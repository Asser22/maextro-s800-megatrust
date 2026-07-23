# Maextro S800 · Path to Market

Mega Trust Group's go-to-market roadmap — from the live MVP to a launch-ready
import business.

**Visual version (shareable):** the same document rendered as a branded page —
ask for the artifact link, or rebuild from `tool/` assets.

**Live product:** https://maextro-s800-megatrustcompany.asserjobsearch.workers.dev/

---

## Phase 0 — Shipped

A genuine cross-platform product from one Flutter codebase: deployed to the
web, ready to compile for iOS and Android from the same source.

- 5 screens — showcase, gallery, specification, live configurator, landed-cost order sheet
- Responsive — app-like on phone, two-column site on desktop
- Real photography that swaps with the chosen finish
- Landed-cost calculator, every assumption editable on screen
- Verified 2026 specification, corrected against two independent sources

**Backend: none yet.** That's the line this roadmap crosses.

---

## What "MVP" honestly means here

1. **A lead that doesn't email you is lost.** The reservation opens the
   customer's mail app; if they don't send, you never know. No record.
2. **The landed price is an estimate.** Duty/tax/clearance are placeholders
   until a broker confirms them — the most financially dangerous number in the app.
3. **English only.** It's Alexandria; most walk-in buyers read Arabic first.
4. **Prices and rates are frozen in code.** Every change needs a redeploy.
5. **Photography is 860px.** Soft on a laptop hero. Fixed by the dealer media pack.

---

## Phase 1 — Ready to sell (weeks, low cost, mostly not code)

| Item | Priority | Owner |
|---|---|---|
| Verified customs & tax figures, in writing | **Critical** | Customs broker |
| Custom domain (megatrust.net) | Next | You + me |
| Arabic + RTL | Next | Translator + me |
| Lead capture that reaches you (not the customer's mail app) | Next | Me |
| Legal & advertising review (import licence, CLTC claim disclaimers, reservation terms) | **Critical** | Lawyer |
| High-res photography + decide margin visibility | Quick | You + supplier |

## Phase 2 — A real product (the backend)

| Item | Note | Owner |
|---|---|---|
| Database + admin panel | Change cars/prices/rates/photos with no redeploy. Recommend **Supabase**. | Me |
| Lead pipeline | Every enquiry stored, status-tracked, assigned, followed up. | Me |
| Instant team notifications | New lead → WhatsApp/Telegram in seconds. Speed-to-lead wins car sales. | Me |
| Live exchange rates | RMB→EGP, USD→EGP daily. Today hardcoded → quotes drift. | Me |
| Online reservation deposit | Real gateway: **Paymob** / **Fawry** (Egypt-native) or Stripe. | Me + gateway |
| WhatsApp Business API + analytics | Two-way, templated, tracked; learn what sells. | Me |

## Phase 3 — Scale (once proven)

| Item | Note |
|---|---|
| iOS + Android apps | Same Flutter code. Apple $99/yr + Mac/Xcode; Google $25 once; store review; privacy policy. |
| Multi-car catalogue + customer accounts | Add models without code; buyers track their order and documents. |
| After-sales module | Service booking, parts, warranty. The thing that retains ultra-luxury buyers. |

---

## Not a coding problem — get professionals

I can build the whole product. I can't invent Egyptian import law, customs
rates or homologation rules — those need real experts, and their answers feed
back into the app.

- **Customs broker** *(critical)* — duty/tax/clearance in writing, HS code, EV vs EREV treatment, homologation/type approval
- **Lawyer** *(critical)* — import licence, company + VAT registration, consumer-protection & advertising compliance, warranty & reservation terms
- **After-sales partner** *(make-or-break)* — who services a Maextro in Alexandria, and the parts channel
- **Accountant** — VAT, corporate tax, costing-model sanity check
- **Supplier agreement · insurance · finance** — authorised import status + media assets; insurer and bank finance partner

---

## Under the hood — infrastructure & quality

- Custom domain + SSL (Cloudflare)
- Push-to-deploy via GitHub Actions (replaces the manual `tool/deploy.sh`)
- Error monitoring (Sentry)
- Performance — rendering engine is ~3.6 MB compressed; a lighter build speeds first load
- Uptime monitoring + lead-database backups
- Expand test coverage beyond the current six checks

---

## If you do nothing else — the five that matter most

1. **Verified customs numbers** — or every quote is fiction
2. **Your own domain** — a business address, not a test URL
3. **Arabic** — it's Alexandria
4. **Lead capture that reaches you** — never lose an enquiry
5. **An after-sales plan** — the promise behind a ¥1M car
