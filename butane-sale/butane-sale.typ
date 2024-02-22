#import "../template/audit.typ": *
#import "@preview/finite:0.3.0": automaton

#show: report.with(
  client: "Butane",
  title: "Pro-rata Sale",
  repo: "https://github.com/SundaeSwap-finance/sundae-audits-public",
  date: "2023-02-21",
  authors: (
    (
      name: "Pi Lanningham",
      display: text(1.3em, $pi$) + " Lanningham",
    ),
  ),
)

= Audit Manifest

Please find below the list of pinned software dependencies and files that were covered by the audit.

#software_versions(
  items: (
    (
      name: "Pro-rata Sale",
      version: "0.0.0",
      commit: "580bba7c85603cd87f6b1e037d30915ca0cf543f",
    ),
  )
)

#files_audited(
  items: (
    (
      file: "validators/sale.ak",
      hash: "75780d0962a096b13176c9ac10664a94a6c38badfdb633a9f09be654685c6568",
    ),
    (
      file: "validators/nft.ak",
      hash: "e50a6642c85499da9ccfa18204b4c63d9455a7edde86726746017eef98a4acbf",
    ),
    (
      file: "lib/launchpad/prorata.ak",
      hash: "b141707194119480c4ab4df48acfc941534e6b52d6ba1718a57834ddef0fc37e",
    ),
    (
      file: "lib/launchpad/types.ak",
      hash: "9c322668b8e8c034ede0ecaca95df242c5de66b9b0bef1046fc6bfd695c77496",
    ),
    (
      file: "lib/launchpad/utils.ak",
      hash: "512c6c801f07d6b8ae5d200fc48326b45b36f1161f7e25b278401cc695e6b8ae",
    ),
  )
)

#artifacts(
  (
    (
      validator: "sale",
      method: "deposit",
      hash: "",
    ),
    (
      validator: "sale",
      method: "collect",
      hash: "",
    ),
    (
      validator: "sale",
      method: "machine",
      hash: "",
    ),
    (
      validator: "nft",
      method: "nft",
      hash: "",
    )
  )
)

#pagebreak()

#set par(
  leading: 1em,
  first-line-indent: 1em,
  justify: true,
)

= Context

The Butane token is a new cardano native token with utility in the upcoming "Butane" synthetics protocol. The scripts under audit are a set of smart contracts that govern a so-called "pro-rata" sale of these tokens. The butane team intends to offer 43% of the total supply (10,750,000 Butane) to the public in this sale, at a rate of 0.9 ADA per Butane.

If less than 9,675,000 ADA is raised, the remaining tokens will be burned, reducing the total supply. If more than 9,675,000 ADA is raised, then each user will use the same percentage of their deposit to buy the token at that rate, and the remaining ADA will be returned to them.

For example, if 10,000,000 ADA is raised, then only 96.75% of the raised ADA can actually purchase tokens. Thus, a user who deposited 1,000 ADA would use 967.5 ADA to purchase 1075 Butane, and 32.5 ADA would be returned.

#v(1em)
#set par(first-line-indent: 0em)
This audit was performed by Sundae Labs, with the following understanding:
 - There would be an "admin" user that should be acknowledged as a point of centralization, and should be treated as a largely trusted actor.
   - That is, this actor should never have direct access to the user funds, but can be trusted to progress the protocol, and provide accurate off-chain global state.
 - Performance of the contracts is not a factor.
 - To limit scope and complexity, we are only auditing the Sale portion, not the Butane minting policy.
 - The duration in which the sale should be active is limited, minimizing the window of time in which an attacker has to find a vulnerability.
 - The contracts will remain closed source during the sale, minimizing the information available to an attacker during that vulnerable window.

#pagebreak()

= Specification

The butane prorata sale protocol is intended to facilitate the initial public sale of the Butane token.

The high level objectives of this sale are:
 - A trusted admin begins the sale
 - While the sale is active, users can deposit funds in a bid to purchase Butane tokens
 - This deposit must be a minimum amount of ADA
 - At the end of the sale, the admin can close the sale, preventing further deposits
 - The admin can then calculate the total subscription of the sale, and lock in a "pro-rata" percentage
 - Users, or the admin in large batches, can then claim their portion of the sold tokens, paying a fixed rate for those they mint, and receiving the remaining amount of ADA in return.
 - When rounding, values should be rounded in favor of the protocol. That is, a user may receive up to 1 diminutive unit less of Butane than they paid for, resulting in a slightly smaller total supply of Butane.
 - The admin can exercise discretion over the timing of the raise
 - The admin should not be able to change the terms of the sale
 - Users should be able to reclaim their ADA after an expiration if the sale doesn't terminate for some reason.

In particular, what we mean by pro-rata distribution is:
  - Let the butane price be the quantity of butane per 1 ADA raised
  - Let the total purchased butane amount be the total deposited ADA multiplied by the butane price
  - If the total purchased butane amount is less than the amount allocated to the sale
    - Let each deposit be spent if the deposited ADA is paid to the admin, and `deposit_amount * butane_price` is minted and paid to the depositer
  - If the total purchased butane amount is greater than the amount allocated to the sale
    - Let the pro-rata percentage be `sale_allocation / total_purchased_butane_amount`
    - Let the pro-rata payment be `deposited_ada * pro_rata_percentage`
    - Let the rebate amount be `deposited_ada - pro_rata_payment`
    - Let each deposit be spent if `pro_rata_payment` ADA is paid to the admin, and `pro_rata_payment * butane_price` Butane plus `rebate_amount` ADA is paid to the depositer

#pagebreak()

The full protocol should adhere to the following state transition diagram:
#v(3em)
#scale(x: 150%, y: 150%, origin: top+left)[
  #automaton(
    (
      Pending: (Live:("Begin Sale")),
      Live: (Counting:("End Sale")),
      Counting: (Closed:("Close Sale")),
      Closed: (nil: ("Burn")),
      nil: (),
    ),
    layout: (
      Pending: (0,0),
      Live: (2.5,0),
      Counting: (5, 0),
      Closed: (7.5, 0),
      nil: (7.5, -2)
    ),
    style: (
      Closed-nil: (
        label: (
          angle: 90deg,
        )
      ),
      Pending: (stroke: red),
      Live: (stroke: blue),
      Counting: (stroke: purple),
      Closed: (stroke: green),
    )
  )
]
#v(8em)
Each depositing user should adhere to the following state transition diagram. The highlighted transitions are only valid when the sale is in the appropriately colored state above.

#v(3em)
#scale(x: 150%, y: 150%, origin: top+left)[
  #automaton(
    (
      Abstain: (Deposit: ("Deposit")),
      Deposit: (Claimed: ("Claim"), Reclaimed: ("Expired")),
      Claimed: (),
      Reclaimed: (),
    ),
    final: ("Abstain", "Claimed", "Reclaimed"),
    layout: (
      Abstain: (0,0),
      Deposit: (2.5, 0),
      Claimed: (5, 0),
      Reclaimed: (2.5, -2),
    ),
    style: (
      Abstain-Deposit: (stroke: blue),
      Deposit-Claimed: (stroke: green),
    )
  )
]

#pagebreak()

== Detailed Specification

=== Definitions

#defn("Butane Token", "The native token of the butane protocol being sold as part of these contracts")
#defn("Public Sale", [
  A specific offering of the #ref("Butane Token") available to all users through the decentralized protocol covered by this audit
])
#defn("Admin UTXO", [
  A trusted UTXO, authenticated by a unique NFT, used as a reference input to describe the global state of the #ref("Public Sale")
])
#defn("Admin NFT", [
  The NFT authenticating the #ref("Admin UTXO")
])
#defn("State Machine", [
  A smart contract implementing a simple state machine through which the #ref("Admin UTXO") is advanced by the #ref("Admin").
])
#defn("Admin", [
  A user trusted to advance the #ref("Admin UTXO") through the stages of the sale correctly.
])
#defn("Deposit", [
  Either:
   - The act of depositing ADA to participate in the sale
   - A specific UTXO holding the ADA of a user participating in the sale
])
#defn("Counting Token", [
  A temporary token minted to authenticate participation in the #ref("Public Sale").
])
#defn("Sale Allocation", [
  The total amount of #ref("Butane Token") allocated to the #ref("Public Sale")
])
#defn("Sale Price", [
  The price of the #ref("Butane Token") for the purposes of the #ref("Public Sale"), either in ADA per Butane or Butane per ADA, depending on context.
])
#defn("Target Raise", [
  The total amount of ADA being sought as part of the #ref("Public Sale"). Calculated as the #ref("Sale Allocation") times the #ref("Sale Price") in ADA per Butane.
])
#defn("Subscription", [
  The total amount of ADA deposited in the #ref("Public Sale")

  Related:
  - A #ref("Public Sale") is under-subscribed when the total amount of ADA raised is less than the #ref("Target Raise")
  - A #ref("Public Sale") is over-subscribed when the total amount of ADA raised is greater than the #ref("Target Raise") 
])
#defn("Pro-rata Percentage", [
  The percentage of the #ref("Sale Allocation") that each user is entitled to, based on their deposit amount.
  This is calculated as follows:
  - If under-subscribed, it is 100%
  - If over-subscribed, it is the #ref("Sale Allocation") divided by the #ref("Subscription").
])
#defn("Rebate", [Some amount of ADA returned returned to the user when the #ref("Public Sale") is over-subscribed.])
#defn("Target Recipient", [The cardano address that will receive ADA raised from the #ref("Public Sale")])
#defn("Recipient", [The address attached to a specific deposit which will receive the #ref("Butane Token") and possibly a #ref("Rebate").])

#pagebreak()

=== Transactions

There are 7 transaction archetypes in this protocol. We present each in detail below.

- Initialization
  - A new #ref("Public Sale") is initialized by the #ref("Admin") creating the #ref("Admin UTXO")
  - An NFT must be minted and paid into a UTXO with the correct `Pending` datum.
  - This represents the initial `Start` transition in the state diagram above.

#v(5em)
#transaction(
  "Initialization",
  inputs: (
    (
      name: "Admin Wallet",
      value: (
        ada: "minUTXO",
      )
    ),
  ),
  outputs: (
    (
      name: "Admin UTXO",
      address: "State Machine",
      value: (
        ada: "minUTXO",
        NFT: 1,
      ),
      datum: (
        "Pending": ""
      )
    ),
  )
)

#pagebreak()

- Begin Sale
 - The #ref("Admin") opens the sale to the public by spending the #ref("Admin UTXO") and updating the state to `Live`.
 - Represents the transition from "Pending" to "Live" in the diagram above.
 - Involves a commitment to sale details.

#v(5em)
#transaction(
  "Begin Sale",
  inputs: (
    (
      name: "Admin UTXO",
      address: "State Machine",
      value: (
        ada: "minUTXO",
        NFT: 1,
      )
    ),
  ),
  outputs: (
    (
      name: "Admin UTXO",
      address: "State Machine",
      value: (
        ada: "minUTXO",
        NFT: 1,
      ),
      datum: (
        "Live": (
          total_expected_ada: [A#sub[e]],
          price_n: [P#sub[n]],
          price_d: [P#sub[d]],
          mint_token_pol: "policy",
          mint_token_tn: "token name",
          expiry_time: [`K`],
        )
      )
    ),
  )
)

#pagebreak()

- Deposit
  - A user deposits ADA, securing their position in the #ref("Public Sale").
  - An equal amount of #ref("Counting Token") is minted to verify that the deposit was made while the #ref("Public Sale") was still ongoing, rather than after the fact.
  - The #ref("Public Sale") must be live, as proven through a reference input.
  - The user must commit to the details of the sale.
  - Represents the users transition from "Abstain" to "Deposit" in the diagram above.

#v(5em)
#transaction(
  "Deposit",
  inputs: (
    (
      name: "User Wallet",
      value: (
        ada: "X+Y",
      )
    ),
    (
      name: "Admin UTXO",
      address: "State Machine",
      reference: true,
      value: (
        ada: "minUTXO",
        NFT: 1,
      ),
      datum: (
        "Live": (
          total_expected_ada: [A#sub[e]],
          price_n: [P#sub[n]],
          price_d: [P#sub[d]],
          mint_token_pol: "policy",
          mint_token_tn: "token name",
          expiry_time: [`K`],
        )
      )
    )
  ),
  outputs: (
    (
      name: "Deposit UTXO",
      address: "sale.collect",
      value: (
        ada: "X",
        counting: "X",
      ),
      datum: (
        recipient: "User Address",
        locked_lovelace: "X",
        details_hash: [`H`],
        expiry_time: [`K`],
      )
    ),
    (
      name: "Change UTXO",
      address: "User Address",
      value: (
        ada: "Y",
      )
    ),
  ),
  notes: [
    `H` is the hash of the admin Datum launch details.
  ]
)

#pagebreak()

- End Sale
 - End the #ref("Public Sale"), preventing further deposits
 - Also allows time for the #ref("Admin") to calculate the #ref("Subscription") and #ref("Pro-rata Percentage") before closing the sale.
 - Represents the transition from "Live" to "Counting" in the diagram above.

#v(5em)
#transaction(
  "End Sale",
  inputs: (
    (
      name: "Admin UTXO",
      address: "State Machine",
      value: (
        ada: "minUTXO",
        NFT: 1,
      ),
      datum: (
        "Live": (
          total_expected_ada: [A#sub[e]],
          price_n: [P#sub[n]],
          price_d: [P#sub[d]],
          mint_token_pol: "policy",
          mint_token_tn: "token name",
          expiry_time: [`K`],
        )
      )
    ),
  ),
  outputs: (
    (
      name: "Admin UTXO",
      address: "State Machine",
      value: (
        ada: "minUTXO",
        NFT: 1,
      ),
      datum: (
        "Counting": ""
      )
    ),
  )
)

#pagebreak()

- Close Sale
 - The #ref("Admin") closes the sale after calculating the #ref("Subscription") and #ref("Pro-rata Percentage").
 - Locks in a price and a #ref("Subscription") amount, so that claims can begin claiming.
 - Represents the transition from "Pending" to "Closed" in the diagram above.

#v(5em)
#transaction(
  "Close Sale",
  inputs: (
    (
      name: "Admin UTXO",
      address: "Admin Address",
      value: (
        ada: "minUTXO",
        NFT: 1,
      ),
      datum: (
        "Counting": ""
      )
    ),
  ),
  outputs: (
    (
      name: "Admin UTXO",
      address: "Admin Address",
      value: (
        ada: "minUTXO",
        NFT: 1,
      ),
      datum: (
        "Closed": (
          "total_deposited_ada": [A#sub[d]],
        )
      )
    ),
  )
)

#pagebreak()

- Claim
 - Someone (either the user, or someone on their behalf) spends a deposit, burning the #ref("Counting Token"), paying the appropriate ADA to the #ref("Target Recipient"), and minting the appropriate amount of #ref("Butane Token"), paid along with any #ref("Rebate") to the #ref("Recipient").
 - $P_n / P_d$ is the #ref("Sale Price") denominated in ADA per Butane
 - $A_e$ refers to the #ref("Sale Allocation")
 - $A_d$ refers to the #ref("Subscription")

#v(2em)
#transaction(
  "Claim",
  inputs: (
    (
      name: "Deposit UTXO",
      address: "sale.collect",
      value: (
        ada: "X",
        counting: "X",
      ),
      datum: (
        recipient: [`recipient1`],
        locked_lovelace: "X",
        details_hash: [`H`],
        expiry_time: [`K`],
      )
    ),
    (
      name: "Deposit UTXO",
      value: (
        ada: "Y",
        counting: "Y",
      ),
      datum: (
        "...": ""
      )
    ),
    (
      name: "...",
    ),
    (
      name: "Admin UTXO",
      reference: true,
      value: (
        ada: "minUTXO",
        NFT: 1,
      ),
      datum: (
        "Closed": (
          "total_deposited_ada": [A#sub[d]],
        )
      )
    ),
  ),
  outputs: (
    (
      name: "User Output",
      address: [`recipient1`],
      value: (
        ada: "X - Pa",
        butane: "Ba",
      ),
    ),
    (
      name: "User Output 2",
      address: [`recipient2`],
      value: (
        ada: "Y - Pb",
        butane: "Bb",
      )
    ),
    (
      name: "Payment UTXO",
      address: "Target Recipient",
      value: (
        ada: "Pa + Pb",
      )
    ),
  ),
  notes: [
    #linebreak()
    `H` must match hash of details in each deposits redeemer
    $ P_i = cases(
      X_i "if" A_d <= A_e,
      floor(frac(X_i * A_e, A_d)) "if" A_d > A_e,
    ) $
    $ B_i = floor(frac(P_i * P_d, P_n)) $
  ]
)

#pagebreak()

- Reclaim
 - Someone reclaims their ADA after the expiration.
 - Only used in disaster recovery, if the sale datum is burned too soon.

#v(2em)
#transaction(
  "Reclaim",
  inputs: (
    (
      name: "Deposit UTXO",
      address: "sale.collect",
      value: (
        ada: "X",
        counting: "X",
      ),
      datum: (
        recipient: [`recipient1`],
        locked_lovelace: "X",
        details_hash: [`H`],
        expiry_time: [`K`],
      )
    ),
    (
      name: "Deposit UTXO",
      value: (
        ada: "Y",
        counting: "Y",
      ),
      datum: (
        "...": ""
      )
    ),
    (
      name: "...",
    ),
  ),
  outputs: (
    (
      name: "User Output",
      address: [`recipient1`],
      value: (
        ada: "X",
      ),
    ),
    (
      name: "User Output 2",
      address: [`recipient2`],
      value: (
        ada: "Y",
      )
    ),
  ),
  notes: [
    #linebreak()
    `K` must be before the transaction lower bound.
  ]
)
#pagebreak()

=== Core Invariants

We use the following labels for the terms defined above:
 - $P_n / P_d$ is the #ref("Sale Price") denominated in ADA per Butane
 - $A_e$ refers to the #ref("Sale Allocation")
 - $A_d$ refers to the #ref("Subscription")

#set enum(numbering: "1.a)")
#v(1em)
The protocol is considered correctly executed if:
 + The #ref("Admin NFT") is minted and paid with a `Pending` datum to the state machine script.
 + The #ref("State Machine") is advanced to `Live` with sale details matching those published publicly.
 + The #ref("State Machine") is advanced by the #ref("Admin") according to a reasonable schedule.
 + At least 1 hour without rollbacks passes between advancing the #ref("State Machine") to `Counting`, and advancing it to `Closed`.
 + The #ref("Subscription") amount provided to the state machine represents the total supply of the #ref("Counting Token"), and thereby the total amount of ADA locked in the script.

#v(1em)
The following core invariants should hold:
 + The #ref("Admin") can be trusted to progress the protocol, and provide accurate off-chain global state.
 + A user can only mint an amount #ref("Counting Token") by paying the same amount of Lovelace into the `sale.collect` script
 + A user must lock at least 300 ADA to participate in the sale.
 + A user can only mint Butane by burning the full amount of #ref("Counting Token") on their UTXO
 + A user can only mint #ref("Counting Token") while the #ref("Admin UTXO") is `Live`
 + A user can only claim the results of the #ref("Public Sale") after the #ref("Admin UTXO") has progressed to the `Closed` state.
 + The #ref("Admin") cannot change the details of the sale after it is in the `Live` state.
 + The total minted butane minted must not exceed $A_e * P_d / P_n$
 + A user can only mint Butane by paying $P_n / P_d$ ADA per #ref("Butane Token") paid to the #ref("Target Recipient")
 + The #ref("Butane Token") minted from a deposit must be paid to the #ref("Deposit") #ref("Recipient")
 + If $A_d <= A_e$, a user must pay the full amount of `locked_lovelace` to the #ref("Target Recipient") and mint $floor(frac("locked_lovelace" * P_d, P_n))$ Butane to the #ref("Recipient")
   + We use `floor` because we cannot mint a fractional diminutive unit, and rounding down favors the protocol: the user may receive 1 diminutive unit less Butane than they paid for
   + This helps maintain Invariant 5
 + If $A_d > A_e$, a user must pay $"paid_lovelace" = floor(frac("locked_lovelace" * A_e, A_d))$ ADA to the #ref("Target Recipient") and mint $floor(frac("paid_lovelace" * P_d, P_n))$ Butane to the #ref("Recipient")
   + We take the floor when calculating the `paid_lovelace` to maintain Invariant 5. If we took the ceiling, `paid_lovelace` might be 1 lovelace more than the correct pro-rata amount, which could result in higher minted Butane than the #ref("Sale Allocation")
   + Similarly, we take the floor when calculating the minted Butane to maintain Invariant 5
 + Any difference between `locked_lovelace` and `paid_lovelace` must be returned to the #ref("Recipient") along with the minted Butane.
 + After some minimum time delay, if the #ref("Deposit") hasn't been claimed yet, a user can reclaim their `locked_lovelace` from the `sale.collect` script
#pagebreak()

= Findings Summary

#findings(prefix: "BTN", items: (
  (
    title: [No commitment to price or allocation by Admin],
    severity: "Critical",
    description: [
      The protocol has an Admin role, that has the following two trust assumptions:
      - They will progress the protocol through the state machine
      - In the Close sale transaction, they will provide an accurate value for $A_d$, such that $A_d$ is the sum of all `locked_lovelace` in valid #ref("Deposit")s.

      However, the admin has much more control and requires much more trust than this. In particular, there is no commitment to the total expected ADA, the sale price, or the butane token policy ID.

      This makes the following attacks possible, which we deem outside of a reasonable trust assumption for such a sale:
      - Users lock up ADA in expectation of receiving Butane at a price of 0.9 ADA per Butane, and instead the price is set to 1000 ADA per Butane.
      - Users lock up ADA in expectation of collectively receiving 43% of the supply, and instead only 0.1% of the supply is distributed, with the rest retained by the team.
      - Users lock up ADA in expectation of receiving Butane, but are given some other worthless token instead. 
    ],
    recommendation: [
      Add `total_expected_ada`, `price_n`, `price_d`, `mint_token_pol` and `mint_token_tn` to the `Pending` and `Live` datums.

      Lock the Admin UTXO in a script that allows the #ref("Admin") to adhere to the state changes, and enforces that these values remain the same during each state transition.

      This way, users can confirm the details of the sale before making the decision about whether to participate.
    ],
    resolution: (
      commit: "53cb47dc77da6a9c053d2ab9c8baf416ea1e7409"
    )
  ),
  (
    title: [Not commitment to sale schedule],
    severity: "Major",
    description: [
      The protocol assumes that the admin will be responsible for eventually progressing the protocol, but does not assume they are trusted to progress the protocol in accordance with a schedule.

      One design goal is to allow reasonable flexibility in the timing. This is to allow an *almost* subscribed sale to wait for it's full sale before closing, without prescribing a set time.

      However, in the current protocol, the admin must be trusted to adhere to that reasonable schedule. For example, the admin could drag out the sale for months if the sale is under-subscribed, trying to eke out more and more ADA, while participants are locked in and have no way to cancel.

      Similarly, the admin could close the sale at any time, limiting the participants and impacting the amount of Butane burned.

      Finally, the admin could reopen the sale after some tokens have been claimed, allowing further deposits to raise more ADA.
    ],
    recommendation: [
      Simplify the sale state machine to just include `Sale` and `Closed` states.
      Lock the #ref("Admin UTXO") in a script that allows the admin to progress the protocol.
      Add a `start_time`, `minimum_length` and `maximum_length` fields to the `Sale` and `Closed` datums.
      Use the `start_time` to prevent deposits before the sale starts, and `start_time + maximum_length` to automatically close the sale and prevent further deposits.
      Then, only a single transition from `Sale` to `Closed` is needed from the admin to report the #ref("Subscription"). Enforce that this happens after `start_time + minimum_length` to ensure the sale stays open for a minimum length of time.
      Add the ability to reclaim ADA if they wish after some delay. This way, if the protocol never progresses for some reason, at the very least the ADA isn't locked forever.

      In this way, the #ref("Admin") has flexibility over the timing of the sale, but users also know ahead of time the reasonable bounds on the schedule of the protocol. The trust placed in the #ref("Admin") is minimized, as they are only trusted to progress the protocol and provide an accurate #ref("Subscription") amount.
    ],
    resolution: (
      comment: "Flexibility in the timing of the sale is a design goal, and combined with the state machine and expiration we implemented for other findings, we believe the timing issue is safely within trust assumptions we are comfortable with"
    )
  ),
  (
    title: [Admin can change terms during partial claim or deadlock unclaimed funds],
    severity: "Critical",
    description: [
      The admin is trusted to progress the protocol, and provide accurate information.

      However, in the current implementation, because the #ref("Admin UTXO") is just held in a wallet, after the sale is closed, the admin can spend the UTXO before all participants have claimed.

      First, this could be used to change the terms of the sale part way through claims. For example, the admin could immediately claim funds for any insiders immediately when the sale is closed, and then change the price or allocation for the remaining claimants.

      Second, the admin could spend the UTXO to remove the datum completely. Because claiming depends on this UTXO as a reference input, this would permanently lock users ADA in the deposit.
    ],
    recommendation: [
      As with the other findings, lock the #ref("Admin UTXO") in a script. The script should enforce that after the sale is closed and the terms are provided, it is never spent again.

      This ensures that no user funds become deadlocked, and the terms of the sale don't change after some users have claimed.

      Alternatively, allow users to reclaim their ADA after some timeout, to ensure that even if the Admin behaves badly, at the very least they get their ADA back.
    ],
    resolution: (
      commit: "bcddbd7a2a590404db8e6abbf0599b20b9b608eb"
    )
  ),
  (
    title: [Attach staking addresses to deposits],
    severity: "Info",
    description: [
      Because the sale may span an epoch boundary, you should ensure the users stake address is attached to any deposits. This doesn't impact the correctness of the script, but ensures that users earn staking rewards for any ADA before the sale officially completes.

      You likely intended to do this anyway, but it's worth highlighting explicitly.
    ],
    resolution: (
      comment: "We address this by enforcing the recipient stake address equals the deposit utxo stake address"
    )
  ),
  (
    title: [Incomplete solutions to previous findings],
    severity: "Major",
    description: [
      The solutions to #ref("BTN-000") and #ref("BTN-001") provide some protection, reducing the severity to only "Major", but are not sufficient in our view.

      #ref("BTN-000") was resolved by adding sale details to the `Live` datum, storing the hash of the sale details in the deposit datum, and verifying the sale details provided through the redeemer match the hash.

      #ref("BTN-001") was addressed by implementing a simple state machine that transitions from `Pending`, to `Live`, to `Closed`.

      However, the implementation suffers from two issues:
       - The state machine never no longer has a transition back to `Pending`, meaning deposits cannot be halted to count up the total subscription. A user may deposit in between the total being counted and the sale being closed, resulting in an excess of Butane being minted.
       - The state machine can be burned, deleting the admin token. Any unclaimed ADA would be permanently locked at that point.
    ],
    recommendation: [
      - Add an intermediate state to allow for counting the total subscription in between the close of the sale and the opening of claims.
      - Either disallow the evaporation of the state machine, or add an expiration, after which a user that was never calimed can reclaim their ADA, even if the admin UTXO has been burned.
    ],
    resolution: (
      commit: "c0f71e9952487cd491888bfb13ad2e78b11a89b0"
    )
  ),
  (
    title: [Issues with minUTXO protections],
    severity: "Info",
    description: [
      One stated goal was to allow the user to lock up an arbitrary amount of ADA, so long as the purchase amount in the datum is less than or equal to the amount in the datum.

      This is to allow the user to include the minUTXO amount, so that the Butane team doesn't need to cover the minUTXO amount when forcing claims for users.

      However, there are three issues.

      First, the user is not actually allowed to lock up an arbitrary amount of ADA. When executing a deposit, the following condition is checked:
      ```
      assert(
        locked_value == (
          value.from_lovelace(lovelace_sent)
            |> value.add(own_pid, "", lovelace_sent)
        ),
        @"Recipient value must be equal to the lovelace_sent field in the redeemer!",
      ),
      ```

      This means that `locked_lovelace` from the datum must always match the amount of ADA in the deposit.
      
      Second, when claiming, the exact amount of ADA is checked here:
      ```rust
      // previously was validating that the input was the rebated value.
      // Now, we check it correctly corresponds to datum.
      (( lovelace |> dict.to_list ) == [("", locked_lovelace)])?,
      ```

      If the lovelace on the UTXO differs from the amount in the datum, the sale will be un-claimable.

      Finally, when checking the result, the amount sent back to the user is compared via:
      ```rust
      lovelace_amt >= must_rebate,
      ```

      If the user had included an extra amount in their deposit to cover minUTXO, and received a rebate, then whoever executed their claim would be able to take the surplus.

      Coincidentally, these issues nullify eachother: because the user cannot lock up additional ADA, there is no concern about the additional ADA being taken, or the UTXO being unspendable.
    ],
    recommendation: [
      If you would like to preserve this property, we recommend switching the first check to comparing a greaterthan, like so:
      ```
      assert(
        and {
          value.lovelace_of(locked_value) >= lovelace_sent,
          value.without_lovelace(locked_value) == value.add(own_pid, "", lovelace_sent)
        },
        @"Recipient value must be equal to the lovelace_sent field in the redeemer!",
      ),
      ```
      
      Then, update the second check to compare the #ref("Counting Token")s instead, like so:
      ```
      (( other_dict |> dict.to_list ) == [("", locked_lovelace)])?,
      ```

      This is equivalent to the intention, since the minting policy checks that #ref("Counting Token")s are minted equal to the amount in the datum, but avoids the surplus ADA issue.

      Finally, we recommend checking that the amount sent to the user is exactly:
      ```
      lovelace_amt == this_value.lovelace - must_send
      ```

      Which ensures that the user receives the full amount of ADA they put in, minus the amount they paid in the sale.

      Alternatively, you can simply acknowledge the risk that Butane may need to cover the minUTXO costs to fully realize the claim. The upper-bound for this cost would be if the full amount was subscribed exactly (meaning no rebates were available to cover the minUTXO), and the most users possible claimed at the minimum amount available.

      That would be roughly 32,250 users, with a minUTXO requirement of around 1.2 ADA, or around 38,700 ADA in minUTXO costs. In any case, the minUTXO cost is capped at 0.4% of the total raise.
    ],
    resolution: (
      comment: "We will take the latter approach; If we raise 10,000,000 ADA, having to cover up to 38,700 ADA in minUTXO costs is an acceptable risk for us.",
    )
  ),
  (
    title: [Funds could get deadlocked if the recipient is a script],
    severity: "Minor",
    description: [
      If users construct their own transaction to participate in the sale, and direct the funds to a script address, they may become permanently locked.

      First, the ADA could never be reclaimed, because the contracts explicitly expect VerificationKeyCredentials.
      Second, we enforce that the output when minting the butane has NoDatum. A script address with NoDatum on the UTXO cannot be spent.

      We don't expect users to build their own transactions given the short time window when this will be active, but if these scripts are reused, this could be more of a concern.
    ],
    recommendation: [
      One approach is to split the `Destination` and the `Owner` into two separate fields. The destination is an address and a datum, and the owner is a condition authorized to reclaim the ADA after some time.

      A simpler approach is just to enforce that the `recipient` is a VerificationKeyCredential during the initial deposit.
    ],
    resolution: (
      commit: "580bba7c85603cd87f6b1e037d30915ca0cf543f"
    )
  )
))
