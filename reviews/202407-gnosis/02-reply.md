# Addressing review comments

## Attacker can steal tokens from user who opted out consented flow

### Summary

If any user opts out of consented flow by calling `setAdvancedUsageFlag()` with argument `ADVANCED_FLAG_OPTOUT_CONSENTEDFLOW` they accept that parties they do not trust may hold their tokens due to their tokens being used as a transition in a flow matrix. Due to the way group tokens are minted when operating a flow matrix, any group can steal every tokens held by a user. Without consented flow, an attacker can deploy a group and steal tokens from the user without requiring the trust of the user.

(for full description, see report)

### Response strategy:
1. consider only consented flow, ie. remove ability to opt-out. Even if 3. is adopted as the elegant fix for netting the flow matrix correctly over group mints, it still leaves open the first premise of the severe attack: "Attacker can steal tokens from user who opted out consented flow", which matters once different Circles identifiers have market price valuations.
2. consider requiring the flow operator must be authorised for all touched vertices:
    - (re)imposing this restriction makes it a lot harder to iterate on improvements for flow operators;
    - on the other hand, enabling it would be a strong mechanism against yet unknown exploits in the protocol. This however needs to be balanced with our confidence in the correctness of the implementation.
3. consider improving how the flow matrix should be netted over group mints along a flow path to remove the error of nullable path edges.