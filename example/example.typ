#import "../template/audit.typ": *

#show: report.with(
  client: "Example",
  title: "Example audit report",
  repo: "https://github.com/SundaeSwap-finance/sundae-audits",
  date: "2023-01-15",
  authors: (
    (
      name: "Pi Lanningham",
      display: text(1.3em, $pi$) + " Lanningham",
    ),
  ),
  about: [
    Example Labs is a fake company used for this template report.
  ],
  disclaimer: [
    This is an example, what do you need disclaimed?
  ],
  links: [
    #link("https://google.com", "Google")
  ]
)

= Audit Manifest

Please find below the list of pinned software dependencies and files that were covered by the audit.

#software_versions(
  items: (
    (
      name: "Staking Contracts",
      version: "0.0.0",
      commit: "7122206784b1ea36214393e7775aadc96928a141",
    ),
  )
)

#files_audited(
  items: (
    (
      file: "validators/a.ak",
      hash: "9916fb18fb1e6c3015270a17841acd5a8e4414e760c910bbe7e7a0fd72ed2fd3",
    ),
    (
      file: "validators/b.ak",
      hash: "d14562ce6a6e190cd3074304457a2d76e3a26e3ac059bfa0918748d0d0299db8",
    ),
    (
      file: "validators/c.ak",
      hash: "9311884bc97ce154eacb7c25b06f118169d058fe57862da1d3ea6e46d33a7baf",
    ),
    (
      file: "validators/d.ak",
      hash: "e5d7a0ebd84f7905076e0dbc2b60d6bec5de7559fdcf792aeacb4c638bd33a19",
    ),
    (
      file: "lib/.../e.ak",
      hash: "099cf3ffd3b468455d6dcbace6dec6c3386f53d23f07aa35c4090bda4acf4d50",
    ),
    (
      file: "lib/.../f.ak",
      hash: "5af9ebd593cbbcbf087a00bc9f9a8daad2d47014bdca0cfc3c80e858bcac3c02",
    ),
  )
)

#parameters(
  (
    (
      name: "delay",
      value: "1500",
    ),
  )
)

#artifacts(
  (
    (
      name: "abc",
      type: "minting",
      hash: "41429696a31fccad078830c182fec39d0df34ec5526df3420fdb4ac132f81843",
    ),
  )
)

#pagebreak()

= Specification

This is a protocol that seeks to do a thing.

#pagebreak()

== Detailed Specification

=== Definitions

#defn("A thing",
  [A thing, that references another #ref("Other thing")]
)
#defn("Other thing", 
  [Another thing, referred to by #ref("A thing")],
)

#pagebreak()

=== Requirements

+ The protocol must do a thing.
  + It must do it well.
  + It must do it fast.

#transaction(
  "Some Transaction",
  inputs: (
    (
      name: "Sample UTXO",
      address: "Pool Contract",
      value: (
        ada: 10,
      ),
      datum: (
        a: 123,
        b: "xyz",
      )
    ),
    (
      name: "Other UTXO",
      value: (
        ada: 1,
        "Access NFT": 1,
      ),
      datum: (
        a: 123,
        b: "xyz",
      )
    ),
    (
      name: "Third UTXO",
      address: "Order Contract",
      value: (
        ada: "N",
        INDY: "M",
        LQ: "P"
      ),
      datum: (
        a: 123,
        b: "xyz",
      )
    ),
    (
      name: "Fourth UTXO",
      reference: true,
      value: (
        ada: 1000000,
      ),
      datum: (
        a: 123,
        b: "xyz",
        c: 123,
      )
    ),

    (
      name: "Fifth UTXO",
      reference: true,
      value: (
        ada: 1000000,
        WMT: "X"
      ),
      datum: (
        a: 123,
        b: "xyz",
        c: 123,
        d: "xyz"
      )
    ),
  ),
  outputs: (
    (
      name: "Output UTXO",
      address: "Pool Contract",
      value: (
        ada: 2000010,
        "Access NFT": 1,
      ),
      datum: (
        a: 123,
        b: "xyz",
      )
    ),
    (
      name: "Other Output",
      address: "Order Contract",
      value: (
        ada: "N",
        INDY: "M",
        LQ: "P",
      ),
      datum: (
        a: 123,
        b: "xyz",
      )
    ),
    (
      name: "Third Output",
      address: "Order Contract",
      value: (
        ada: 1,
        WMT: "X"
      ),
      datum: (
        a: 123,
        b: "xyz",
      )
    ),
  ),
  signatures: (
    "User A",
    "User B",
  ),
  certificates: (
    "Withdraw Stake A",
  ),
  notes: [ABC! tada!]
)

= Findings Summary

#findings(prefix: "EX", items: (
  (
    title: [Some Minor Inconvenience],
    severity: "Minor",
    category: "Incentives",
    description: [
      This is a small issue.
    ],
    recommendation: [
      Maybe fix #ref("Other thing")
    ],
    resolution: (
      comment: "This isn't actually an issue"
    )
  ),
  (
    title: [Major issue],
    severity: "Major",
    category: "Access",
    description: [
      Some major issue with a the protocol.
    ],
    recommendation: [
      Fix it.
    ],
  ),
))