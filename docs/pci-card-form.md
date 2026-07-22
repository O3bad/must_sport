# Card form in the booking flow — PCI DSS concern

Status: **open, needs a product decision.**

## What the code does today

`lib/features/booking/presentation/booking_screen.dart` offers four payment
methods: InstaPay, Vodafone Cash, Fawry, and card. Selecting **card** renders
`_GlassCardForm`, which asks for:

- card number (validated as 16 digits)
- expiry (validated as MM/YY, must be in the future)
- CVC (3–4 digits)
- cardholder name (non-empty)

`_GlassCardFormState.validate()` checks those constraints locally. On success
the booking is written to Firestore with `paymentMethod: 'card'` and nothing
else. The card number, expiry, CVC and name are never transmitted to Firestore,
never logged, and never persisted to disk.

## Why this is still a problem

The app never processes a payment. There is no gateway integration, no
payment intent, and no settlement. So the form collects a full PAN and CVC,
validates it, and then displays a successful booking regardless of whether any
money moved. That creates three distinct problems:

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

## Recommended options

Pick one — the first is the recommended default:

1. **Remove the card option.** Keep InstaPay / Vodafone Cash / Fawry, and add a
   clear line: "Pay at the facility. MUSTER does not process card payments."
   This removes PCI scope, removes the dark pattern, and removes the
   unnecessary field in one change.
2. **Integrate a compliant PSP** (Paymob, Fawry, Stripe) and tokenise. The SDK
   collects the card data in its own PCI-compliant surface; the app only ever
   receives a token. This keeps the card option but is real work and needs
   merchant onboarding.
3. **Keep it and accept the compliance cost.** Document the SAQ decision, and
   be aware this is not a graduation-project-appropriate trade.

## Related

- `docs/third-party-sdk-audit.md` § "Data minimisation" item 1.
- The Refund Policy and Privacy Policy §7 already state that card details are
  checked locally and are not transmitted or stored. If option 1 is taken, both
  documents need their §7 / §3 wording simplified.
