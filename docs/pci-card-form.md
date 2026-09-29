# Card form in the booking flow — PCI DSS concern

Status: **resolved in the app: payment is handled at the facility.**

## What the code does today

The booking flow no longer asks for card or wallet credentials, offers
InstaPay/Vodafone Cash/Fawry payment, or displays a fabricated payment
reference. It records the booking with `paymentMethod: 'pay_at_facility'` and
tells the user that MUSTER does not collect or process payment.

## Why this is still a problem

The app never processes a payment. There is no gateway integration, no
payment intent, and no settlement. Before the change, the form accepted real card details and reported a successful
booking without moving money. That created three distinct problems:

1. **PCI DSS scope.** Handling a PAN and CVC in an app you own pulls the app
   into PCI DSS scope (SAQ-D rather than SAQ-A). Google Play and Apple both
   expect either a certified PCI attestation or proof that card data is never
   touched. Even "validated locally and discarded" is a defensible SAQ-A-EP
   position only if the field is removed or tokenised by a compliant SDK.
2. **A misleading control (dark pattern).** The user types real card details
   into a form that cannot charge them, then sees a confirmation. From the
   user's point of view the app claims to have taken payment.
3. **Unnecessary data collection.** Under data minimisation the app has no
   legitimate need for a PAN it cannot use.

This removes card-data collection and avoids claiming that a payment was
processed. If online payments are added later, integrate a compliant payment
provider and update the privacy, terms, and refund disclosures before release.
