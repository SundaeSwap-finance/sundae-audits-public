// severity colors
#let severity_colors = (
  Critical: rgb("#6E0B05"),
  Major: rgb("#EC4460"),
  Minor: rgb("#F7797D"),
  Info: rgb("#CCDAD1"),
  Witness: rgb("#9EE493"),
)
#let severity_text_colors = (
  Critical: rgb("#FFFFFF"),
  Major: rgb("#FFFFFF"),
  Minor: rgb("#FFFFFF"),
  Info: rgb("#000000"),
  Witness: rgb("#000000"),
)

// status colors
#let status_colors = (
  Resolved: rgb("#00CE60"),
  Mitigated: rgb("#FC9F5B"),
  Acknowledged: rgb("#890620"),
  Identified: rgb("#77479F"),
)
#let status_text_colors = (
  Resolved: rgb("#000000"),
  Mitigated: rgb("#000000"),
  Acknowledged: rgb("#FFFFFF"),
  Identified: rgb("#FFFFFF"),
)

// other colors
#let table_header = rgb("#E5E5E5")

// table cells
#let cell = rect.with(
    inset: 10pt,
    fill: rgb("#F2F2F2"),
    width: 100%,
    height: 50pt,
    radius: 2pt
)

#let tx_link(url, content) = {
  link(url, underline(text(fill: rgb("#007bff"), content)))
} 

// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let report(
  client: "",
  title: "",
  authors: (),
  date: none,
  repo: "",
  body,
  disclaimer: [],
  about: [],
  links: [],
) = {
  // Set the document's basic properties.
  let title = client + " - " + title
  set document(author: authors.map(a => a.name), title: title)
  set text(font: "Linux Libertine", lang: "en")
  set heading(numbering: "1.a.i -")
  set underline(offset: 0.3em)
  show link: underline

  // Title page.
  // The page can contain a logo if you pass one with `logo: "logo.png"`.
  set page(fill: gradient.linear(rgb("#aa00de"), rgb("#0a93ec"), dir: ttb))

  text(1.1em, date, fill: white)
  v(1.2em, weak: true)
  text(2em, weight: 700, title, fill: white)

  v(9.6fr)
  align(right, image("img/sundae.svg", width: 50%))
  v(0.6fr)

  // Author information.
  if authors.len() > 0 {
    set text(1.3em, fill: white)
    pad(
      top: 0.7em,
      right: 20%,
      grid(
        columns: (1fr,) * calc.min(3, authors.len()),
        gutter: 1em,
        ..authors.map(author => align(start, strong(author.display))),
      ),
    )
  }

  v(2.4fr)
  pagebreak()
  set page(numbering: "1", number-align: center, fill: none)

  // Table of contents.
  outline(depth: 2, indent: true, )
  pagebreak()

  // Main body.
  set par(justify: true)

  body
  
  [
    = Appendix

    #v(1em)

    == Disclaimer

    #v(1em)
    #disclaimer

    #pagebreak()
    
    == Issue Guide

    === Severity
    #v(1em)
    
    #grid(
      columns: (20%, 80%),
      gutter: 1pt, 
      cell(fill: table_header, height: auto)[
        #set align(horizon + center)
        *Severity*
      ],
      cell(fill: table_header, height: auto)[
        #set align(horizon + center)
        *Description*
      ],
      cell(fill: severity_colors.Critical)[
        #set align(horizon + center)
        #set text(fill: severity_text_colors.Critical)
        Critical
      ],
      cell()[
        #set align(horizon)
        Critical issues highlight exploits, bugs, loss of funds, or other vulnerabilities
        that prevent the dApp from working as intended. These issues have no workaround.
      ],
      cell(fill: severity_colors.Major, height: 5.1em)[
        #set align(horizon + center)
        #set text(fill: severity_text_colors.Major)
        Major
      ],
      cell(height: 5.1em)[
        #set align(horizon)
        Major issues highlight exploits, bugs, or other vulnerabilities that cause unexpected
        transaction failures or may be used to trick general users of the dApp. dApps with Major issues
        may still be functional.
        
      ],
      cell(fill: severity_colors.Minor)[
        #set align(horizon + center)
        #set text(fill: severity_text_colors.Minor)
        Minor
      ],
      cell()[
        #set align(horizon)
        Minor issues highlight edge cases where a user can purposefully use the dApp
        in a non-incentivized way and often lead to a disadvantage for the user.
      ],
      cell(fill: severity_colors.Info, height: 6.4em)[
        #set align(horizon + center)
        #set text(fill: severity_text_colors.Info)
        Info
      ],
      cell(height: 6.4em)[
        #set align(horizon)
        Info are not issues. These are just pieces of information that are beneficial to the dApp creator, or should be kept in mind for the off-chain code or end user. These are not necessarily acted on or have a resolution, they are logged for the completeness of the audit. 
      ],
      cell(fill: severity_colors.Witness, height: 6.4em)[
        #set align(horizon + center)
        #set text(fill: severity_text_colors.Witness)
        Witness
      ],
      cell(height: 6.4em)[
        #set align(horizon)
        Witness findings are affirmative findings, which covers bizarre corner cases we considered and found to be safe. Not all such cases are covered, but when something is considered interesting, or might be a common question, we try to include it.
      ],
    )

    #v(1em)
    
    === Status
    #v(1em)

    #grid(
      columns: (20%, 80%),
      gutter: 1pt, 
      cell(fill: table_header, height: auto)[
        #set align(horizon + center)
        *Status*
      ],
      cell(fill: table_header, height: auto)[
        #set align(horizon + center)
        *Description*
      ],
      
      cell(fill: status_colors.Resolved)[
        #set align(horizon + center)
        #set text(fill: status_text_colors.Resolved)
        Resolved
      ],
      cell()[
        #set align(horizon)
        Issues that have been *fixed* by the *project* team.
      ],
      cell(fill: status_colors.Mitigated)[
        #set align(horizon + center)
        #set text(fill: status_text_colors.Resolved)
        Mitigated
      ],
      cell()[
        #set align(horizon)
        Issues that have a *partial mitigation*, and are now vulnerable in only *extreme* corner cases.
      ],
      cell(fill: status_colors.Acknowledged)[
        #set align(horizon + center)
        #set text(fill: status_text_colors.Acknowledged)
        Acknowledged
      ],
      cell()[
        #set align(horizon)
        Issues that have been *acknowledged* or *partially fixed* by the *project* team. Projects
        can decide to not *fix* issues for whatever reason.
      ],
      cell(fill: status_colors.Identified)[
        #set align(horizon + center)
        #set text(fill: status_text_colors.Identified)
        Identified 
      ],
      cell()[
        #set align(horizon)
        Issues that have been *identified* by the *audit* team. These
        are waiting for a response from the *project* team.
      ],
    )

    #pagebreak()
    
    == Revisions
    #v(1em)
    
    This report was created using a git based workflow. All changes are tracked in a github repo and the report is produced
    using #tx_link("https://typst.app")[typst]. The report source is available #tx_link(repo)[here]. All versions with downloadable PDFs can be found on the #tx_link(repo + "/releases")[releases page].

    #v(1em)
    
    == About Us
    #v(1em)

    #about
    
    #v(1em)

    === Links

    #v(1em)

    #links
    
  ]
}

#let software_versions(items: ()) = {
    grid(
        columns: (2fr, 1fr, 4fr),
        gutter: 1pt,
        cell(fill: rgb("#E5E5E5"), height: 2.4em)[*Software*],
        cell(fill: rgb("#E5E5E5"), height: 2.4em)[*Version*],
        cell(fill: rgb("#E5E5E5"), height: 2.4em)[*Commit*],
        ..items.map(
            row => (
              cell(height: 2.4em)[*#row.name*],
              cell(height: 2.4em)[*#row.version*],
              cell(height: 2.4em)[*#row.commit*],
            )
        ).flatten()
    )
}

#let files_audited(items: ()) = {
    grid(
        columns: (1fr, 1.3fr),
        gutter: 1pt,
        cell(fill: rgb("#E5E5E5"), height: 2.4em)[*Filename*],
        cell(fill: rgb("#E5E5E5"), height: 2.4em)[*Hash (SHA256)*],
        ..items.map(
            row => (
              cell(height: 3.4em)[
                #align(horizon, text(0.8em, row.file))
              ],
              cell(height: 3.4em)[
                #align(horizon, text(0.7em, raw(row.hash)))
              ],
            )
        ).flatten()
    )
}

#let parameters(
  parameters,
  column_sizes: (1fr, 1fr)
) = {
  grid(
    columns: column_sizes,
    gutter: 1pt,
    cell(fill: rgb("#E5E5E5"), height: 2.4em)[*Parameter*],
    cell(fill: rgb("#E5E5E5"), height: 2.4em)[*Value*],
    ..parameters.map(
        row => (
          cell(height: 2.4em)[#text(0.8em, raw(row.name))],
          cell(height: 2.4em)[#text(0.7em, raw(row.value))],
        )
    ).flatten()
  )
}

#let artifacts(
  artifacts,
  column_sizes: (1fr, 1fr, 3fr)
) = {
  grid(
      columns: column_sizes,
      gutter: 1pt,
      cell(fill: rgb("#E5E5E5"), height: 2.4em)[*Name*],
      cell(fill: rgb("#E5E5E5"), height: 2.4em)[*Type*],
      cell(fill: rgb("#E5E5E5"), height: 2.4em)[*Hash (Blake2b-224)*],
      ..artifacts.map(
          row => (
            cell(height: 2.4em)[#text(0.8em, row.name)],
            cell(height: 2.4em)[#text(0.8em, row.type)],
            cell(height: 2.4em)[#text(0.7em, raw(row.hash))],
          )
      ).flatten()
  )
}

#let tx_out_height_estimate(input) = {
  let address = if "address" in input { 1 } else { 0 }
  let value = if "value" in input { input.value.len() } else { 0 }
  let datum = if "datum" in input { input.datum.len() } else { 0 }
  return (address + value + datum) * 8pt
}

#let datum_field(indent, k, val) = [
  #if val == "" [
    #h(indent)\+ #raw(k)
  ] else [
    #h(indent)\+ #raw(k):
    #if type(val) == content { val }
    #if type(val) == str and val != "" {repr(val)}
    #if type(val) == int {repr(val)}
    #if type(val) == array [
      #stack(dir: ttb, spacing: 0.4em,
        for item in val [
          #datum_field(indent + 1.2em, "", item) \
        ]
      )
    ]
    #if type(val) == dictionary [
      #v(-0.7em)
      #stack(dir: ttb, spacing: 0em,
        for (k, v) in val.pairs() [
          #datum_field(indent + 1.2em, k, v) \
        ]
      )
    ]
  ]
]

#let tx_out(input, position, inputHeight, styles) = {
  let address = if "address" in input [
    *Address: #h(0.5em) #input.address*
  ] else []
  let value = if "value" in input [
    *Value:* #if ("ada" in input.value) [ *#input.value.ada* ADA ] \
    #v(-1.0em)
    #stack(dir: ttb, spacing: 0.4em,
      ..input.value.pairs().map(((k, v)) => [
        #if k != "ada" {
          [#h(2.3em) \+ *#v* #raw(k)]
        }
      ])
    )
  ] else []
  let datum = if "datum" in input [
    *Datum:* \ 
    #v(-0.8em)
    #stack(dir: ttb, spacing: 0.4em,
      ..input.datum.pairs().map(((k,val)) => datum_field(1.2em, k, val))
    )
  ] else []
  let addressHeight = measure(address, styles).height + if "address" in input { 6pt } else { 0pt }
  let valueHeight = measure(value, styles).height + if "value" in input { 6pt } else { 0pt }
  let datumHeight = measure(datum, styles).height + if "datum" in input { 6pt } else { 0pt }
  let thisHeight = 32pt + addressHeight + valueHeight + datumHeight
  return (
    content: place(dx: position.x, dy: position.y, [
      *#input.name*
      #line(start: (-4em, -1em), end: (10em, -1em))
      #place(dx: 10em, dy: -1.5em)[#circle(radius: 0.5em, fill: white, stroke: black)]
      #if "address" in input { place(dx: 0em, dy: -3pt)[#address] }
      #place(dx: 0em, dy: addressHeight)[#value]
      #if "datum" in input { place(dx: 0em, dy: addressHeight + valueHeight)[#datum] }
    ]),
    height: thisHeight,
  )
}

#let collapse_values(existing, v, one) = {
  if type(v) == int {
    existing.qty += one * v
  } else {
    let parts = v.matches(regex("([ ]*([+-]?)[ ]*([0-9]*)[ ]*([a-zA-Z]*)[ ]*)"))
    for part in parts {
      let sign = part.captures.at(1)
      let qty = int(if part.captures.at(2) == "" { 1 } else { part.captures.at(2) })
      let var = part.captures.at(3)
      let existing_var = existing.variables.at(var, default: 0)
      if var == "" {
        existing.qty += one * qty
      } else {
        if sign == "-" {
          existing.variables.insert(var, existing_var - one * qty)
        } else {
          existing.variables.insert(var, existing_var + one * qty)
        }
      }
    }
  }
  existing
}

#let transaction(name, inputs: (), outputs: (), signatures: (), certificates: (), validRange: none, notes: none) = style(styles => {
  let inputHeightEstimate = inputs.fold(0pt, (sum, input) => sum + tx_out_height_estimate(input))
  let inputHeight = 0em
  let mint = (:)
  let inputs = [
      #let start = (x: -18em, y: 1em)
      #for input in inputs {
        // Track how much is on the inputs
        if "value" in input {
          for (k, v) in input.value {
            let existing = mint.at(k, default: (qty: 0, variables: (:)))
            let updated = collapse_values(existing, v, -1)
            mint.insert(k, updated)
          }
        }

        let tx_out = tx_out(input, start, inputHeight, styles)

        tx_out.content

        // Now connect this output to the transaction
        place(dx: start.x + 10.5em, dy: start.y + 0.84em)[
          #path(
            stroke: if input.at("reference", default: false) { blue } else { black },
            ((0em, 0em), (0em, 0em), (8em, 0em)),
            ((7.44em, (inputHeightEstimate / 1.25) - (inputHeight / 1.25)), (-4em, 0em))
          )
        ]
        place(dx: start.x + 10.26em, dy: start.y + 0.59em)[#circle(radius: 0.25em, fill: black)]

        start = (x: start.x, y: start.y + tx_out.height)
        inputHeight += tx_out.height
      }
    ]
  
  let outputHeightEstimate = outputs.fold(0pt, (sum, output) => sum + tx_out_height_estimate(output))
  let outputHeight = 0em
  let outputs = [
      #let start = (x: 4em, y: 1em)
      #for output in outputs {
        // Anything that leaves on the outputs isn't minted/burned!
        if "value" in output {
          for (k, v) in output.value {
            let existing = mint.at(k, default: (qty: 0, variables: (:)))
            let updated = collapse_values(existing, v, 1)
            mint.insert(k, updated)
          }
        }

        let tx_out = tx_out(output, start, outputHeight, styles)
        tx_out.content
        start = (x: start.x, y: start.y + tx_out.height)
        outputHeight += tx_out.height
      }
    ]

  // Collapse down the `mint` array
  let display_mint = (:)
  for (k, v) in mint {
    let has_variables = v.variables.len() > 0 and v.variables.values().any(v => v != 0)
    if v.qty == 0 and not has_variables {
      continue
    }
    let display = []
    if v.qty != 0 {
      display = if v.qty > 0 { [\+] } + [#v.qty]
    }
    let vs = v.variables.pairs().sorted(key: ((k,v)) => -v)
    if vs.len() > 0 {
      for (k, v) in vs {
        if v == 0 {
          continue
        } else if v > 0 {
          display += [ \+ ]
        } else if v < 0 {
          display += [ \- ]
        }
        if v > 1 or v < -1 {
          display += [#calc.abs(v)]
        }
        display += [*#k*]
      }
    }
    display += [ *#raw(k)*]
    display_mint.insert(k, display)
  }

  let mints = if display_mint.len() > 0 [
    *Mint:* \
    #for (k, v) in display_mint [
      #v \
    ]
  ] else [#v(-1em)]
  let signatures = if signatures.len() > 0 [
    *Signatures:* \
    #for signature in signatures [
      - #signature
    ]
  ] else [#v(-1em)]
  let certificates = if certificates.len() > 0 [
    *Certificates:*
    #for certificate in certificates [
      - #certificate
    ]
  ] else [#v(-1em)]
  let valid_range = if validRange != none [
    *Valid Range:* \
    #if "lower" in validRange [#validRange.lower $<=$ ]
    `slot`
    #if "upper" in validRange [$<=$ #validRange.upper]
  ] else [#v(-1em)]
  let transaction = [
      #set align(center)
      #rect(
        radius: 4pt,
        height: calc.max(100pt, inputHeight + 16pt, outputHeight + 16pt),
        [
          #pad(top: 1em, name)
          #v(1em)
          #set align(left)
          #stack(dir: ttb, spacing: 1em,
            mints,
            signatures,
            certificates,
            valid_range,
          )
        ]
      )
    ]

  let diagram = stack(dir: ltr,
    inputs,
    transaction,    
    outputs
  )
  let size = measure(diagram, styles)
  block(width: 100%, height: size.height)[
    #set align(center)
    #diagram
    #if notes != none [ *Note*: #notes ]
  ]
})


// Utilities

#let anchor(title) = label("anchor_" + title)

#let defn(title, ..definition) = block(
  spacing: 11.5pt,
  inset: 8pt,
  radius: 4pt,
  {
    [
      - #underline[#strong[#title]] #anchor(title)
        #list(tight: false, spacing: 1em, ..definition.pos().map(d => d))
    ]
  }
)

#let ref(title, display: "") = link(anchor(title))[
  #underline[#strong[
    #if display == "" {
      title
    } else {
      display
    }
  ]]
]

#let titles = ("ID", "Title", "Severity", "Status")

#let finding_titles = ("Category", "Commit", "Severity", "Status")

#let findings(prefix: "XX", items: ()) = {
  let severity_num = (
    Critical: "0",
    Major: "1",
    Minor: "2",
    Info: "3",
    Witness: "4",
  )
  let counters = (
    Critical: 0,
    Major: 0,
    Minor: 0,
    Info: 0,
    Witness: 0,
  )

  findings = ()
  for finding in items {
    let resolution = finding.at("resolution", default: (:))
    let status = if resolution == (:) {
      "Identified"
    } else if finding.resolution.at("commit", default: "") != "" {
      "Resolved"
    } else if finding.resolution.at("comment", default: "") != "" {
      "Acknowledged"
    }
    let idx = "00" + str(counters.at(finding.severity))
    let id = prefix + "-" + severity_num.at(finding.severity) + idx.slice(-2)

    finding.insert("status", status)
    finding.insert("id", id)
    counters.insert(finding.severity, counters.at(finding.severity) + 1)

    findings.push(finding)
  }

  findings = findings.sorted(key: row => severity_num.at(row.severity))

  grid(
    columns: (1fr, 46%, 1fr, 1.2fr),
    gutter: 1pt,
    ..titles.map(t => cell(fill: table_header, height: auto)[
      #set align(horizon + center)
      *#t* 
    ]),
    ..findings
      .map(
        row => {
          (
            cell()[
              #set align(horizon + center)
              #ref(row.id)
            ],
            cell()[
              #set align(horizon)
              #row.title
            ],
            cell(
              fill: severity_colors.at(row.severity)
            )[
              #set align(horizon + center)
              #set text(fill: severity_text_colors.at(row.severity))
              #row.severity
            ],
            cell(
              fill: status_colors.at(row.status)
            )[
              #set align(horizon + center)
              #set text(fill: status_text_colors.at(row.status))
              #row.status
            ]
          )
        }
      )
      .flatten()
  )

  pagebreak()

  set heading(numbering: none)
  for finding in findings {
    [
      == #finding.id - #finding.title
      #anchor(finding.id)
      #v(1em)

      #grid(
        columns: (1fr, 40%, 0.8fr, 0.8fr),
        gutter: 1pt,
        ..finding_titles.map(t => cell(fill: rgb("#E5E5E5"), height: auto)[
          #set align(horizon + center)
          *#t*
        ]),
        cell(height: auto)[
          #set align(horizon + center)
          #finding.at("category", default: "None")
        ],
        cell(height: auto)[
          #set align(horizon + center)
          #finding.at("resolution", default: (commit: " ")).at("commit", default: " ")
        ],
        cell(
          height: auto,
          fill: severity_colors.at(finding.severity)
        )[
          #set align(horizon + center)
          #set text(fill: severity_text_colors.at(finding.severity))
          #finding.severity
        ],
        cell(
          height: auto,
          fill: status_colors.at(finding.status)
        )[
          #set align(horizon + center)
          #set text(fill: status_text_colors.at(finding.status))
          #finding.status
        ]
      )

      #v(1em)

      === Description

      #v(1em)

      #finding.description

      #if finding.at("recommendation", default: none) != none [
        #v(1em)

        === Recommendation

        #v(1em)

        #finding.recommendation
      ]

      #if finding.at("resolution", default: none) != none [
        #v(1em)

        === Resolution

        #v(1em)

        #let status = finding.at("status", default: none)
        #if status == "Resolved" {
          "This issue was resolved as of commit " + raw(finding.resolution.commit) + "."
        } else if status == "Acknowledged" {
          "This issue was acknowledge by the project team with the comment: " + finding.resolution.comment + "."
        } else {
          "This issue is still open and has not been resolved."
        }
      ]
    ]

    pagebreak()
  }
}
