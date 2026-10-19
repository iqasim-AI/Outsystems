# Example: full integration — external payment gateway

A complete two-way integration:
- **We call them**: get a token, create a payment, check its status.
- **They call us**: a webhook tells us when the payment is paid or failed.
- **Safety net**: a timer checks payments that never got a webhook.

`PaymentGateway` is a placeholder. Replace URLs, fields and auth with your provider's real API docs.

Build in this order.

---

## 1. Entity to track each payment (_CS)
```
/create-entity Payment in Payment_CS, attributes:
- AuctionInvoiceId: AuctionInvoice Identifier (from Auction_CS), mandatory, delete rule Protect
- Amount: Decimal(18,2), mandatory
- Currency: Text(3), mandatory, default "SAR"
- StatusId: PaymentStatuses Identifier, mandatory, default Pending
    (static entity PaymentStatuses: Pending, Paid, Failed, Expired, Refunded)
- MerchantReference: Text(50), mandatory, unique   -- our id sent to the gateway
- GatewayPaymentId: Text(100), optional, unique    -- their id
- CheckoutUrl: Text(500), optional
- FailureReason: Text(250), optional
- PaidOn: Date Time, optional
- LastCheckedOn: Date Time, optional
```
Then:
```
/create-crud Payment in Payment_CS — also add Payment_GetByMerchantReference
and Payment_GetByGatewayPaymentId
```

---

## 2. Get and cache the access token (_IS)
```
/consume-rest-api GetAccessToken in PaymentGateway_IS:
POST {PaymentGatewayBaseUrl}/oauth/token
Body (form): grant_type=client_credentials, client_id, client_secret
  - client_id and client_secret from Site Properties (encrypted / secret settings).
Response: access_token, expires_in (seconds).

Wrapper: PaymentGateway_GetToken() -> Token (Text)
- Cache the token and its expiry (e.g. in a small entity or Site Property).
- Reuse the cached token until 60 seconds before it expires; then request a new one.
- Never log the token or the client secret.
```

---

## 3. Create a payment (_IS)
```
/consume-rest-api CreatePayment in PaymentGateway_IS:
POST {PaymentGatewayBaseUrl}/v1/payments
Headers:
  Authorization: Bearer {token from PaymentGateway_GetToken}
  Idempotency-Key: {MerchantReference}   -- prevents double charge on retry

Request:
{
  "amount": 1500.00,
  "currency": "SAR",
  "merchantReference": "PAY-2026-000123",
  "description": "Auction invoice INV-55821",
  "callbackUrl": "{OurBaseUrl}/PaymentAPI/rest/v1/webhooks/payment",
  "returnUrl": "{OurPortalUrl}/payment/result"
}

Response:
{ "paymentId": "pg_8f3a...", "status": "PENDING", "checkoutUrl": "https://..." }

Wrapper: PaymentGateway_CreatePayment(Amount, Currency, MerchantReference, Description)
  -> Success, ErrorCode, ErrorMessage, GatewayPaymentId, CheckoutUrl
- If the response is 401, refresh the token once and retry.
- Do NOT retry on timeout for this POST unless the Idempotency-Key is sent.
- Map gateway errors to: GATEWAY_UNAVAILABLE, INVALID_REQUEST, AUTH_FAILED.
```

---

## 4. Check payment status (_IS)
```
/consume-rest-api GetPaymentStatus in PaymentGateway_IS:
GET {PaymentGatewayBaseUrl}/v1/payments/{paymentId}
Response: paymentId, status (PENDING | PAID | FAILED | EXPIRED), paidAt, failureReason.

Wrapper: PaymentGateway_GetPaymentStatus(GatewayPaymentId)
  -> Success, ErrorCode, Status (mapped to our PaymentStatuses), PaidOn, FailureReason
Safe read: retry up to 2 times on timeout or 5xx.
```

---

## 5. Business logic (_BL)
```
/create-logic Payment_Start in Payment_BL:
Inputs: AuctionInvoiceId (mandatory)
Outputs: PaymentId, CheckoutUrl

1. Get the invoice with AuctionInvoice_GetById (Auction_CS). Must exist and be Unpaid.
2. If a Pending payment already exists for this invoice and has a CheckoutUrl,
   return it (don't create a second payment).
3. Generate MerchantReference "PAY-{year}-{sequence}".
4. Create the Payment record with Payment_Create (Payment_CS), status Pending.
5. Call PaymentGateway_CreatePayment (PaymentGateway_IS).
   - On failure: set status Failed with FailureReason and raise a user-friendly error.
6. Save GatewayPaymentId and CheckoutUrl with Payment_Update.
```

```
/create-logic Payment_ApplyStatus in Payment_BL:
Inputs: GatewayPaymentId, NewStatus, PaidOn, FailureReason
Used by BOTH the webhook and the reconciliation timer.

1. Find the payment with Payment_GetByGatewayPaymentId. If not found, log a warning and exit.
2. Idempotent: if the payment is already in a final status (Paid, Failed, Expired, Refunded),
   do nothing and exit. Never move Paid back to Pending or Failed.
3. Update status, PaidOn, FailureReason, LastCheckedOn with Payment_Update.
4. If NewStatus = Paid: mark the invoice paid with AuctionInvoice_MarkPaid (Auction_BL)
   in the same transaction.
5. LAST: send a notification with Notification_Send (Notification_SL).
   If the notification fails, log it only; don't fail the payment update.
```

---

## 6. Webhook — the gateway calls us (_API)
```
/create-rest-api PaymentWebhook in Payment_API:
Add to REST API "PaymentAPI".
POST /v1/webhooks/payment

Request (sent by the gateway):
{ "eventId": "evt_91c...", "type": "payment.updated",
  "data": { "paymentId": "pg_8f3a...", "status": "PAID", "paidAt": "2026-10-19T09:12:00Z" } }

Security:
- Verify the signature header "X-Signature": HMAC-SHA256 of the raw body using
  Site Property PaymentWebhookSecret. Reject with 401 if it doesn't match.
- Optionally allow only the gateway's IP range (Site Property).
- No user login on this endpoint; the signature is the authentication.

Processing:
- Store eventId; if this eventId was already processed, return 200 and do nothing.
- Call Payment_ApplyStatus (Payment_BL).
- Always return 200 quickly once the event is stored, so the gateway doesn't keep retrying.
- Unexpected error: return 500 so the gateway retries later.

Log eventId, paymentId, status and result. Never log the secret or signature.
```

---

## 7. Reconciliation timer (safety net)
```
/create-logic Payment_Reconcile in Payment_BL:
Run by a Timer every 15 minutes (create the Timer in Payment_BL).

1. Get payments with status Pending, created more than 10 minutes ago,
   and LastCheckedOn empty or older than 10 minutes. Max 200 per run.
2. For each: call PaymentGateway_GetPaymentStatus (PaymentGateway_IS),
   then Payment_ApplyStatus (Payment_BL).
3. Payments still Pending after 24 hours: mark Expired.
4. One failing payment must not stop the run; log it and continue.
5. Commit after each payment (CommitTransaction) so progress isn't lost on timeout.
```

---

## 8. Settings to create (one value per environment)
| Site Property | Example | Secret? |
|---|---|---|
| PaymentGatewayBaseUrl | https://sandbox.gateway.example | No |
| PaymentGatewayClientId | ... | Yes |
| PaymentGatewayClientSecret | ... | Yes |
| PaymentWebhookSecret | ... | Yes |
| OurBaseUrl / OurPortalUrl | https://dev.ourapp... | No |

Development and Test point to the gateway **sandbox**. Only Production uses live keys,
and those are set by an admin, never by Claude.

---

## Why it's built this way
- **All gateway calls live in `_IS`**, so `_BL` never knows the gateway's URLs or JSON.
- **Idempotency everywhere**: Idempotency-Key on create, eventId on the webhook, final
  statuses never change. Retries and duplicate webhooks are safe.
- **One status action** (`Payment_ApplyStatus`) is used by the webhook and the timer,
  so the rules are in one place.
- **Webhook + timer**: webhooks can be lost; the timer catches anything missed.
- **Secrets in Settings** and never in logs or prompts.
- **Notification last** and non-blocking, so a failed SMS never undoes a payment.
