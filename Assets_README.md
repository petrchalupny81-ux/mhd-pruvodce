# Assets.xcassets — Color Setup

Přidej do Assets.xcassets tyto Color sety (Light / Dark):

| Name              | Any (Light)  | Dark         |
|-------------------|--------------|--------------|
| AppPrimary        | #0A84FF      | #0A84FF      |
| AppSuccess        | #30D158      | #30D158      |
| AppWarning        | #FF9F0A      | #FF9F0A      |
| AppDanger         | #FF453A      | #FF453A      |
| BusBadge          | #0A84FF      | #0A84FF      |
| TramBadge         | #FF9F0A      | #FF9F0A      |
| MetroBadge        | #30D158      | #30D158      |
| TrainBadge        | #FF453A      | #FF453A      |
| TrolleybusBadge   | #BF5AF2      | #BF5AF2      |

Postup v Xcode:
1. Otevři Assets.xcassets
2. Klikni + → New Color Set
3. Vyplň název a barvu pro Light i Dark
4. Opakuj pro všechny barvy výše

## Audio soubory (.caf)

Musíš dodat vlastní soubory (nebo vygenerovat pomocí `afconvert`):
- alert_far.caf    — jemný dvoutónový zvuk, ~1s
- alert_near.caf   — výraznější dvojitý zvuk
- alert_arrive.caf — trojitý příjezdový zvuk

Jako fallback se použije systémový zvuk ID 1016 (SMS received).

Ukázkový příkaz pro konverzi .aiff → .caf:
```
afconvert -f caff -d LEI16 input.aiff alert_far.caf
```
