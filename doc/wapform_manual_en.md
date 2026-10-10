# WapForm Complete Technical Manual

---

WapForm is a declarative XML framework for enterprise applications: a single `.wml` file drives the database, renders the interface, and produces reports, generating a Windows desktop application, a web page, or a Flutter app directly at runtime, and can also export COBOL programs, extending into IC electronic design automation (EDA) and a local AI Agent, Cherith. No boilerplate code, no framework churn, no rewriting when you switch platforms — this design pattern has been proven in production for over twenty years across manufacturing ERP, financial systems, and e-commerce platforms.

**WapForm's core proposition is singular: describe "what," not "how."** Developers declare datasets, bind fields, define events and output formats in XML, and the framework drives the database, renders the interface, and handles pagination and totals. The same `.wml` file can simultaneously be an input form and a paginated report, with no language switching and no bridging between the UI framework and the data layer. The power of the declarative approach: when business rules change, you only modify the description — the framework derives the rest.

### Four Core Advantages

**Fast, and then faster still** — In an official case study, a multi-level nested production report (multi-dimensional grouping, with automatic pagination) was estimated to take months to develop with traditional imperative code; with WapForm it was built and shipped within days, with the code collapsing from thousands of lines of cross-file logic into a WML declaration of a few hundred lines. It isn't that there are fewer problems — it's that changes are fast enough that testing stops being something to dread.

**Fast across platforms, fast across domains** — Master the declarative syntax once, and the same mental model covers Windows desktop, server-side Web, Flutter mobile, and even IC electronic design automation (EDA) and COBOL mainframes. WapForm isn't a tool for one platform — it's a **development design pattern** that can cross any domain.

**An innovative report-templating mechanism** — A built-in trigger-based template system where HTML templates own the layout, code only declares content blocks, and report-application logic is completely separated from the main program, giving an intuitive, fluid development experience.

**Rock solid** — A modular architecture paired with rigorous data-logic validation ensures the stability and extensibility of enterprise-grade applications, proven over twenty years in real manufacturing ERP, e-commerce, and financial systems.

### What WapForm Really Is: Define Once, Deploy Many Times

Data sources, fields, lookups, events, forms, and reports are all described in WML — not bound directly to Dart, Flutter, or any other specific language. Therefore:

> **WapForm is the Source of Truth for the application.**

The generator expands this definition into target-platform code, while the runtime and component library provide the "landing layer" where the program actually runs.

### The Value of AI Isn't Free-Form Code Generation

Simply handing the source code of an existing desktop database component library to an LLM and asking it to translate one file after another into Dart may produce a large amount of code, but that does not mean it can reliably port a large system.

What's genuinely difficult is behavioral consistency, API mapping, the data model, the event model, and long-term maintenance.

WapForm takes a different approach:

**WML Definition → Generator → Stable Runtime/API → Target Code**

The AI isn't asked to freely "write an app" — it performs large-scale, mechanical, repeatable code expansion against an already clearly defined WML and a stable target API.

This port of WapForm for Flutter was completed with about two months of AI-assisted development; compared with an estimated six to twelve months for an equivalent manual port, the real difference isn't just that AI writes code faster, but:

> **Establish the definition first, then let AI generate from that definition.**

So Flutter's two months isn't simply a demonstration of AI development speed — it's a real-world validation of this "define → generate → runtime → execute" engineering pattern.

### Taking Flutter as an Example: Not a Component Port, but the First Validation of the Application Definition

Cross-platform support was never the biggest cost — what's truly expensive is having to redevelop from scratch every time you switch platforms.

Even after the desktop data-aware components are fully ported to Flutter — with familiar datasets, grids, navigator bars, fields and an event model — developers still have to build screens in Dart, bind data, and write events and business logic. In essence, they are still rewriting a whole program on another platform.

What WapForm solves isn't components — it's how the application itself is defined.

WML is a plain-text, declarative application definition language. Data sources, fields, lookups, events, forms, and reports are all defined by "description," not bound to Dart, Flutter, or any specific platform. So the real development flow becomes:

> **Define once, deploy many times.**

WML is the single application definition; the generator expands it into target-platform code; the runtime provides the components and behavioral model the program needs to actually run. Take Flutter as an example: the `wapform_flutter` repository is Flutter's runtime — not another Flutter UI framework, but the implementation of WapForm's dataset, expression and report models on Flutter. Every line of Dart the WapForm generator produces targets this API, so the same WML that originally ran on Windows can be deployed to Flutter without changing the definition. That's why "write ten lines of WML, get a working Flutter screen" — because what's actually being reused isn't code, it's the definition of the application itself (see Chapter 16 for details).

### Taking the Web as an Example: Triggered Templates, Layout and Logic Fully Separated

Traditional PHP/ASP writes conditions directly inside the HTML, so the program knows too much about the layout: changing one block means changing code, designers cannot change the layout on their own, and as the system grows, maintenance costs explode.

The core of WapForm for Web is **triggered templates**: the program does not write HTML; it only declares "under what condition, trigger which layout block". All HTML lives in the template file, marked as named blocks with `<!-- name.aa -->` / `<!-- name.zz -->`.

```xml
<card id="main" device="wapform.html">          <!-- device names the template file -->
  <setvar name="op" value="request.op"/>
  <block name="wapform.aa"/>                     <!-- trigger: output the frame's opening -->
  <include name="header"/>                       <!-- shared header, one copy for the whole site -->
  <block name="onpage" cnd="op='page'"/>         <!-- trigger different layouts by condition -->
  <block name="onblog" cnd="op='blog'"/>
  <include name="footer"/>
  <block name="wapform.zz"/>                     <!-- trigger: output the frame's closing -->
</card>
```

```html
<!-- onpage.aa -->
#(breadcrumb)                                     <!-- run the breadcrumb sub-card in place -->
<div class="content">#(content)</div>             <!-- run the content sub-card in place -->
<!-- onpage.zz -->
```

Key points of triggered templates:

- **Conditions trigger layouts**: only blocks whose `cnd` holds are output, so layouts switch automatically without if/else; one set of conditions can drive several output blocks.
- **`aa`/`zz` pairs open and close containers**: frames and components become reusable building blocks that nest; maintenance means editing the template, not the main program.
- **`#(card)` injects a sub-card**: when the flow reaches `#(content)`, the `content` sub-card runs as a complete module and its output fills that spot — its own queries, row-by-row output and grouping all happen as usual. The shell stays, the content changes, and every page that uses the same shell is updated together.
- **Blocks can carry parameters and state**: `<block name="row.aa" alg="'align-items-center'"/>` passes a value into the template's `$alg`; `var()`/`inc()` make sequence numbers and alternating colors across blocks predictable.
- **Versus writing HTML directly in CDATA**: hard-coding HTML in place with CDATA means assembling "shell + content" yourself; paging, layout changes and template reuse are not brought in automatically, and as pages and layouts multiply, maintenance costs climb fast.

The result: **designers edit templates without touching logic, engineers edit WML without touching layout**; the header, footer and menu are defined once with `<include>` and the whole site updates together; the output is standard HTML, so Bootstrap, Tailwind or your own CSS apply directly. Swap the template file and the same mechanism turns a web page into an API — `device="api.htm"` outputs only what the `.wml` itself produces, used to answer webhooks such as a LINE Bot with JSON. See Chapter 9, The Web Template System, and Chapter 15 for the full story.

### Taking COBOL as an Example: Not a Language Converter, and Not Starting From Zero

Many AI tools today emphasize converting COBOL into Java, C#, or other modern languages. But:

> **Successfully converting the code doesn't mean the system has been migrated.**

What's genuinely complex about COBOL enterprise systems is often the data structures, transaction flows, field semantics, batch jobs, reports, exception handling, and the behavior shaped by the original runtime — all accumulated over many years. So a simple **COBOL → Java** conversion easily turns into **COBOL → AI → Java → Compile → Debug → Test → revise again** — even once it finally compiles, extensive cross-platform debugging and verification may still be needed to confirm the converted system truly behaves the same as the original.

WapForm takes a different direction: it doesn't treat "source code" as the only source of truth — instead it lifts the application up to WML, a platform-independent definition layer. The future **WapForm for COBOL** won't just be "generate COBOL" — the application logic, data, fields, flows, events, and reports of an existing COBOL system can also be converted *into* WML (**existing COBOL → WapForm for COBOL → WML**), and this entry point isn't one-way: the same WML can also be deployed back to COBOL itself (**COBOL → WapForm for COBOL → WML → COBOL**), making WapForm for COBOL not just "an exit ramp for retiring legacy systems," but also "a regeneration and verification tool for the legacy system itself" — confirming the converted behavior matches the original, or producing a cleaner version aligned with the current runtime. Once inside WML, the application is no longer tied to COBOL itself — the same definition can then be deployed through the already-established Flutter generator and runtime: **existing COBOL → WML → Flutter**, without having to redo **COBOL → Flutter** from scratch every time. If WML already fully describes the original application, generating Flutter from WML in principle requires no re-understanding of COBOL and no large-scale cross-language translation redone from zero — only the necessary adjustments for the handful of platform differences. That's what really matters about WML as an intermediate definition layer.

**WapForm for COBOL doesn't exist yet** — but Flutter has already completed the first validation of the full engineering chain of **Definition → Generator → Runtime → Target Code**, so when the runtime, component model, and generator needed for COBOL are eventually built, WapForm doesn't need to be reinvented from scratch. Given favorable conditions, subsequent platforms might even be completed on a cycle as short as or shorter than Flutter's, because the most important methods, architecture, and generation process already exist:

> **The first platform has already established and validated the hardest engineering method — subsequent platforms can build on this foundation to land.**

So, going forward, this may take shape:

**COBOL → WML → COBOL**

**COBOL → WML → Flutter**

as well as:

**WML → other platforms: MicroPython, Node.js**

**WML → other domains: AI, EDA**

Different platforms and different domains no longer each need to redefine the same application from scratch.

### What Is WapForm Really Trying to Build?

So, WapForm's core isn't:

**WapForm for Flutter**

nor is it:

**WapForm for COBOL**

but a higher-level architecture:

> **Let the application be defined first, then realized by different platforms.**

WML is the center. AI is the accelerator. The runtime is the landing layer. The platform is only the final form of realization.

This is also the biggest difference between WapForm and general-purpose AI code-conversion tools:

**AI Code Conversion**

`Source Code → AI → Another Source Code`

**WapForm**

`Application Definition → Target Runtime → Target Code`

The former moves code between languages; the latter frees the application definition itself from the platform.

WapForm for Flutter isn't just a Flutter port — it's the first complete proof of concept for WapForm's cross-platform architecture.

And WapForm for COBOL won't just be the next "language converter" either. It can become the bridge by which an existing COBOL system enters WML, and from there is deployed further to Flutter or other platforms.

**One Definition. Any Platform. Every Domain.**

### Scope of This Book

WapForm currently has two official runtime environments, which are also the main content covered by this book:

**WapForm for Windows** — A traditional desktop MDI application, connecting directly to the database, offering rich UI controls (grids, tabs, print preview).

**WapForm for Web** — A server-side dynamic web engine that parses `.wml` into HTML output. A card's `device` attribute points to an HTML template file (e.g. `"wapform.html"`). It receives HTTP parameters via `request.*`, maintains user state via `session.*`, and its output can be embedded directly into front-end frameworks such as Bootstrap.

Chapter 16 additionally covers **WapForm for Flutter**: how the same WML definition is deployed as a Flutter app through the open-source runtime — a concrete demonstration of "define once, deploy many times" on a third platform.

This book is a concise, example-driven reference manual. It assumes the reader is already familiar with SQL, XML, and the concepts of event-driven applications, but requires no prior experience with WapForm.

### Typographic Conventions Used in This Book

`<element/>` denotes a WML void element; `<element>` denotes a container element. Attribute names are rendered in `monospace`. Required attributes are marked **(required)**; optional attributes are marked **(optional)**. Expression syntax follows WapForm's `$()` interpolation convention.

---

### The WapForm Platform Ecosystem

WapForm is a continuously evolving cross-platform ecosystem:

| Platform | Description | Status |
|---|---|---|
| **WapForm Windows** | Desktop MDI application framework, with grids, pagination, print preview | Stable release |
| **WapForm Web** | Server-side dynamic web engine (IIS ISAPI), layout separated from logic | Stable release |
| **WapForm Flutter** | The same WML exports directly to a cross-platform Flutter app; core focus is on Web, with mobile support being added incrementally | Stable release |
| **WapForm COBOL** | COBOL import → WapForm development → COBOL export, mainframe modernization without rewrites | In development |
| **WapForm EDA** | Converges IC design flows scattered across scripts into a readable, traceable WML pipeline | In development |
| **WapForm AI (Cherith)** | A local AI Agent that requires no pre-training and reasons directly | In development |

---

### WapForm for AI: Cherith

Cherith is WapForm's core initiative for the AI era, built on twenty years of cross-platform, real-world experience, taking a route fundamentally different from LLMs.

LLMs rely on statistical correlations from massive corpora to predict output — they are, at their core, imitators of language. Cherith's premise is: **"language is program," "the world is object-oriented"** — every natural-language sentence can be decomposed into a reasoning-capable logical structure, where nouns map to objects, actions map to methods, conditions become property operations, and the entire semantic scene becomes a programmable, object-oriented world model.

This brings several key differences: no dependence on pre-training, the ability to run on edge devices (at a fraction of a GPU's power draw), reasoning that is explainable and verifiable, and no hallucination. WapForm's tenfold development speed is precisely what makes it feasible to build a system that needs to construct tens of millions of sentence-to-logic mappings.

> *An LLM imitates; Cherith understands. An LLM outputs text; Cherith constructs cognition.*

---

This book covers three complete environments — WapForm for Windows, WapForm for Web, and WapForm for Flutter — based on real project source code, providing complete technical documentation from the mental model, through the language reference, to production-grade real-world practice.

---

## Table of Contents

- [Platform Support Notation](#platform-support-notation)
- [Chapter 1　The WapForm Mental Model](#chapter-1-the-wapform-mental-model)
  - [1.1 Everything Is a Card](#11-everything-is-a-card)
  - [1.2 The Dataset Binding Model](#12-the-dataset-binding-model)
  - [1.3 Flow Mode vs. Output Mode](#13-flow-mode-vs-output-mode)
  - [1.4 The Expression System](#14-the-expression-system)
  - [1.5 The Event Model](#15-the-event-model)
- [Chapter 2　Document Structure](#chapter-2-document-structure)
  - [2.1 WML Documents](#21-wml-documents)
  - [2.2 Card Lifecycle](#22-card-lifecycle)
  - [2.3 Dataset Field Variable Naming Rules](#23-dataset-field-variable-naming-rules)
- [Chapter 3　Core Patterns](#chapter-3-core-patterns)
  - [3.1 Pattern: Single-Table CRUD Form](#31-pattern-single-table-crud-form)
  - [3.2 Pattern: Master-Detail Structure](#32-pattern-master-detail-structure)
  - [3.3 Pattern: Query Input → Report Output](#33-pattern-query-input--report-output)
  - [3.4 Pattern: Lookup with Auto-Fill](#34-pattern-lookup-with-auto-fill)
  - [3.5 Pattern: Multi-Tab Sectioned Form](#35-pattern-multi-tab-sectioned-form)
  - [3.6 Pattern: Background Copy Job](#36-pattern-background-copy-job)
  - [3.7 Pattern: Dynamic WHERE + Multi-Mode Search](#37-pattern-dynamic-where--multi-mode-search)
  - [3.8 Pattern: Web Member Login and Session Management](#38-pattern-web-member-login-and-session-management)
- [Chapter 4　Complete Tag Reference](#chapter-4-complete-tag-reference)
  - [4.1 Document and Layout Tags](#41-document-and-layout-tags)
  - [4.2 Data Access Tags](#42-data-access-tags)
  - [4.3 Data Binding and List Tags](#43-data-binding-and-list-tags)
  - [4.4 Form Input and Interaction Tags](#44-form-input-and-interaction-tags)
  - [4.5 Flow Control Tags](#45-flow-control-tags)
  - [4.6 Variable and Dataset Operation Tags](#46-variable-and-dataset-operation-tags)
  - [4.7 Report Output Tags](#47-report-output-tags)
  - [4.8 Crosstab and Chart Tags](#48-crosstab-and-chart-tags)
  - [4.9 Navigation and Menu Tags](#49-navigation-and-menu-tags)
  - [4.10 System Integration Tags](#410-system-integration-tags)
  - [4.11 Web-Only Tags](#411-web-only-tags)
  - [4.12 HTML Text and Layout Tags](#412-html-text-and-layout-tags)
  - [4.13 Tag Quick Reference](#413-tag-quick-reference)
- [Chapter 5　Arrays](#chapter-5-arrays)
  - [5.1 Declaration](#51-declaration)
  - [5.2 Access](#52-access)
  - [5.3 Array Functions](#53-array-functions)
  - [5.4 The `name()` / `value()` Functions](#54-the-name--value-functions)
  - [5.5 Arrays as Counters (Report Accumulation)](#55-arrays-as-counters-report-accumulation)
  - [5.6 Arrays as Lookup Tables](#56-arrays-as-lookup-tables)
  - [5.7 Arrays as Color Maps](#57-arrays-as-color-maps)
  - [5.8 Array-Style Dataset Access](#58-array-style-dataset-access)
  - [5.9 Limitations and Caveats](#59-limitations-and-caveats)
- [Chapter 6　Expressions and the Function Library](#chapter-6-expressions-and-the-function-library)
  - [6.1 Interpolation Syntax](#61-interpolation-syntax)
  - [6.2 Operators](#62-operators)
- [Chapter 7　Dataset Object Reference](#chapter-7-dataset-object-reference)
  - [7.1 Field Value Access](#71-field-value-access)
  - [7.2 Dataset State Properties](#72-dataset-state-properties)
  - [7.3 The Lookup Prefix (`lup{dataset}`)](#73-the-lookup-prefix-lupdataset)
  - [7.5 Web Environment Objects](#75-web-environment-objects)
  - [7.6 Report Environment Special Variables](#76-report-environment-special-variables)
  - [7.7 Dataset Method Quick Reference](#77-dataset-method-quick-reference)
- [Chapter 8　Windows System Login and Access Control](#chapter-8-windows-system-login-and-access-control)
  - [8.1 The Three-Layer Cooperative Architecture](#81-the-three-layer-cooperative-architecture)
  - [8.2 The Login Dialog](#82-the-login-dialog)
  - [8.3 Authentication](#83-authentication)
  - [8.4 Menu Construction and LoginLevel Settings](#84-menu-construction-and-loginlevel-settings)
  - [8.5 Field-Block Permissions: the `<author>` Tag](#85-field-block-permissions-the-author-tag)
  - [8.6 Worked Example: Order Sign-Off Block](#86-worked-example-order-sign-off-block)
  - [8.7 Complete Data Flow](#87-complete-data-flow)
  - [8.8 Database Design Reference](#88-database-design-reference)
  - [8.9 Design-Point Summary](#89-design-point-summary)
- [Chapter 9　The Web Template System](#chapter-9-the-web-template-system)
  - [9.1 Concept: WML-Driven HTML Templates](#91-concept-wml-driven-html-templates)
  - [9.2 Triggered Blocks](#92-triggered-blocks)
  - [9.3 HTML Template Structure: Block Markers](#93-html-template-structure-block-markers)
  - [9.4 Layout Modes](#94-layout-modes-choosing-block-nameon)
  - [9.5 The notebar Directory Tree: Side Sub Cards in Detail](#95-the-notebar-directory-tree-side-sub-cards-in-detail)
  - [9.6 AJAX On-Demand Loading and the `<wap>` Tag](#96-ajax-on-demand-loading-and-the-wap-tag)
  - [9.7 Three Content-Injection Mechanisms](#97-three-content-injection-mechanisms)
  - [9.8 Two Kinds of HTML Templates](#98-two-kinds-of-html-templates)
  - [9.9 Parameter Passing on `<block>` Calls](#99-parameter-passing-on-block-calls)
  - [9.10 Expressions and State Functions Inside Templates](#910-expressions-and-state-functions-inside-templates)
  - [9.11 Full Correspondence: note.wml ↔ wapform.html](#911-full-correspondence-notewml--wapformhtml)
  - [9.12 Report-Templating Mechanism Summary](#912-report-templating-mechanism-summary)
- [Chapter 10　Charts](#chapter-10-charts)
  - [10.1 Overview](#101-overview)
  - [10.2 Basic Structure](#102-basic-structure)
  - [10.3 `<chart>` — Chart Container Attributes](#103-chart--chart-container-attributes)
  - [10.4 `<serie>` — Series Attributes](#104-serie--series-attributes)
  - [10.5 `<point>` — Data Points](#105-point--data-points)
  - [10.6 Complete Chart-Type List](#106-complete-chart-type-list)
  - [10.7 Chart-Type Quick Reference](#107-chart-type-quick-reference)
  - [10.8 Data Sources: Two Modes](#108-data-sources-two-modes)
  - [10.9 Color-Array Technique](#109-color-array-technique)
  - [10.10 Multiple Charts Side by Side](#1010-multiple-charts-side-by-side-table-layout)
  - [10.11 Platform Differences](#1011-platform-differences)
  - [10.12 Common Patterns at a Glance](#1012-common-patterns-at-a-glance)
- [Chapter 11　Web File Uploads in Practice: upload and multiupload](#chapter-11-web-file-uploads-in-practice-upload-and-multiupload)
  - [11.1 multiupload: Multi-File Multipart Upload](#111-multiupload-multi-file-multipart-upload)
  - [11.2 upload: Raw PUT Single-File Upload](#112-upload-raw-put-single-file-upload)
  - [11.3 Security Summary](#113-security-summary)
  - [11.4 Chapter Summary](#114-chapter-summary)
- [Chapter 12　Windows File Transfer in Practice: open and webcopy](#chapter-12-windows-file-transfer-in-practice-open-and-webcopy)
  - [12.1 open: The System File-Selection Dialog](#121-open-the-system-file-selection-dialog)
  - [12.2 webcopy: File Transfer over Five Protocols](#122-webcopy-file-transfer-over-five-protocols)
  - [12.3 Putting It Together: open + webcopy httpupload Image Upload and Preview](#123-putting-it-together-open--webcopy-httpupload-image-upload-and-preview)
  - [12.4 Chapter Summary](#124-chapter-summary)
- [Chapter 13　Crosstab Case Study](#chapter-13-crosstab-case-study)
  - [13.1 The Nature of WapForm Crosstabs](#131-the-nature-of-wapform-crosstabs)
  - [13.2 System Overview](#132-system-overview)
  - [13.3 Data Query: From Detail Rows to a Pivot](#133-data-query-from-detail-rows-to-a-pivot)
  - [13.4 The `crosstab` Root-Element Attributes](#134-the-crosstab-root-element-attributes)
  - [13.5 Initializing State Variables](#135-initializing-state-variables)
  - [13.6 The Table Container and Pagination Settings](#136-the-table-container-and-pagination-settings)
  - [13.7 Defining the Column Axis: col change](#137-defining-the-row-axis-row-change)
  - [13.8 The Row Axis and Cell Rendering](#138-the-row-axis-and-cell-rendering-cellrowcellcolcell-not-rowcol)
  - [13.9 The Row-End Subtotal Column (the TOTAL Column)](#139-the-row-end-subtotal-column-the-total-column)
  - [13.10 The Row-End AMOUNT Column (Horizontal Grand Total)](#1310-the-row-end-amount-column-horizontal-grand-total)
  - [13.11 Group-End Subtotal Rows (TOTAL Rows)](#1311-group-end-subtotal-rows-total-rows)
  - [13.12 The Final Grand-Total Row (AMOUNT Total)](#1312-the-final-grand-total-row-amount-total)
  - [13.13 Complete WML Source](#1313-complete-wml-source)
  - [13.14 Report Design Pattern Summary](#1314-report-design-pattern-summary)
- [Chapter 14　Building a Sales Management System](#chapter-14-building-a-sales-management-system)
  - [14.1 System Overview](#141-system-overview)
  - [14.2 Three Ways to Write Single-Table CRUD](#142-three-ways-to-write-single-table-crud)
  - [14.3 The Dynamic-Query Trio: `xyz` / `clr` / `set`](#143-the-dynamic-query-trio-xyz--clr--set)
  - [14.4 Shipment Master-Detail: Serial Numbers and Live Detail Totals](#144-shipment-master-detail-serial-numbers-and-live-detail-totals)
  - [14.5 Dynamic Linking: Barcode Scanning and Customer History Price Auto-Fill](#145-dynamic-linking-barcode-scanning-and-customer-history-price-auto-fill)
  - [14.6 Popup Data Selection: Four Kinds of Lookup Dialog Cards](#146-popup-data-selection-four-kinds-of-lookup-dialog-cards)
  - [14.7 Continuous Two-Part Reports: Printing Shipment/Receiving Notes](#147-continuous-two-part-reports-printing-shipmentreceiving-notes)
  - [14.8 Grouped Summary Reports: A/R Statements and Opening-Balance Carry-Forward](#148-grouped-summary-reports-ar-statements-and-opening-balance-carry-forward)
  - [14.9 Mail Integration: One-Click Customer Shipment Notification](#149-mail-integration-one-click-customer-shipment-notification)
  - [14.10 Account and Permission Management: Nested Master-Detail + Auto-Expanding Sub-Tables](#1410-account-and-permission-management-nested-master-detail--auto-expanding-sub-tables)
  - [14.11 Chapter Summary](#1411-chapter-summary)
- [Chapter 15　Building a Dynamic Web Trading Platform (WapForm for Web)](#chapter-15-building-a-dynamic-web-trading-platform-wapform-for-web)
  - [15.1 System Overview](#151-system-overview)
  - [15.2 A Menu Tree Queried Once and Shared Site-Wide](#152-a-menu-tree-queried-once-and-shared-site-wide)
  - [15.3 Component Reuse: asider.wml Never Touches the Database](#153-component-reuse-asiderwml-never-touches-the-database)
  - [15.4 Deciding the Link Target Dynamically by Content Type](#154-deciding-the-link-target-dynamically-by-content-type)
  - [15.5 AJAX Partial Loading: The Two-File Design for Manuals and Notices](#155-ajax-partial-loading-the-two-file-design-for-manuals-and-notices)
  - [15.6 The Shop Homepage: Three Operating Modes and Safe Dynamic Query Assembly](#156-the-shop-homepage-three-operating-modes-and-safe-dynamic-query-assembly)
  - [15.7 The Pagination-Row Generator: the `navigator` Sub Card](#157-the-pagination-row-generator-the-navigator-sub-card)
  - [15.8 Shopping-Cart Summary: The Built-In Cash-Flow Calculation in `header.wml`](#158-shopping-cart-summary-the-built-in-cash-flow-calculation-in-headerwml)
  - [15.9 Session Lifetime: Three Layers and Per-Variable Expiry](#159-session-lifetime-three-layers-and-per-variable-expiry)
  - [15.10 Chapter Summary](#1510-chapter-summary)
- [Chapter 16　Deploying the Same Definition to Flutter (WapForm for Flutter)](#chapter-16-deploying-the-same-definition-to-flutter-wapform-for-flutter)
  - [16.1 Why Another Runtime Is Needed](#161-why-another-runtime-is-needed)
  - [16.2 Package Architecture: WapForm Modules](#162-package-architecture-wapform-modules)
  - [16.3 How WML Tags Map One-to-One to Dart Classes](#163-how-wml-tags-map-one-to-one-to-dart-classes)
  - [16.4 Mapping Master-Detail Structures: Shipments and Line Items](#164-mapping-master-detail-structures-shipments-and-line-items)
  - [16.5 Mapping the Report Engine: How Group Subtotals Become `parseBlock`/`emitRow`](#165-mapping-the-report-engine-how-group-subtotals-become-parseblockemitrow)
  - [16.6 File Architecture: One File, One Independent Unit](#166-file-architecture-one-file-one-independent-unit)
  - [16.7 Real-World Validation: `app001` Through `app902` Translated All at Once](#167-real-world-validation-app001-through-app902-translated-all-at-once)
  - [16.8 Current Platform Status and Known Limitations](#168-current-platform-status-and-known-limitations)
  - [16.9 Installation and Licensing](#169-installation-and-licensing)
  - [16.10 Chapter Summary](#1610-chapter-summary)
- [Appendix A　Quick Reference Card](#appendix-a-quick-reference-card)
- [Appendix B　Complete Function Reference](#appendix-b-complete-function-reference)
- [Appendix C　Flutter Expression Engine Differences](#appendix-c-flutter-expression-engine-differences)
- [Index](#index)

---

## Platform Support Notation

Chapters 1 through 15 use the following two kinds of notation on feature entries, indicating each feature's support status on the Windows/Web platforms; Chapter 16, WapForm for Flutter, is a self-contained chapter and does not use this notation system:

| Notation | Meaning |
|---|---|
| 🖥️ **Win** | WapForm for Windows (desktop application) |
| 🌐 **Web** | WapForm for Web (server-side dynamic web) |
| ✅ | Supported |
| ⚠️ | Partially supported, behaves differently, or not yet confirmed by this manual |
| ❌ | Not supported |

Chapter 4, "Complete Tag Reference," adds a third platform marker:

| Marker | Meaning |
|---|---|
| 📱 **Flutter** | WapForm for Flutter (one WML exports a runnable Flutter app) |

WapForm for Flutter's export maps the **Windows component model** (datasets, grids, navigator bars, fields, events) one-to-one onto equivalent Dart classes; it does not map the Web version's HTML templates, Session or server-side mechanisms. Therefore:

- Any tag marked 🖥️ **Win** ❌ (one that does not exist in the Windows version itself) is also marked 📱 **Flutter** ❌, because there is no Windows-side counterpart to export.
- **Crosstabs** (`<crosstab>` and its child tags) and **charts** (`<chart>` and its child tags) are explicitly listed as "not supported in any edition" in the website's edition comparison, because of the presentation limits of mobile devices, not because of the paid edition; they are therefore all marked 📱 **Flutter** ❌.
- The remaining tags are checked one by one against the capability items in the website's edition comparison (CRUD forms, master-detail structure, Lookup fill-back, calculated fields, data navigator bar, event hooks, dynamic queries, report grouping and pagination, multiple tabs, print preview, and so on); a tag with no matching capability item that this manual cannot confirm from existing material is marked ⚠️ — no unverified claims are made.

The above is compiled from the public information on the WapForm website page `flutter.html` ("Edition comparison"); if edition features change later, the website's announcement at that time prevails.

**📱 Flutter sections**

In Chapters 1–15, every tag or section that has a corresponding module in `wapform_flutter` is followed by a **📱 Flutter** section explaining which module and API do the same thing in Dart, with an example. Features without a corresponding module (for example crosstabs, charts, Web templates, Session, `<navigator/>`, `<dbgrid>`) have no Flutter section. The modules used are all in the package root:

| Module | Main API |
|---|---|
| `wapform_expression.dart` | `WapEvaluator`: `eval()`, `cond()`, `setVar()`, `getVar()`, `setRow()`, `addFunction*()` |
| `wapform_lazarus.dart` | `useEngine()`, `setvar()`, `expression()`, `condition()`, `expandText()`/`expandSql()`/`expandSqlAuto()`/`expandSqlQuoted()`, `invoke()`, `varChangeHooks`, `DataSetRegistry`, `DbQuery` |
| `wapform_lookup_box.dart` | `WapLookupBox` |
| `wapform_filter.dart` | `WapFilter`, `FilterItem` |
| `wapform_report.dart` | `WapReport`, `WapPage`, `isLandscape()`, `normalizePaper()`, `customPaperSizeInches()`, `pageSizeOf()` |
| `wapform_report_style.dart` | `reportCssScreen`, `reportCssPrint`, `reportCssSrc` |
| `report_web.dart` | `openHtmlForPrint()`, `buildHtmlIframe()` |
| `wapform_colors.dart` | `WapColors` |

The examples share three objects: `_ev` (this card's `WapEvaluator`), `_reg` (this card's `DataSetRegistry`) and `db` (`DbQuery(registry: _reg, connection: connection)`; see the package README for creating the connection object), and `useEngine(_ev, _reg)` has already been called when the screen initialized. See Chapter 16 for installation and architecture.

---

## How to Read This Book

Chapters 1–3 establish the conceptual model; Chapter 4 is the complete tag reference; Chapter 5 covers arrays; Chapter 6 is the expression system (interpolation syntax and operators); Chapter 7 is the dataset object reference; Chapter 8 covers Windows login and permissions; Chapter 9 is the Web template system; Chapter 10 covers charts; Chapter 11 is a Web file upload case study (`<upload>` and `<multiupload>`); Chapter 12 is a Windows file transfer case study (`<open>` and `<webcopy>`); Chapter 13 is a crosstab case study; Chapter 14 is a sales management system case study (WapForm for Windows); Chapter 15 is a dynamic web trading platform case study (WapForm for Web); Chapter 16 is a case study in deploying the same definition to Flutter (WapForm for Flutter); Appendix A is a quick reference card; Appendix B is the complete function reference, covering all 398 functions (string, math, date and time, conditional, encoding and conversion, and other); Appendix C covers the differences of the Flutter expression engine. In each chapter, tags and sections with a corresponding module are followed by a **📱 Flutter** section.

---

## Chapter 1　The WapForm Mental Model

### 1.1 Everything Is a Card

🖥️ **Win** ✅ | 🌐 **Web** ✅

WapForm's basic unit of execution is the **card** — a `<card>` element with a unique `id`. A WapForm program is a `<wml>` document containing one or more cards.

**Windows environment:** A card is closer to a Delphi form or a Windows dialog; the runtime environment hosts them inside the same MDI application window.

**Web environment:** A card's `device` attribute points to an HTML template (e.g. `"wapform.html"`), and the framework embeds the output of the WML flow into the template's designated block. Helper cards use `device="sub"` as callable subroutines, loaded asynchronously via JavaScript's `loadDoc()` or the framework's routing mechanism.

```
Windows:
<wml>
  ┌─────────────────────────────────┐
  │ <card id="P" device="MDI">      │  ← Main MDI window
  │   <card id="list" device="wap"> │  ← Search/filter panel
  │   <card id="rpt"  device="prv"> │  ← Print preview
  │   <card id="bk"   device="SUB"> │  ← Background worker
  └─────────────────────────────────┘
</wml>

Web:
<wml>
  <card id="P" device="wapform.html">   ← Main page, output embedded in the HTML template
  <card id="slider"    device="sub">    ← Carousel block (loaded asynchronously)
  <card id="breadcrumb" device="sub">   ← Breadcrumb (loaded asynchronously)
  <card id="content"   device="sub">    ← Main content (loaded asynchronously)
</wml>
```

Navigation between cards uses `<go href="#id">` to jump forward and `<prev/>` to go back to the previous one. In the Web environment, `<redirect href="page.wml"/>` can be used instead for an HTTP redirect.

### 1.2 The Dataset Binding Model

🖥️ **Win** ✅ | 🌐 **Web** ✅

WapForm's data layer is built around the **dataset** — a named, cursor-positioned record set whose lifecycle matches the card's. Each dataset is declared with `<dbquery>` (SQL-query style) or `<dbtable>` (table style). Once declared, a `<datasource dataset="name">` element wraps UI controls and binds them to the current record.

```
┌─ <dbquery id="em"> ─────────────────────────────┐
│   SELECT * FROM employees                        │
│                                                  │
│  ┌─ <datasource dataset="em"> ──────────────┐   │
│  │   <navigator/>               ← CRUD bar  │   │
│  │   <input field="emp_no"/>    ← bound     │   │
│  │   <input field="emp_name"/>  ← bound     │   │
│  └───────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

Datasets work the same way in the Web environment, but UI binding (`<datasource>`, `<navigator/>`, `<dbgrid>`) is usually replaced by directly outputting HTML.

**📱 Flutter** (`wapform_lazarus.dart`: `DbQuery`, `DataSetRegistry`)

`<dbquery id="em">` corresponds to `db.query("em", sql)`: once the query is open it is registered in `DataSetRegistry` as `em`, and expressions can read the current record with `em.field` (the id is case-insensitive).

```dart
Future<void> openEmployees() async {
  await db.query("em", "select * from employees order by emp_no");
  debugPrint("${expression("em.emp_name")} / ${expression("em.COUNT")}");
}
```

### 1.3 Flow Mode vs. Output Mode

🖥️ **Win** ✅ | 🌐 **Web** ✅

A card has two execution modes:

**Flow mode** — the card body executes top-to-bottom as a program: `<setvar>`, `<if>`, `<dbquery>`, `<alert>`, `<go>`. Login validation, record copying, and background batch jobs all run in this mode.

**Output mode** — the card body produces HTML-like markup consumed by the hosting renderer. Windows reports (`device="prv"`) run in this mode; so does all page output in the Web environment.

The same card can mix flow and output — the runtime environment separates the two automatically.

**📱 Flutter** (`wapform_lazarus.dart`; `wapform_report.dart`: `WapReport`)

Flow-mode tags are written in order as `setvar()`, `condition()`, `await db.query(...)`; output mode goes in the `parseBlock()` of a `WapReport` subclass, which outputs HTML with `emitRow(expandText(r"..."))` and hands it to `WapPage` for preview and printing (Section 4.7).

```dart
Future<bool> checkStock() async {
  await db.query("st", r"select * from stock where pno=$(AsQuoted(pa.pno))");
  if (condition("st.COUNT=0")) return false;     // <if cnd="st.COUNT=0"> ... <exit/>
  setvar("ONHAND", "st.qty");
  return true;
}
```

### 1.4 The Expression System

🖥️ **Win** ✅ | 🌐 **Web** ✅

WapForm uses `$variable` for simple substitution and `$(expression)` to compute the value of any string attribute:

```xml
<setvar name="label" value="sz.color_name+'('+sz.color_no+')'"/>
<td>$(IF(total_qty>0, STR(total_qty), '—'))</td>
<alert message="$('Balance: '+STR(sa.c))" cnd="sa.c>0"/>
```

The Web environment adds a `DEFINE(var)` function for checking whether a request or session variable exists:

```xml
<setvar name="pg" value="1"/>
<setvar name="pg" value="val(request.pg)" cnd="DEFINE(request.pg)"/>
```

Expressions follow SQL-style operator precedence and support the full function library (Chapter 5).

**📱 Flutter** (`wapform_expression.dart`: `WapEvaluator`; `wapform_lazarus.dart`: `setvar()`, `expression()`, `condition()`, `expandText()`)

```dart
void expressionDemo() {
  setvar("label", "sz.color_name+'('+sz.color_no+')'");                  // <setvar>
  final td = expandText(r"<td>$(IF(total_qty>0, STR(total_qty), '—'))</td>"); // $(...)
  if (condition("sa.c>0")) {                                               // cnd=
    debugPrint(expandText(r"$('Balance: '+STR(sa.c))"));
  }
  _ev.setVar("request.pg", "3");             // Flutter has no request.*: put it into the engine yourself
  setvar("pg", "1");
  if (condition("DEFINE(request.pg)")) setvar("pg", "VAL(request.pg)");
  debugPrint(td);
}
```

- The value of `setvar()` is always evaluated as an expression, so string literals need single quotes: `setvar("pa.icon", "'a.jpg'")`; to store a Dart value as is (user input, a `List`), use `_ev.setVar()`.
- Write strings containing `$` as Dart raw strings (`r"..."`), otherwise Dart interpolates the `$` first.

### 1.5 The Event Model

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ (only flow events are effective; UI events do not apply)

Datasets and UI controls fire events at key lifecycle moments. Events are handled by an `<onevent type="...">` block containing arbitrary WapForm flow:

| Trigger | Event | Win | Web |
|---|---|---|---|
| On new record | `onnewrecord` | ✅ | ⚠️ |
| Before / after save | `beforepost` / `afterpost` | ✅ | ⚠️ |
| Before / after delete | `beforedelete` / `afterdelete` | ✅ | ⚠️ |
| After the record cursor moves | `afterscroll` | ✅ | ❌ |
| On field value change | `onchange` | ✅ | ❌ |
| After a lookup selection closes | `oncloseup` | ✅ | ❌ |
| On field losing focus | `onexit` | ✅ | ❌ |
| On grid row double-click | `ondblclick` | ✅ | ❌ |
| When computing grid cell colors | `oncalccellcolors` | ✅ | ❌ |
| When the grid footer needs updating | `onupdatefooter` | ✅ | ❌ |

**📱 Flutter**

Events with a directly corresponding module:

| Event | Flutter |
|---|---|
| `oncloseup` after a lookup selection closes | `WapLookupBox(onPicked: (key) { ... })` (Section 4.4) |
| Filter bar `onfilter` | `WapFilter(onQuery: (sql) async { ... })` (Section 4.2) |
| Syncing screen variables after a field value changes | `varChangeHooks` (Section 7.7) |

The flow inside an event is written with `setvar()`, `condition()` and `invoke()` as usual.

---

## Chapter 2　Document Structure

### 2.1 WML Documents

🖥️ **Win** ✅ | 🌐 **Web** ✅

Every WapForm program is a well-formed XML file with a `.wml` extension:

```xml
<?xml version="1.0"?>
<wml>

  <!-- Dataset declarations (shared scope) -->
  <dbquery id="em"><![CDATA[
    SELECT * FROM employees ORDER BY emp_no
  ]]></dbquery>

  <!-- Reusable functions -->
  <function id="UpdateTotal"> ... </function>

  <!-- Cards -->
  <card id="P" title="Employee Master" device="MDI">
    ...
  </card>

</wml>
```

**Typical structure in the Web environment:**

```xml
<?xml version="1.0"?>
<wml>
  <card id="P" device="wapform.html">
    <!-- Flow logic: read request parameters, query the database -->
    <setvar name="gp" value="request.gp" cnd="DEFINE(request.gp)"/>
    <dbquery id="sys">select * from sys</dbquery>
    <!-- Call HTML template blocks -->
    <block name="wapform.aa"/>
    <include name="header"/>
    <block name="onreport"/>
    <include name="footer"/>
    <block name="wapform.zz"/>
  </card>

  <!-- Sub card: loaded asynchronously by JS, or invoked by routing -->
  <card id="content" device="sub">
    <dbquery id="items"><![CDATA[SELECT ... ]]></dbquery>
    <report dataset="items">
      <group>
        <!-- Outputs an HTML fragment -->
      </group>
    </report>
  </card>
</wml>
```

**Scoping rules:**
- `<dbquery>` and `<dbtable>` declared at the top level of a card are visible within that card and its child datasources.
- `<function>` elements declared at the top level can be called from any card in the same file via `<go href="@id">`.
- Variables set with `<setvar>` are global within the card session.

### 2.2 Card Lifecycle

🖥️ **Win** ✅ | 🌐 **Web** ✅ (the flow steps are the same, but UI rendering is replaced by HTML output)

When a card is opened:
1. Top-level flow executes in order: `<setvar>`, `<dbquery>`, `<if>`, `<alert>`.
2. `<datasource>` elements initialize, triggering `onnewrecord` or loading data from a query. (Win)
   In the Web environment, `<report>` directly iterates the dataset to output HTML.
3. The rendered UI is shown to the user.
4. User interaction triggers events; events run subsequent flow. (Win)
   In the Web environment, the next HTTP request triggers a new card execution cycle.
5. `<prev/>` or `<go href="#other">` leaves the card. (Win)
   In the Web environment, `<redirect href="page.wml"/>` or `<go href="#card_id">` performs the jump.

**📱 Flutter** (`wapform_lazarus.dart`: `useEngine()`, `DataSetRegistry.releaseAll()`)

One card corresponds to one screen, each with its own `WapEvaluator` and `DataSetRegistry`:

```dart
final WapEvaluator _ev = WapEvaluator();         // this card's variables
final DataSetRegistry _reg = DataSetRegistry();   // this card's datasets

Future<void> onOpen() async {                     // 1. top-level flow (called from initState)
  useEngine(_ev, _reg);                           //    setvar()/expression()/condition() now use this card
  await db.query("em", "select * from employees");
}

void onClose() => _reg.releaseAll();              // 5. leaving the card: close and release all datasets
```

When several cards are open at once, `useEngine()` decides which one `setvar()`, `expression()` and `condition()` act on; call it again after returning from another card. When a child card should share its parent's variables and datasets, pass the same `_ev` and `_reg` down.

### 2.3 Dataset Field Variable Naming Rules

🖥️ **Win** ✅ | 🌐 **Web** ✅

WapForm concatenates the dataset `id` with the field name to produce a composite variable name. For example:

```xml
<dbquery id="orderhdr" ...>
  <field fieldname="work_order_no" displaylabel="Work Order No."/>
```

The variable `orderhdrwork_order_no` holds the current field value, and can be read or written via `<setvar>`:

```xml
<setvar name="orderhdrwork_order_no" value="'WO-2024-001'"/>
```

**📱 Flutter** (`wapform_lazarus.dart`: `setvar()`)

Flutter does not use concatenated names like `orderhdrwork_order_no`; always write `datasetid.field`:

```dart
void namingDemo() {
  setvar("orderhdr.work_order_no", "'WO-2024-001'"); // writes the current record (enters edit mode automatically when browsing)
  debugPrint("${expression("orderhdr.work_order_no")}");
}
```

When `setvar()` sees `id.field` and `id` is a registered, open dataset, it writes the field; otherwise it is treated as an ordinary variable name.

---

## Chapter 3　Core Patterns

### 3.1 Pattern: Single-Table CRUD Form

🖥️ **Win** ✅ | 🌐 **Web** ❌ (Web uses `<operator>` to output an HTML form)

```xml
<?xml version="1.0"?>
<wml>
  <dbtable name="em" tablename="employees" indexfieldnames="emp_no">
    <field fieldname="emp_no"   displaylabel="Employee No."/>
    <field fieldname="emp_name" displaylabel="Name"/>
    <field fieldname="dept"     displaylabel="Department"/>
    <field fieldname="hired"    displaylabel="Hire Date"/>
  </dbtable>

  <card id="P" title="Employee Master">
    <datasource dataset="em">
      <p align="center"><navigator/></p>
      <fieldset>
        Employee No.: <input field="emp_no"   size="8"/><br/>
        Name:         <input field="emp_name" size="20"/><br/>
        Department:   <input field="dept"     size="12"/><br/>
        Hire Date:    <input field="hired"    type="date" size="12"/>
      </fieldset>
    </datasource>
    <do type="prev" label="Close"><prev/></do>
  </card>
</wml>
```

`<navigator/>` automatically provides "First / Previous / Next / Last / Insert / Delete / Post / Cancel" buttons.

### 3.2 Pattern: Master-Detail Structure

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ (replaced by repeated `<dbquery>` + nested `<report>` output)

**Windows version — nested `<datasource>` establishes the master-detail relationship:**

```xml
<datasource dataset="sh">
  <p align="center"><navigator/></p>
  Shipment No.: <input field="shipment_no" readonly="yes"/><br/>
  <datasource dataset="sn" masterfields="shipment_no">
    <p align="center"><navigator/></p>
    <dbgrid width="900" height="200">
      <item field="seq_no"        size="4"/>
      <item field="material_code" size="12"/>
    </dbgrid>
  </datasource>
</datasource>
```

**📱 Flutter** (`wapform_lazarus.dart`: `DbQuery`, `setvar()`)

The effect of `masterfields="shipment_no"`: when the header moves, the detail is re-queried with the header's current number, and new detail rows get the header's number.

```dart
// call after the header cursor moves
Future<void> loadDetail() async {
  await db.query("sn",
      r"select * from sn where shipment_no=$(AsQuoted(sh.shipment_no)) order by seq_no");
}

// call when adding a detail row
void newDetail() => setvar("sn.shipment_no", "sh.shipment_no");
```

When `db.query()` queries again with the same id, it reuses the existing dataset; `$(AsQuoted(...))` adds single quotes and escapes the content.

### 3.3 Pattern: Query Input → Report Output

🖥️ **Win** ✅ | 🌐 **Web** ✅ (Web outputs HTML, Windows outputs a print preview)

The standard WapForm report flow is a sequence of two cards: an input card that collects parameters, and a report card that renders the output.

**Step 1 — Dynamically assemble the WHERE clause:**

```xml
<function id="build_query">
  <setvar name="S" value="'1=1'"/>
  <setvar name="S" value="S+' AND order_date>=`'+date_from+'`'"
          cnd="date_from<>''"/>
  <setvar name="S" value="S+' AND customer_abbr=`'+cust_filter+'`'"
          cnd="cust_filter<>''"/>
  <dbquery id="rpt_data"><![CDATA[
    SELECT * FROM orders WHERE $S ORDER BY order_date
  ]]></dbquery>
</function>
```

**Step 2 (Windows) — render inside a `<page>` block:**

```xml
<card id="RPT" device="$(IF(preview='Y','PRV','PRN'))" orientation="landscape">
  <report dataset="rpt_data">
    <setvar name="grand_total" value="0"/>
    <page>
      <table class="wap" width="100%" rows="40">
        <group>
          <tr>
            <td>$(rpt_data.work_order_no)</td>
            <td align="right">$(FORMAT('%.2n',rpt_data.order_price))</td>
          </tr>
          <setvar name="grand_total" value="grand_total+rpt_data.order_price"/>
        </group>
      </table>
    </page>
  </report>
</card>
```

**Step 2 (Web) — output HTML inside a sub card:**

```xml
<card id="content" device="sub">
  <dbquery id="rpt_data"><![CDATA[
    SELECT * FROM orders WHERE $S ORDER BY order_date
  ]]></dbquery>
  <report dataset="rpt_data">
    <setvar name="grand_total" value="0"/>
    <group>
      <![CDATA[
      <tr>
        <td>$(rpt_data.work_order_no)</td>
        <td class="text-end">$(FORMAT('%.2n',rpt_data.order_price))</td>
      </tr>
      ]]>
      <setvar name="grand_total" value="grand_total+rpt_data.order_price"/>
    </group>
  </report>
</card>
```

**📱 Flutter** (`wapform_lazarus.dart`: `setvar()`/`expandSql()`; `wapform_report.dart`: `WapReport`, `WapPage`)

**Step 1 — Build the WHERE clause dynamically:**

```dart
Future<void> buildQuery() async {
  setvar("S", "'1=1'");
  if (condition("date_from<>''")) {
    setvar("S", "S+' AND order_date>=`'+AsSqlStr(date_from)+'`'");
  }
  if (condition("cust_filter<>''")) {
    setvar("S", "S+' AND customer_abbr=`'+AsSqlStr(cust_filter)+'`'");
  }
  await db.query("rpt_data", r"SELECT * FROM orders WHERE $S ORDER BY order_date");
}
```

**Step 2 — The report:** `<report dataset="rpt_data">` becomes a `WapReport` subclass; a `<group>` without `change` is the `RECORD` block, and `<page>` is `PAGEPREFIX`/`PAGESUFFIX`:

```dart
class OrderListReport extends WapReport {
  @override
  void initParams() {
    wap.wapLpp = 40;                        // <table rows="40">
    wap.wapGroups = 0;
  }

  @override
  String expression(int idx) => '';

  @override
  Future<bool> fetchFirst() async {
    invoke("rpt_data", "first");
    return !condition("rpt_data.EOF");
  }

  @override
  Future<bool> fetchNext() async {
    invoke("rpt_data", "next");
    return !condition("rpt_data.EOF");
  }

  @override
  Future<void> fetchPrior() async => invoke("rpt_data", "prior");

  @override
  void parseBlock(String id) {
    switch (id) {
      case 'PREFIX':
        setvar("grand_total", "0");
        break;
      case 'PAGEPREFIX':
        emit('<table class="wap" width="100%">');
        break;
      case 'RECORD':
        emitRow(expandText(r"<tr><td>$(rpt_data.work_order_no)</td>"
            r"<td align='right'>$(FORMAT('%.2n',rpt_data.order_price))</td></tr>"));
        setvar("grand_total", "grand_total+rpt_data.order_price");
        break;
      case 'PAGESUFFIX':
        emit('</table>');
        break;
    }
  }
}
```

**Step 3 — Preview** (`device="PRV"`, `orientation="landscape"`):

```dart
Future<void> showReport() async {
  await buildQuery();
  if (!mounted) return;
  await Navigator.push(context, MaterialPageRoute(
    builder: (_) => WapPage(title: "Orders", report: OrderListReport(), orient: "L"),
  ));
}
```

Flutter has no "print directly without preview": `PRN` also opens `WapPage`, and the user presses Print (on the Web it goes to the browser's print; on Android a PDF is produced).

### 3.4 Pattern: Lookup with Auto-Fill

🖥️ **Win** ✅ | 🌐 **Web** ❌ (Web uses an HTML select or AJAX instead)

```xml
<input field="material_code"
       lookup="pm;material_code;material_name"
       size="12">
  <onevent type="oncloseup">
    <setvar name="snmaterial_name" value="luppm.material_name"/>
  </onevent>
  <onevent type="onexit">
    <setvar name="snmaterial_name" value="''"
            cnd="sn.material_code=''"/>
  </onevent>
</input>
```

The `lookup` attribute's format is: `"dataset_id ; key field ; display field"`. The prefix `lup` + dataset id gives access to fields of the selected row.

A dynamic SQL-based lookup:

```xml
<input field="color_no"
       lookup="sql;yy;SELECT color_no, color_name FROM color_master ORDER BY color_no"
       size="10">
  <onevent type="oncloseup">
    <setvar name="sncolor_name" value="lupyy.color_name"/>
  </onevent>
</input>
```

**📱 Flutter** (`wapform_lookup_box.dart`: `WapLookupBox`)

`lookup="pm;material_code;material_name"` + filling back in `oncloseup`:

```dart
Widget materialLookup() => WapLookupBox(
      dataSet: _reg.findQuery("pm"),                  // the lookup's source dataset
      keyField: "material_code",
      displayFields: const ["material_code", "material_name"],
      colWidths: const [100, 220],
      value: "${expression("sn.material_code") ?? ''}",
      onPicked: (key) {                               // oncloseup
        _ev.setVar("PICKED", key);
        setvar("sn.material_code", "PICKED");
        invoke("pm", "first");                        // find the chosen row (same as luppm)
        while (!condition("pm.EOF") && !condition("pm.material_code=PICKED")) {
          invoke("pm", "next");
        }
        setvar("sn.material_name", "pm.material_name");
      },
      onChanged: (key) {                              // onexit: clear the name when the code is cleared
        if (key.isEmpty) setvar("sn.material_name", "''");
      },
    );
```

- SQL lookups (`lookup="sql;yy;SELECT ..."`): first `await db.query("yy", "SELECT color_no, color_name FROM color_master ORDER BY color_no")`, then pass `_reg.findQuery("yy")` to `dataSet:`.
- Fixed options need no dataset: `lookupItems: {'A': 'Cash', 'B': 'Transfer'}` (one column), or `lookupColumns: {'P01': ['Ballpoint pen', 'pcs']}` + `colWidths` (several columns).

### 3.5 Pattern: Multi-Tab Sectioned Form

🖥️ **Win** ✅ | 🌐 **Web** ❌ (Web uses Bootstrap tabs + multiple sub cards instead)

```xml
<pagecontrol name="pc" activepageindex="0">
  <tabsheet caption="Order Header">
    <datasource dataset="oh">
      <p align="center"><navigator/></p>
    </datasource>
  </tabsheet>
  <tabsheet caption="Quick Search">
    <datasource dataset="od_view">
      <dbgrid name="search_grid" width="1000" height="400" multi="yes">
        <onevent type="ondblclick">
          <setprop name="pc" prop="ActivePageIndex" value="0"/>
          <invoke instance="oh" method="locate"
                params="'work_order_no';od_view.work_order_no"/>
        </onevent>
      </dbgrid>
    </datasource>
  </tabsheet>
</pagecontrol>
```

### 3.6 Pattern: Background Copy Job

🖥️ **Win** ✅ | 🌐 **Web** ✅ (Web uses `device="sub"` + `<redirect>` instead)

A card with `device="SUB"` runs a workflow without opening a window, suitable for record copying, batch updates, and auto-numbering.

**Windows version:**

```xml
<card id="do_copy" device="SUB">
  <dbquery id="src">SELECT * FROM orders WHERE work_order_no='$source_no'</dbquery>
  <if cnd="src.COUNT=0">
    <alert message="Source record not found"/>
    <exit/>
  </if>
  <dbquery><![CDATA[
    INSERT INTO orders (work_order_no, ...) VALUES ('$target_no', ...)
  ]]></dbquery>
  <invoke instance="oh" method="refresh"/>
  <alert message="Copy completed successfully"/>
</card>
```

**Web version:**

```xml
<card id="content" device="sub">
  <if cnd="DEFINE(request.del)">
    <dbquery><![CDATA[DELETE FROM rn WHERE sno='$session.ord']]></dbquery>
    <session name="ord" value="''"/>
    <redirect href="cart.wml"/>
  </if>
  <!-- Remaining logic -->
</card>
```

**📱 Flutter** (`wapform_lazarus.dart`: `DbQuery.query()`/`DbQuery.exec()`)

A `device="SUB"` card is, in Flutter, an `async` method that builds no screen:

```dart
Future<String> doCopy(String sourceNo, String targetNo) async {
  _ev.setVar("source_no", sourceNo);
  _ev.setVar("target_no", targetNo);
  await db.query("src", r"SELECT * FROM orders WHERE work_order_no=$(AsQuoted(source_no))");
  if (condition("src.COUNT=0")) return "Source record not found";   // <alert> + <exit/>
  await db.exec(r"INSERT INTO orders (work_order_no, buyer, amount) "
      r"VALUES ($(AsQuoted(target_no)), $(AsQuoted(src.buyer)), $src.amount)");
  await db.query("oh", "SELECT * FROM orders ORDER BY work_order_no"); // invoke refresh
  return "Copy completed successfully";
}
```

- `db.query(id, sql)`: opens a query and registers it under id; `db.exec(sql)`: runs SQL that returns no rows and returns the number of affected rows.
- Both can take parameters instead: `db.query("src", "select * from orders where work_order_no=:no", params: {"no": sourceNo})`; once `params` is given, `$` is no longer expanded.

### 3.7 Pattern: Dynamic WHERE + Multi-Mode Search

🖥️ **Win** ✅ | 🌐 **Web** ✅

```xml
<function id="run_search">
  <setvar name="S" value="'1=1'"/>
  <if cnd="match_mode='A'">
    <setvar name="S" value="S+' AND buyer_name=`'+buyer_filter+'`'"
            cnd="buyer_filter<>''"/>
  </if>
  <if cnd="match_mode='B'">
    <setvar name="S" value="S+' AND buyer_name LIKE `'+buyer_filter+'%`'"
            cnd="buyer_filter<>''"/>
  </if>
  <!-- Prevent a full-table scan -->
  <setvar name="S" value="'work_order_no=`__NONE__`'" cnd="S='1=1'"/>
  <dbquery id="result"><![CDATA[
    SELECT * FROM orders WHERE $S ORDER BY order_date DESC
  ]]></dbquery>
</function>
```

**📱 Flutter** (`wapform_lazarus.dart`: `setvar()`, `condition()`, `expandSql()`)

```dart
Future<void> runSearch() async {
  setvar("S", "'1=1'");
  if (condition("(match_mode='A') AND (buyer_filter<>'')")) {
    setvar("S", "S+' AND buyer_name=`'+AsSqlStr(buyer_filter)+'`'");
  }
  if (condition("(match_mode='B') AND (buyer_filter<>'')")) {
    setvar("S", "S+' AND buyer_name LIKE `'+AsSqlStr(buyer_filter)+'%`'");
  }
  if (condition("S='1=1'")) setvar("S", "'work_order_no=`__NONE__`'"); // prevent a full table scan
  await db.query("result", r"SELECT * FROM orders WHERE $S ORDER BY order_date DESC");
}
```

Backticks become single quotes on expansion; `$S` is inserted as is; user input always goes through `AsSqlStr()` first (`'` → `''`). In the Dart engine, comparisons on both sides of `AND`/`OR` need parentheses.

### 3.8 Pattern: Web Member Login and Session Management

🖥️ **Win** ❌ | 🌐 **Web** ✅

```xml
<card id="content" device="sub">
  <if cnd="gp='logout'">
    <session name="usr" value="''"/>
    <session name="ord" value="''"/>
    <redirect href="index.wml"/>
  </if>
  <if cnd="gp='set'">
    <dbquery id="usr"><![CDATA[select * from cu where email='$A']]></dbquery>
    <if cnd="usr.count=0">
      <block name="login-alert" message="'User is not authorized to log in.'"/>
    <elseif cnd="MD5(B)<>usr.password"/>
      <block name="login-alert" message="'Incorrect password.'"/>
    <else/>
      <session name="usr" value="A"/>
      <redirect href="index.wml"/>
    </if>
  </if>
</card>
```

To make the login identity time out automatically, add `expire` (in minutes) when writing it:

```xml
<else/>
  <session name="usr" value="A" expire="480"/>   <!-- signed out automatically after 8 hours -->
  <redirect href="index.wml"/>
```

`expire` can only make a variable expire earlier than the system default, never later; see Section 15.9 of Chapter 15 for the full explanation.

> **Note**: parameter values of `<block>` are expressions, so string literals must be quoted. If `title="'Error'"` above were written as `title="Error"`, it would be treated as a variable name and come back Null, and the template output would throw `Could not convert variant of type (Null) into type (OleStr)`.

---

## Chapter 4　Complete Tag Reference

This chapter organizes by function all the tags used in WML, including tags unique to WapForm and standard HTML tags that can be output directly. Each tag shows 🖥️ Win / 🌐 Web support status, a complete attribute table (marking **(required)** / **(optional)**), common child tags, and a minimal working example. Attribute names are rendered in `monospace`; `<element/>` denotes a void element, `<element>` a container element. Expression syntax follows the `$()` interpolation convention — see Chapter 6 for details.

### 4.1 Document and Layout Tags

#### `<wml>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

The root container of every `.wml` file, containing one or more `<card>` elements. It has no attributes of its own and cannot be omitted.

**Common child tags:** `<card>` (one or more)

```xml
<?xml version="1.0"?>
<wml>
  <card id="P" title="Example">
    ...
  </card>
</wml>
```

#### `<card>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

WML's basic unit of execution, called "everything is a Card" in Chapter 1. A single `.wml` file can contain multiple cards, and the framework determines the rendering method and role based on `device`.

| Attribute | Required/Optional | Description |
|---|---|---|
| `id` | (required) | Card identifier, referenced by `<include>`, `loadDoc()`, and routing calls |
| `title` | (optional) | Window title (Win) or the HTML `<title>` (Web) |
| `device` | (optional) | Determines the rendering role: `MDI` (Windows main window), `SUB`/`sub` (background/sub card, produces no UI), `PRV` (print preview), `PRN` (direct print), or an HTML template filename (Web, e.g. `"wapform.html"`, `"wapform-js.html"`) |
| `width` / `height` | (optional) | Dialog dimensions (Win) |
| `orientation` | (optional) | Report orientation: `portrait` (default) / `landscape` |
| `printer` | (optional) | Specifies the printer source, usually carrying a system setting like `sys.printer1` |
| `preview` | (optional) | `Y`/`N`, controls whether the report enters print preview first |
| `zoom` | (optional) | Initial zoom level for print preview |
| `rowheight` | (optional) | Grid/report row height (pixels) |
| `fontsize` | (optional) | Default font size (points) |

**Common child tags:** `<dbquery>`, `<datasource>`, `<report>`, `<crosstab>`, `<mainmenu>`, `<fieldset>`, `<do>`, `<function>`, `<onevent>`, and various flow-control tags

```xml
<card id="P" title="Employee Master" device="MDI">
  <dbquery id="em">select * from employees</dbquery>
  <datasource dataset="em">
    <navigator/>
    <fieldset>
      Employee No.: <input field="emp_no" size="8"/>
    </fieldset>
  </datasource>
</card>
```

The card lifecycle is covered in detail in Section 2.2.

**📱 Flutter** (`wapform_report.dart`: `WapPage`)

A report card (`device="PRV"`/`"PRN"`) is a `WapPage` in Flutter; `orientation` maps to `orient`:

```dart
Widget reportCard(WapReport report) => WapPage(
      title: "Employee Roster",    // title=
      report: report,              // the <report> inside the card
      orient: "L",                 // orientation="landscape"
      paper: "A4",
    );
```

`orient` accepts `P` (default), `L`, `landscape`, `1`, `橫` and `水平` (Chinese for "landscape"); `paper` accepts `A4`, `A3`, `A5`, `B5`, `letter`, `legal`, or a custom size in inches such as `"8.5x5.5"`.

#### `<page>` (layout)

🖥️ **Win** ✅ | 🌐 **Web** ✅ (print output scenarios only) | 📱 **Flutter** ✅

Wraps the content of one physical page; inside `<report>`/`<crosstab>`, `<page>` is re-entered on each page break.

**Common child tags:** `<table>`, `<group>`, arbitrary HTML layout tags

```xml
<page>
  <table class="wap" width="100%" rows="40">
    <group>...</group>
  </table>
</page>
```

**📱 Flutter** (`wapform_report.dart`: the `PAGEPREFIX`/`PAGESUFFIX`/`PAGEBREAK` blocks)

`WapReport` calls `parseBlock('PAGEPREFIX')` at the start of each page, `parseBlock('PAGESUFFIX')` at the end, and `parseBlock('PAGEBREAK')` between two pages; the header reprinted on every page inside `<page>` goes in `PAGEPREFIX`, and `rows="40"` maps to `wap.wapLpp = 40`:

```dart
// part of a WapReport subclass's parseBlock()
void pageBlocks(String id) {
  switch (id) {
    case 'PAGEPREFIX':                                   // <page><table class="wap">
      emit('<table class="wap" width="100%">');
      break;
    case 'PAGESUFFIX':                                   // </table></page>
      emit('</table>');
      break;
  }
}
```

#### `<fieldset>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

Wraps a group of related input fields, corresponding to the HTML `<fieldset>`; `<input>` elements and descriptive text are placed directly inside.

**Common child tags:** `<input>`, `<p>`, `<br/>`

```xml
<fieldset>
  <p>Employee No.: <input field="emp_no" size="8"/></p>
  <p>Name: <input field="emp_name" size="20"/></p>
</fieldset>
```

---

### 4.2 Data Access Tags

#### `<dbquery>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

Declares a dataset, with the content being a SQL statement. Multi-line SQL, or SQL containing special characters, should be wrapped in `<![CDATA[ ]]>` to avoid conflicts between characters like `<`, `>`, `&` and XML parsing.

| Attribute | Required/Optional | Description |
|---|---|---|
| `id` | (required) | Dataset identifier, later referenced as `$id.field` or `id.field` |
| `name` | (optional) | Some versions use `name` instead of `id`, with the same effect |
| `tablename` | (optional) | Specifies the physical table name when used together with `<dbtable>` |

**Common child tags:** `<field>` (when explicitly defining fields)

```xml
<dbquery id="em"><![CDATA[
  SELECT * FROM employees WHERE dept='$dept'
]]></dbquery>
```

For a simple query, the CDATA can be omitted: `<dbquery id="sys">select * from sys</dbquery>`.

**📱 Flutter** (`wapform_lazarus.dart`: `DbQuery.query()`/`DbQuery.exec()`, `expandSql()`)

| WML | Flutter |
|---|---|
| `<dbquery id="em">select ...</dbquery>` | `await db.query("em", r"select ...")` |
| `$dept`, `$(expr)` in the SQL | expanded automatically with `expandSql()` before the query |
| `<dbquery>` without `id` (INSERT/UPDATE/DELETE) | `await db.exec(r"...")`, returns the number of affected rows |

```dart
Future<void> dbqueryDemo() async {
  await db.query("em", r"SELECT * FROM employees WHERE dept='$dept'");
  await db.query("em2", "select * from employees where dept=:d", params: {"d": "R&D"});
  final n = await db.exec(r"UPDATE employees SET active=1 WHERE dept='$dept'");
  debugPrint("$n rows");
}
```

- Calling again with the same id re-queries the same dataset with the new SQL; an empty id gives a one-off query that is not registered.
- When `params` is given, `$` is not expanded and the values are sent as parameters — the best protection against SQL injection.
- In Dart strings, write `<`, `>` and `&` directly; no CDATA is needed.

#### `<dbtable>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ (usually replaced by `<dbquery>`) | 📱 **Flutter** ✅

Used together with `<field>` child tags to explicitly define a dataset's fields and display names, as an alternative to writing SQL directly; common on simple master-file CRUD pages, and also used for helper lookup datasets that carry a key value.

| Attribute | Required/Optional | Description |
|---|---|---|
| `tablename` | (required) | The physical table name |
| `name` | (optional) | Dataset identifier |
| `indexfieldnames` | (optional) | Index field(s), used for sorting and `locate` positioning |
| `keyfields` | (optional) | Primary key field(s), used as the basis for lookup/update |
| `lookupkeyfields` | (optional) | The key field(s) used when this dataset is referenced by another `<input lookup=...>` |
| `filter` | (optional) | Initial filter condition string |

**Common child tags:** `<field>` (one or more)

```xml
<dbtable tablename="fm">
  <field fieldname="fno" displaylabel="Carrier Code"/>
  <field fieldname="fname" displaylabel="Carrier Name"/>
</dbtable>

<!-- A lookup helper dataset with a key value -->
<dbtable name="gs" tablename="gszl" keyfields="factory_code" lookupkeyfields="factory_code">
  <field fieldname="factory_code" displaylabel="Factory Code"/>
  <field fieldname="factory_name" displaylabel="Factory Name"/>
</dbtable>
```

**📱 Flutter** (`wapform_lazarus.dart`: `DbQuery.query()`)

Flutter only has query datasets; `<dbtable tablename="fm" indexfieldnames="fno">` becomes:

```dart
Future<void> openFm() => db.query("fm", "select * from fm order by fno");
```

`lookupkeyfields` corresponds to `WapLookupBox`'s `keyField` (`<input>` in Section 4.4).

#### `<field>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

A child tag under `<dbquery>` or `<dbtable>` that defines a single field's display name, type, and default value. Void element.

| Attribute | Required/Optional | Description |
|---|---|---|
| `fieldname` | (required) | Corresponds to the actual database field name |
| `name` | (optional) | Some versions use `name` instead of `fieldname` |
| `displaylabel` | (optional) | On-screen display label |
| `type` | (optional) | Data type, e.g. `date`, `checkbox` |
| `value` | (optional) | Default value (commonly used when inserting a new record) |

```xml
<field fieldname="hired" displaylabel="Hire Date" type="date"/>
```

#### `<dbfilter>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ (usually replaced by a hand-written dynamic WHERE, see Section 14.3) | 📱 **Flutter** ✅

A declarative quick-filter row; the framework automatically generates input boxes and assembles the condition string in the `onfilter` event.

| Attribute | Required/Optional | Description |
|---|---|---|
| `result` | (required) | The variable name for the resulting filter string |

**Common child tags:** `<item>` (defines a filter field), `<onevent type="onfilter">`

```xml
<dbfilter result="R">
  <item field="cno" size="20"/>
  <item field="cname" size="20"/>
  <onevent type="onfilter">
    <dbquery id="cu"><![CDATA[select * from cu where $R order by cno]]></dbquery>
  </onevent>
</dbfilter>
```

**📱 Flutter** (`wapform_filter.dart`: `WapFilter`, `FilterItem`)

| WML | `WapFilter` |
|---|---|
| `<item field="cno" size="20"/>` | `items: [FilterItem(field: "cno", label: "Customer No", size: 20)]` |
| `result="R"` + `$R` in the SQL | `sqlTemplate: r"select * from cu where $R order by cno"` |
| `<onevent type="onfilter">` | `onQuery: (sql) async { ... }`, receives the full SQL with `$R` replaced |

```dart
Widget customerFilter() => WapFilter(
      items: const [
        FilterItem(field: "cno", label: "Customer No", size: 20),
        FilterItem(field: "cname", label: "Customer Name", size: 20),
      ],
      sqlTemplate: r"select * from cu where $R order by cno",
      onQuery: (sql) async {
        await db.query("cu", sql);           // the <dbquery> inside onfilter
        if (mounted) setState(() {});
      },
    );
```

Conditions the user types in each field:

| Input | Resulting condition |
|---|---|
| `A` | `field = 'A'` |
| `A~Z` | `(field >= 'A' and field <= 'Z')` |
| `A~` | `field >= 'A'` |
| `~Z` | `field <= 'Z'` |
| Contains `%` (`A%`, `%A%`) | `field like '...'` |
| All empty | `1=1` |

Several fields are joined with `and`, and `'` in the input is escaped to `''` automatically; **Clear** empties all fields and calls `onQuery` with `1=1`. Without `width` the filter fills its parent; `borderColor` changes the border color.

---

### 4.3 Data Binding and List Tags

#### `<datasource>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ (the Web environment iterates output with `<report>` instead, see Sections 3.1/3.2) | 📱 **Flutter** ✅

Binds screen components (`<input>`, `<dbgrid>`, `<navigator>`) to the given dataset; can be nested to build a master-detail structure.

| Attribute | Req./Opt. | Description |
|---|---|---|
| `dataset` | (req.) | The `id` of the corresponding `<dbquery>` |
| `name` | (opt.) | Lets an inner `<datasource>` refer to it through `mastersource` |
| `mastersource` | (opt.) | For nested master-detail, points to the `name` of the outer `<datasource>` |
| `masterfields` | (opt.) | Master-detail link field; the child level is refiltered by this field automatically |

**Common child tags:** `<navigator/>`, `<fieldset>`, `<input>`, `<dbgrid>`, an inner `<datasource>` (master-detail nesting)

```xml
<datasource dataset="sh">
  <navigator/>
  <fieldset>
    No.: <input field="sno" readonly="true"/>
  </fieldset>
  <datasource name="ds" dataset="sn" mastersource="sh" masterfields="sno">
    <navigator/>
    <dbgrid height="200">
      <item field="pno" size="14"/>
      <item field="qty" size="8"/>
    </dbgrid>
  </datasource>
</datasource>
```

See Section 3.2 for master-detail structures; Section 14.4 of Chapter 14 has a complete production example.

#### `<dbgrid>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ (the Web replaces it with an HTML `<table>` output loop) | 📱 **Flutter** ✅

A tabular list containing several `<item>` field definitions; supports in-place editing and check boxes.

| Attribute | Req./Opt. | Description |
|---|---|---|
| `name` | (opt.) | For references from code (e.g. `lookupResolver`) |
| `height` / `width` | (opt.) | Grid size (pixels) |
| `color` | (opt.) | Background color |
| `fontsize` | (opt.) | Font size (points) |
| `multi` | (opt.) | `1` allows multiple selection |

**Common child tags:** `<item>` (one or more), `<column>` (style rules)

#### `<item>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ✅

A field definition under `<dbgrid>` or `<dbfilter>`. Empty element.

| Attribute | Req./Opt. | Description |
|---|---|---|
| `field` | (req.) | The corresponding dataset field |
| `size` | (opt.) | Column width |
| `title` | (opt.) | Column title; defaults to the dataset field's `displaylabel` |
| `type` | (opt.) | Special presentations such as `checkbox` |
| `range` | (opt.) | With `type="checkbox"`, in the format `checked value;unchecked value` |
| `lookup` | (opt.) | Format `table;key field;display field`; the column shows the lookup result |

```xml
<dbgrid name="gd" height="200">
  <item field="itm" title="No." size="10"/>
  <item field="uid" size="30" lookup="users;userid"/>
  <item field="w" title="Enabled" type="checkbox" range="1;0" size="10"/>
</dbgrid>
```

**📱 Flutter**

- Inside `<dbfilter>`: one `FilterItem(field:, label:, size:)` (see `<dbfilter>`).
- With `lookup`: the lookup list comes from `WapLookupBox`; inside a grid cell set `forGrid: true` and handle Tab moves with `onTab`/`onTabPrev` (parameters in Section 7.3).

#### `<navigator/>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ (the Web implements it by hand with buttons and `request.op`) | 📱 **Flutter** ✅

Generates the complete CRUD button bar — first / previous / next / last / insert / delete / save / cancel. Empty element, bound to the dataset of the enclosing `<datasource>`, no attributes.

```xml
<p align="center"><navigator/></p>
```

#### `<column/>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

Used inside `<dbgrid>` to apply a style (background color, text color) to a whole column or row by condition, typically for status highlighting. Empty element, always written under the `<dbgrid>`'s `<onevent type="oncalccellcolors">`, evaluated for every record.

| Attribute | Req./Opt. | Description |
|---|---|---|
| `field` | (opt.) | Target column (**omit it to apply to the whole row**, not the whole column — this is often misunderstood: `field` means "only this column", leaving it out means "the entire row") |
| `brush` | (opt.) | Background color (hex color code, no `#`) |
| `color` | (opt.) | Text color |
| `cnd` | (opt.) | Condition expression; the style is applied only when it holds; when omitted it always holds (see the advanced example below) |

**Basic use** (whole-row coloring: when `cnd` holds, the whole row's background changes):

```xml
<column brush="EDDA74" color="000000" cnd="od.cancelled='Y'"/>
```

**Advanced use**: one `oncalccellcolors` can hold several `<column>` rules; each row of data is checked against them in order and they do not interfere with each other (a later rule does not override one already applied, unless the two rules' `field` or whole-row ranges overlap). A common combination: one rule marks "the current record" and the others color specific columns by data value:

```xml
<onevent type="oncalccellcolors">
  <!-- no field: color the whole row to mark "the current record" (compares a string built from the primary key) -->
  <column brush="#E5F3FF" cnd="sh.sno=(shym+shco+FORMAT('%4.4d',1))"/>

  <!-- with field: only the cno column is colored, and the color itself is computed
       (the brush value is built with $(...) from the database field sh.color, not a fixed code) -->
  <column field="cno" _color="#FF0000" brush="$('#'+sh.color)" cnd="sh.color&lt;&gt;''"/>
  <column field="cshort" _color="#FF0000" brush="$('#'+sh.color)" cnd="sh.color&lt;&gt;''"/>

  <!-- no cnd is also valid: these two rules have no condition, i.e. "always apply", used to fix a column's text color -->
  <column field="eval" color="#0000FF"/>
  <column field="log" color="#FF0000"/>
</onevent>
```

This example shows three additional rules:

1. **`brush`/`color` can be dynamic values**, not just fixed hex literals — the example uses `$('#'+sh.color)` to turn the color value stored in the database field `sh.color` into a full color code, so different rows of the same `<dbgrid>` can get different colors.
2. **`cnd` can be omitted**: a `<column>` rule without `cnd` always holds, commonly used to fix the style of a column (like the `eval`/`log` columns above).
3. ⚠️ The example contains `_color="#FF0000"` (with a leading underscore and a `#`) instead of the `color` listed in the table (no underscore). This manual has not found a formal specification for underscore-prefixed attributes (`_color`, `_bgcolor`, etc.), and it is unclear whether the prefix means "disabled, kept for later" or a separate syntax; the `<dbgrid>` element in the example also carries `_bgcolor="#EEF3E9"`. Rely on what `wap.exe`/`flutter.pas` produces in your environment for the actual behavior; the form observed is recorded here as is, to avoid misleading you.

---

### 4.4 Form Input and Interaction Tags

#### `<input>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ (the Web must write `request.*` back itself) | 📱 **Flutter** ✅

Binds an input control to a single field; type and attributes vary with `type`. Void element.

| Attribute | Required/Optional | Description |
|---|---|---|
| `field` | (required) | Corresponds to a dataset field |
| `size` | (optional) | Display width |
| `type` | (optional) | `date`/`checkbox`/`radio`, etc.; defaults to plain text input |
| `value` | (optional) | The option value for `checkbox`/`radio`, format `checked-value;unchecked-value` |
| `readonly` | (optional) | Read-only when `true` |
| `lookup` | (optional) | `table;key field;display field`, with auto-fill (see Section 3.4) |
| `oncustomdlg` | (optional) | Points to a popup selection card (e.g. `#PC`), replacing the default lookup dialog |
| `color` | (optional) | Field background color, often combined with `cnd` to highlight anomalous values |
| `title` | (optional) | Used as the option text label with `type="checkbox"` |
| `rows` / `cols` | (optional) | Rows/columns for multi-line text input (`textarea` type) |
| `onclick` | (optional) | Event handler triggered on click |

```xml
<input field="cno" size="14" lookup="cu;cno;cname"/>
<input field="confirmed" type="checkbox" value="Y;N" title="Confirmed Order"/>
<input field="cancel_date" type="date"/>
<input field="remark" type="textarea" rows="4" cols="40"/>
```

**📱 Flutter** (`wapform_lookup_box.dart`: `WapLookupBox`)

The lookup drop-down of `<input lookup="cu;cno;cname">`:

```dart
Widget customerLookup(bool editing) => WapLookupBox(
      dataSet: _reg.findQuery("cu"),               // lookup part 1: source dataset
      keyField: "cno",                             // part 2: key field
      displayFields: const ["cno", "cname"],       // part 3: display fields (one or more)
      colWidths: const [80, 200],
      width: 168,                                  // size="14"
      readOnly: !editing,                          // readonly="true"
      value: "${expression("sh.cno") ?? ''}",
      onPicked: (key) {                            // oncloseup
        _ev.setVar("PICKED", key);
        setvar("sh.cno", "PICKED");
      },
    );
```

As the user types in the box, the list keeps only items whose code or any display field contains the typed text; Enter selects. On losing focus the typed content is filled back and `onChanged` is called.

#### `<do>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ (the Web uses ordinary HTML buttons + `request.op` instead) | 📱 **Flutter** ✅

Defines an on-screen button; `type` determines the built-in behavior.

| Attribute | Required/Optional | Description |
|---|---|---|
| `type` | (required) | `accept` (OK, triggers save or a custom event) / `prev` (Cancel, triggers `<prev/>` to go back one level) |
| `label` | (optional) | Button text |

**Common child tags:** `<prev>`, `<setvar>`, `<invoke>`, `<dbquery>`, and any other flow tag

```xml
<do type="accept" label="OK">
  <prev><setvar name="RESULT" value="gr.id"/></prev>
</do>
<do type="prev" label="Cancel"><prev/></do>
```

#### `<prev>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ✅

Closes the current popup card and returns to the previous level; when it contains `<setvar>`, the selection result can be carried back into a variable in the parent level before closing (see Section 14.6, the four kinds of lookup dialog cards). It's a void element `<prev/>` when it has no attributes/children; a container element when it has child tags.

**Common child tags:** `<setvar>`

```xml
<prev><setvar name="shcno" value="cu1.cno"/></prev>
```

#### `<alert>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ (the Web uses JavaScript `alert()` or a front-end message component instead) | 📱 **Flutter** ✅

Pops up a message box, commonly used with `cnd` for conditional validation.

| Attribute | Required/Optional | Description |
|---|---|---|
| `cnd` | (optional) | Pops up only if the condition is true |
| `message` | (optional) | Message content; can also be written directly as the tag's inner text |

```xml
<alert cnd="qty<=0">Quantity must be greater than zero</alert>
```

#### `<prompt>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

Pops up an input dialog asking the user to enter a single value, which is saved back into a specified variable.

| Attribute | Required/Optional | Description |
|---|---|---|
| `message` | (optional) | Prompt text |
| `result` | (required) | Variable name the input result is stored into |

---

### 4.5 Flow Control Tags

#### `<if>` / `<elseif>` / `<else>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

Conditional branching. `<if>` can use the `cnd` attribute for a single-line condition, or be combined with `<elseif>`/`<else>` to build multiple branches.

| Attribute | Required/Optional | Description (applies to `<if>`/`<elseif>`) |
|---|---|---|
| `cnd` | (required) | Condition expression |

**Common child tags:** any tag; `<elseif>`/`<else>` may only appear inside `<if>`

```xml
<if cnd="CUSTNO_TO=''">
  <setvar name="SQL_WHERE" value="SQL_WHERE+' AND cno like '''+CUSTNO_FROM+'%'''"/>
  <elseif cnd="CUSTNO_FROM=''"/>
  <setvar name="SQL_WHERE" value="SQL_WHERE"/>
  <else/>
  <setvar name="SQL_WHERE" value="SQL_WHERE+' AND cno &gt;= '''+CUSTNO_FROM+''''"/>
</if>
```

Most tags (`<setvar>`, `<dbquery>`, `<invoke>`, etc.) support attaching a `cnd` attribute directly for single-condition execution, equivalent to wrapping them in an `<if>`.

**📱 Flutter** (`wapform_lazarus.dart`: `condition()`)

```dart
void buildWhere() {
  if (condition("CUSTNO_TO=''")) {
    setvar("SQL_WHERE", "SQL_WHERE+' AND cno like '''+CUSTNO_FROM+'%'''");
  } else if (condition("CUSTNO_FROM=''")) {
    setvar("SQL_WHERE", "SQL_WHERE");
  } else {
    setvar("SQL_WHERE", "SQL_WHERE+' AND cno >= '''+CUSTNO_FROM+''''");
  }
}
```

- A tag's `cnd` attribute becomes `if (condition("...")) ...;`.
- **In the Dart engine, comparisons on both sides of `AND`/`OR` need parentheses**: `condition("(qty>0) AND (price<100)")`; without them parsing fails and `false` is returned.
- On an error `condition()` returns `false` and prints `[ERROR] expression # reason` to the console.

#### `<switch>` / `<case>` / `<default>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

A multi-branch selection structure, matching each `<case>`'s `value` against the `exp` expression.

| Attribute | Required/Optional | Description |
|---|---|---|
| `exp` (`<switch>`) | (required) | The expression to match against |
| `value` (`<case>`) | (required) | The value to match |

**Common child tags:** one or more `<case>`, with an optional trailing `<default>`

```xml
<switch exp="mnu_typ[k]">
  <case value="b"><setvar name="app" value="'book'"/></case>
  <case value="n"><setvar name="app" value="'note'"/></case>
  <case value="p"><setvar name="app" value="'page'"/></case>
  <default><setvar name="app" value="'grid'"/></default>
</switch>
```

**📱 Flutter** (`wapform_lazarus.dart`: `expression()`; `wapform_expression.dart`: `SWITCH()`, `DECODE()`)

```dart
void pickApp() {
  switch ("${expression("mnu_typ[k]")}") {
    case "b":
      setvar("app", "'book'");
      break;
    case "n":
      setvar("app", "'note'");
      break;
    case "p":
      setvar("app", "'page'");
      break;
    default:
      setvar("app", "'grid'");
  }
}
```

When you only map one value to another, a one-line expression is enough: `setvar("app", "SWITCH(mnu_typ[k],'b','book','n','note','p','page','grid')")` (`DECODE()` works the same way).

#### `<while>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

A conditional loop; keeps executing its inner tags while `cnd` is true, commonly used with a dataset's manual `First`/`Next`/`EOF` iteration.

| Attribute | Required/Optional | Description |
|---|---|---|
| `cnd` | (required) | The loop-continuation condition |

```xml
<while cnd="not(mnu.eof)">
  <setvar name="mnu_id[k]" value="mnu.pno"/>
  <invoke instance="mnu" method="next"/>
</while>
```

**📱 Flutter** (`wapform_lazarus.dart`: `condition()`, `invoke()`, `setvar()`)

```dart
void loadMenuIds() {
  setvar("mnu_id", "[0..1023]");
  setvar("k", "0");
  invoke("mnu", "first");
  while (condition("not(mnu.eof)")) {                // <while cnd="not(mnu.eof)">
    setvar("mnu_id[k]", "mnu.pno");
    setvar("k", "k+1");
    invoke("mnu", "next");                           // <invoke instance="mnu" method="next"/>
  }
}
```

If the dataset moved in the loop is bound to screen components, wrap the loop with `invoke("mnu", "disablecontrols")`/`invoke("mnu", "enablecontrols")` so the screen is not redrawn on every row.

#### `<for>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

A counting loop; in the Web environment, commonly used for repeating a layout a fixed number of times (e.g. a row of pagination buttons).

| Attribute | Required/Optional | Description |
|---|---|---|
| `var` | (required) | Loop variable name |
| `from` / `to` | (required) | Start/end values |
| `step` | (optional) | Increment amount, default 1 |

#### `<go/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ✅

Jumps to call a named `<function>` (referenced as `@functionname`) or another card; in the report engine, `<go href="@header"/>` is commonly seen calling a header function. Void element.

| Attribute | Required/Optional | Description |
|---|---|---|
| `href` | (required) | `@function_id`, or a target card/URL |

```xml
<go href="@header"/>
```

#### `<exit/>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

Void element; immediately ends the current `<function>` or flow block, often attached with `cnd` for an early return (see Section 14.4's reentrancy guard in the `UpdateTotal` function).

| Attribute | Required/Optional | Description |
|---|---|---|
| `cnd` | (optional) | Ends only if the condition is true |

```xml
<exit cnd="DeletingItems"/>
```

#### `<function>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

Defines a named flow block that can be called by `<go href="@id">` or an event — equivalent to a named subroutine.

| Attribute | Required/Optional | Description |
|---|---|---|
| `id` | (required) | Function name, referenced as `@id` |

**Common child tags:** any flow-control and data-operation tags

#### `<block/>`

🖥️ **Win** ⚠️ | 🌐 **Web** ✅ | 📱 **Flutter** ❌

Outputs a pre-defined HTML/text fragment; commonly seen in the template system for inserting fixed template blocks by name (e.g. `footer.aa`, `footer.zz`). Void element.

| Attribute | Required/Optional | Description |
|---|---|---|
| `name` | (required) | Template block name |

```xml
<block name="footer.aa"/>
```

#### `<platform>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

Chooses what to run according to the platform, so one `.wml` can take a different implementation on each platform. The Windows/Web engines run only the blocks whose `name` contains their own platform name and skip the rest; the WapForm for Flutter generator copies the `<![CDATA[ ]]>` inside a `name="flutter"` block into the generated `.dart` as Dart code, as is. Typical uses: a feature that has no corresponding tag in Flutter yet (for example image upload with `<open>` + `<webcopy>`), or when two platforms need different code.

**Embedding native code in WML**: `<platform>` + `<![CDATA[ ]]>`

- One `.wml` can carry native code for the target platform directly.
- Flutter (Dart) is supported today; COBOL source is planned to use the same mechanism (`<platform name="cobol">`, in development).
- The CDATA content goes into the generated program as is; everything else stays declarative WML.

| Attribute | Req/Opt | Description |
|---|---|---|
| `name` | (required) | Platform name: `windows`, `web`, `flutter`; several can be listed (e.g. `name="windows,web"`) |
| `part` | (optional) | Only for `name="flutter"`: `import` means the content is Dart `import` statements, placed in the import section at the top of the generated file |

**Common child tags:** ordinary WML tags inside `windows`/`web` blocks; one `<![CDATA[ Dart code ]]>` inside a `flutter` block

A `flutter` block works in three ways depending on where it is placed:

| Position | Generated Dart |
|---|---|
| `part="import"` | Added to the `import` section at the top of the file |
| In a flow such as `<function>` or `<onevent>` | Statements inserted into that function as is; if the content contains `await`, the function automatically becomes `async` |
| In the layout (e.g. `<td>`) | A `Widget` expression inserted into the layout |

**Complete example: `app002.wml` product image upload** (Windows uses `<open>` + `<webcopy>`, Flutter uses `file_picker` + `http`):

```xml
<card id="P" title="Product Master" width="1200">

  <!-- Flutter: the generated file needs two more packages -->
  <platform name="flutter" part="import"><![CDATA[
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
  ]]></platform>

  <!-- pick an image and upload it -->
  <function id="A0">
    <platform name="windows">
      <setvar name="I" value="0"/>
      <setvar name="S" value="''"/>
      <open filename="S" result="I"/>
      <if cnd="I=1">
        <webcopy protocol="httpupload" unique="yes"
                 host="http://localhost:90/xyz/upload.php"
                 url="$S" result="R" errmsg="E"/>
        <if cnd="E=''">
          <setvar name="paicon" value="R"/>
          <invoke instance="pa" method="post"/>
          <else>
            <alert message="Upload failed: $E"/>
          </else>
        </if>
        <go href="@SHOWIMG"/>
      </if>
    </platform>
    <platform name="flutter"><![CDATA[
final f = await FilePicker.pickFile(type: FileType.image);
if (f == null) return;
final bytes = await f.readAsBytes();
final name = '${DateTime.now().millisecondsSinceEpoch}.${(f.extension ?? 'jpg').toLowerCase()}';
try {
  final res = await http.put(
      Uri.parse('http://localhost:90/xyz/upload.php?name=$name'), body: bytes);
  if (res.statusCode == 200) {
    setvar("pa.icon", "'$name'");
    await _saveAsync(_pa);
  } else {
    await _alert("Upload failed: HTTP ${res.statusCode}");
  }
} catch (e) {
  await _alert("Upload failed: $e");
}
    ]]></platform>
  </function>

  <!-- clear the image -->
  <function id="B0">
    <platform name="windows">
      <setvar name="paicon" value="''"/>
      <invoke instance="pa" method="post"/>
      <go href="@SHOWIMG"/>
    </platform>
    <platform name="flutter"><![CDATA[
setvar("pa.icon", "''");
await _saveAsync(_pa);
    ]]></platform>
  </function>

  <!-- show the image: only Windows needs this -->
  <function id="SHOWIMG">
    <platform name="windows">
      <setprop name="g0" prop="img" value="IF(paicon='', 'http://localhost:90/xyz/upload/300x300.jpg', 'http://localhost:90/xyz/upload/'+paicon)"/>
    </platform>
  </function>

  <dbquery id="pa">
    <![CDATA[select * from pa order by pno]]>
    <field fieldname="icon" displaylabel="Icon"/>
    <onevent type="afterscroll">
      <!-- the Flutter screen is redrawn after the cursor moves, so the image follows automatically -->
      <platform name="windows"><go href="@SHOWIMG"/></platform>
    </onevent>
  </dbquery>

  <datasource dataset="pa">
    <table columns="1">
      <tr>
        <td>
          <!-- layout: Windows uses links and <img>, Flutter uses one Widget expression -->
          <platform name="windows">Image | <a href="@A0">Open</a> | <a href="@B0">Clear</a><br/><img id="g0" width="300" height="300"/></platform>
          <platform name="flutter"><![CDATA[
Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Row(mainAxisSize: MainAxisSize.min, children: [
    const Text("Image  "),
    TextButton(onPressed: () async { await _a0(); if (mounted) setState(() {}); },
        child: const Text("Open")),
    TextButton(onPressed: () async { await _b0(); if (mounted) setState(() {}); },
        child: const Text("Clear")),
  ]),
  Image.network(
    _str(_pa, "icon").isEmpty
        ? "http://localhost:90/xyz/upload/300x300.jpg"
        : "http://localhost:90/xyz/upload/${_str(_pa, "icon")}",
    width: 300, height: 300, fit: BoxFit.contain,
    errorBuilder: (_, __, ___) => const Text("No image")),
]),
          ]]></platform>
        </td>
      </tr>
    </table>
    <platform name="windows"><go href="@SHOWIMG"/></platform>
  </datasource>
</card>
```

Points this example shows:

1. **Blocks only one platform needs** (`SHOWIMG`, the `<go>` in `afterscroll`) are written only for `windows`; Flutter simply skips them.
2. **A `flutter` block can use names from the generated file directly**: `<function id="A0">` generates `_a0()`, dataset `pa` is `_pa`, and the generated file has built-in `_saveAsync()` (writes back to the database), `_alert()` and `_str()`; `setvar()` and the like are functions of `wapform_flutter`.
3. **Upload file names are handled the same way**: Windows' `unique` names the file with a timestamp; the Flutter side also builds the file name from a timestamp, received by `upload.php?name=`.
4. `<platform>` can also wrap any piece of WML (not just functions), for example help text shown only on the Web: `<platform name="web"><p>…</p></platform>`.

> **Note:** the content of a `flutter` block goes into the Dart file as is, so syntax errors are found only when Flutter compiles; after changing the `.wml`, regenerate and run `flutter analyze`.

---

### 4.6 Variable and Dataset Operation Tags

#### `<setvar/>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

Declares or assigns a variable — the most frequently used tag in WML; `value` supports the full expression syntax (see Chapter 6), and can be combined with `cnd` for conditional assignment. Void element.

| Attribute | Required/Optional | Description |
|---|---|---|
| `name` | (required) | Variable name |
| `value` | (required) | Expression or literal value |
| `cnd` | (optional) | Assigned only if the condition is true |

```xml
<setvar name="TempTotal" value="TempTotal+sn.Total"/>
<setvar name="mnu_id" value="[0..1023]"/>  <!-- Declares a fixed-length array -->
```

**📱 Flutter** (`wapform_lazarus.dart`: `setvar()`; `wapform_expression.dart`: `WapEvaluator.setVar()`)

```dart
void setvarDemo() {
  setvar("TempTotal", "TempTotal+sn.Total");     // value is an expression
  setvar("mnu_id", "[0..1023]");                 // declare a fixed-length array
  setvar("mnu_id[3]", "mnu.pno");                // write an array element
  setvar("sh.amount", "TempTotal");              // write a dataset field
  if (condition("qty>0")) setvar("OK", "1");     // cnd=
  _ev.setVar("USER_INPUT", "O'Brien");           // store a Dart value as is, not as an expression
}
```

| `name` form | Behavior |
|---|---|
| `X` | Sets a variable |
| `X[i]` | Sets an array element; `i` is an expression, and the array grows automatically (padded with `null`) when too short |
| `ds.field` | If `ds` is registered and open: writes the current record (entering edit mode automatically when browsing); otherwise treated as a variable name |

After `setvar()` changes a variable it notifies the functions in `varChangeHooks` so the screen stays in sync (Section 7.7).

#### `<setprop/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ✅

Dynamically sets a screen component's property value (such as color, visibility, tab index), changing the UI's appearance at runtime based on a condition. Void element.

| Attribute | Required/Optional | Description |
|---|---|---|
| `name` | (required) | Target component id |
| `prop` | (required) | The property name to set (e.g. `enabled`, `Readonly`, `img`, `filter`, `ActivePageIndex`) |
| `value` | (required) | The new property value |
| `cnd` | (optional) | Set only if the condition is true |

```xml
<setprop name="$ID" prop="enabled" value="0" cnd="I=-1"/>
<setprop name="b0" prop="img" value="$(sys.GSWEB+'nopic.jpg')"/>
<setprop name="pagecontrol" prop="ActivePageIndex" value="0"/>
```

#### `<getprop/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ✅

Reads a screen component's current property value into a variable — the counterpart to `<setprop>`. Void element.

| Attribute | Required/Optional | Description |
|---|---|---|
| `name` | (required) | Target component id |
| `prop` | (required) | The property name to read |
| `result` | (required) | Variable name to store the result into |

#### `<invoke/>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

Calls a method on a dataset object (such as `First`/`Next`/`Edit`/`Post`/`GetBookmark`) — the main means of operating a dataset's cursor and transaction state; the full method list is in Section 7.7. Void element.

| Attribute | Required/Optional | Description |
|---|---|---|
| `instance` | (required) | The target dataset's `id` |
| `method` | (required) | Method name |
| `arg1`/`arg2`/`arg3` | (optional) | Method parameters (e.g. `locate`'s key value and match options) |
| `params` | (optional) | Some methods (e.g. `GoToBookmark`) pass in a bookmark variable this way |
| `result` | (optional) | Variable name to store the method's return value into |
| `cnd` | (optional) | Called only if the condition is true |

```xml
<invoke instance="sn" method="GetBookmark" result="BookMark"/>
<invoke instance="sn" method="First"/>
<invoke instance="mnu" method="locate" arg1="'id'" arg2="[pa.gid]" arg3="[loCaseInsensitive,loPartialKey]"/>
<invoke instance="sn" method="GoToBookmark" params="BookMark"/>
```

**📱 Flutter** (`wapform_lazarus.dart`: `invoke(instance, method, {params, result})`)

```dart
void invokeDemo() {
  invoke("sn", "getbookmark", result: "BookMark");     // result=
  invoke("sn", "first");
  invoke("sn", "gotobookmark", params: _ev.getVar("BookMark")); // params=
  if (condition("sn.state<>'BROWSE'")) invoke("sn", "post");    // cnd=
}
```

| `method` | Description |
|---|---|
| `first`/`next`/`prior`/`last` | Move the cursor |
| `edit`/`insert`/`append`/`cancel`/`post`/`delete` | Edit state (`post`/`delete` write back to the dataset; sending to the database is handled by the dataset's update mechanism) |
| `disablecontrols`/`enablecontrols` | Pause/resume screen updates (`beginwalk`/`endwalk` are synonyms) |
| `getbookmark`/`gotobookmark`/`freebookmark` | Bookmarks |

Method names are case-insensitive; if `invoke()` cannot find the dataset it returns `null` and does nothing. `locate` and `refresh` have no corresponding `invoke` method: re-query with `db.query("ds", sql)`.

---

### 4.7 Report Output Tags

#### `<report>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

Iterates over a dataset record by record and outputs content — the core tag for report and Web-layout rendering; combine with `<group>` to build grouped subtotals, and with `<page>` to control pagination.

| Attribute | Required/Optional | Description |
|---|---|---|
| `dataset` | (required) | The `id` of the dataset to iterate |
| `rows` | (optional) | Fixed rows per page, used for automatic pagination in continuous-form reports (see Section 12.11) |
| `dialog` | (optional) | Field(s) the grouping dialog is based on, common in multi-level grouped reports |

**Common child tags:** `<setvar>`, `<group>`, `<page>`

```xml
<report dataset="sh" dialog="cno;sno">
  <group change="sh.cno">
    <setvar name="AMOUNT_SUM" value="0"/>
    <page>...</page>
  </group>
</report>
```

**📱 Flutter** (`wapform_report.dart`: `WapReport`, `WapPage`; `wapform_report_style.dart`; `report_web.dart`)

`<report dataset="sh">` becomes a `WapReport` subclass shown by `WapPage`. Order of execution:

```
initParams() → fetchFirst()
PREFIX → PAGEPREFIX
  ┌ each row: group value changed? → onGroupPrepare() → G1_PREFIX…G9_PREFIX
  │       RECORD → fetchNext()
  │       group value of next row changed? → fetchPrior() → G9_SUFFIX…G1_SUFFIX → fetchNext()
  └ every wapLpp lines (counted by emitRow) → PAGESUFFIX → PAGEBREAK → PAGEPREFIX
SUFFIX of the last group → PAGESUFFIX → SUFFIX
```

| Subclass implements | Description |
|---|---|
| `initParams()` | `wap.wapLpp` (lines per page), `wap.wapGroups` (number of group levels, up to 9), `wap.wapRow[i].tagPrefix`/`tagSuffix` (block names of level i) |
| `expression(int idx)` | The value of group level idx; when it changes a new group starts (corresponds to `<group change>`) |
| `fetchFirst()`/`fetchNext()`/`fetchPrior()` | How data is read, usually `invoke()` + `condition("ds.EOF")` |
| `parseBlock(String id)` | What each block outputs |
| `onGroupPrepare()` | (optional) Asynchronous preparation before a group changes, e.g. querying that group's summary first |

| Callable | Description |
|---|---|
| `emitRow(html, {isHeader, isFooter})` | Outputs one line and counts it; at `wapLpp` it breaks the page automatically and reprints `PAGEPREFIX` |
| `emit(text, {isHeader, isFooter, tag})` | Outputs without counting lines (table opening, closing) |
| `forcePageBreak()` | Forces a page break |
| `buildHtml()` | The whole report as HTML |
| `buildPdf({orient, paper, fontAsset})` | Produces a PDF (Android); on the Web it opens a new tab to print instead |

> **Note:** `WapReport` has its own `expression(int idx)` method, which shadows the top-level `expression()` of `wapform_lazarus.dart`. To evaluate an expression inside a report class, use `expandText(r"$(...)")`, `condition()`, or `currentEvaluator!.eval("...")`.

On the Web, `WapPage` previews in an iframe and prints by opening a new tab for the browser (`openHtmlForPrint()` in `report_web.dart`); on Android it previews with the system WebView and prints by producing a PDF. Screen and print styles come from `reportCssScreen`/`reportCssPrint` in `wapform_report_style.dart`. For the condition input of `dialog="cno;sno"`, Flutter uses `WapFilter` to get the conditions, queries the dataset, then opens the report.

#### `<group>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

A grouping block inside `<report>`/`<crosstab>`. Without a `change` attribute, it means record-by-record output (a RECORD block); with `change`, this block is only re-entered when that expression's value changes — commonly used for grouped subtotals and automatic page breaks.

| Attribute | Required/Optional | Description |
|---|---|---|
| `change` | (optional) | The grouping expression; re-triggers only when its value changes |

**Common child tags:** `<setvar>`, an inner `<group>` (multi-level grouping), arbitrary output content

```xml
<group change="sh.cno">
  <setvar name="AMOUNT_SUM" value="0"/>
  <group change="datetostr(sh.sdate)">
    <group>
      <tr>...</tr>
    </group>
  </group>
</group>
```

**📱 Flutter** (`wapform_report.dart`: `expression(idx)`, `G1_PREFIX`/`RECORD`/`G1_SUFFIX`)

`<group change="sh.cno">` is level 1, `<group change="datetostr(sh.sdate)">` is level 2, and the innermost `<group>` without `change` is `RECORD`:

```dart
class StatementReport extends WapReport {
  @override
  void initParams() {
    wap.wapLpp = 60;
    wap.wapGroups = 2;
    wap.wapRow[0].tagPrefix = 'G1_PREFIX';
    wap.wapRow[0].tagSuffix = 'G1_SUFFIX';
    wap.wapRow[1].tagPrefix = 'G2_PREFIX';
    wap.wapRow[1].tagSuffix = 'G2_SUFFIX';
  }

  @override
  String expression(int idx) {
    switch (idx) {
      case 0:
        return expandText(r'$(sh.cno)');                 // <group change="sh.cno">
      case 1:
        return expandText(r'$(datetostr(sh.sdate))');    // <group change="datetostr(sh.sdate)">
    }
    return '';
  }

  @override
  Future<bool> fetchFirst() async {
    invoke("sh", "first");
    return !condition("sh.EOF");
  }

  @override
  Future<bool> fetchNext() async {
    invoke("sh", "next");
    return !condition("sh.EOF");
  }

  @override
  Future<void> fetchPrior() async => invoke("sh", "prior");

  @override
  void parseBlock(String id) {
    switch (id) {
      case 'PAGEPREFIX':
        emit('<table class="wap" width="100%">');
        break;
      case 'G1_PREFIX':
        setvar("AMOUNT_SUM", "0");
        emitRow(expandText(r'<tr><th colspan="3">$(sh.cname)</th></tr>'), isHeader: true);
        break;
      case 'G2_PREFIX':
        setvar("DAY_SUM", "0");
        break;
      case 'RECORD':
        setvar("AMOUNT_SUM", "AMOUNT_SUM+sh.amount");
        setvar("DAY_SUM", "DAY_SUM+sh.amount");
        emitRow(expandText(r"<tr><td>$(sh.sdate)</td><td>$(sh.sno)</td>"
            r"<td align='right'>$(FORMAT('%.0n',sh.amount))</td></tr>"));
        break;
      case 'G2_SUFFIX':
        emitRow(expandText(r"<tr><td colspan='2'>Day total</td>"
            r"<td align='right'>$(FORMAT('%.0n',DAY_SUM))</td></tr>"), isFooter: true);
        break;
      case 'G1_SUFFIX':
        emitRow(expandText(r"<tr><td colspan='2'>Subtotal</td>"
            r"<td align='right'>$(FORMAT('%.0n',AMOUNT_SUM))</td></tr>"), isFooter: true);
        break;
      case 'PAGESUFFIX':
        emit('</table>');
        break;
    }
  }
}

Future<void> showStatement() async {
  await db.query("sh", "select * from sh order by cno, sdate");   // sort by the group fields
  if (!mounted) return;
  await Navigator.push(context, MaterialPageRoute(
    builder: (_) => WapPage(title: "A/R Statement", report: StatementReport()),
  ));
}
```

When the group changes, the engine first goes back to the last row of the previous group with `fetchPrior()` and then outputs `G?_SUFFIX`, so `sh.cname` in the subtotal line is still the previous group's customer.

#### `<newpage/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ (the Web uses paging buttons / URL parameters instead of physical page breaks) | 📱 **Flutter** ✅

Void element, forces a page break; commonly seen for manually controlling page-break logic in fixed-row-count continuous reports (see Section 14.7). No attributes.

**📱 Flutter** (`wapform_report.dart`: `forcePageBreak()`)

```dart
// part of a WapReport subclass's parseBlock(): each customer starts on a new page
void newPageDemo(String id) {
  if (id == 'G1_PREFIX' && condition("not(cu.bof)")) forcePageBreak(); // <newpage cnd="not(cu.bof)"/>
}
```

`forcePageBreak()` outputs `PAGESUFFIX` → `PAGEBREAK` → `PAGEPREFIX` in order; if the page has no detail yet, no blank page is produced. Normally you need no manual page breaks: `emitRow()` breaks the page automatically after `wap.wapLpp` lines.

#### `<varblock/>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

Accumulates HTML into a named variable piece by piece, inserted all at once at the end of the template with `$(varname)` — an alternative to incremental output (see Chapter 9's pre-accumulated varblock injection). Void element.

| Attribute | Required/Optional | Description |
|---|---|---|
| `name` | (required) | The accumulator variable name |
| `block` | (required) | The name of the content block to accumulate |

```xml
<report dataset="mnu">
  <varblock name="footer" block="footer.aa"/>
  <varblock name="footer" block="footer-item"/>
  <varblock name="footer" block="footer.zz"/>
</report>
```

#### `<debug/>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ⚠️

A development-time helper tag that outputs the report engine's current coordinates and accumulator state (e.g. `$row,$col;$K,$(X[K])`); should be removed before release. No attributes.

**📱 Flutter** (`wapform_expression.dart`: `getUserVars()`, `hasError`/`lastError`; `wapform_lazarus.dart`: `DataSetRegistry.registeredIds`)

```dart
void debugDump() {
  debugPrint(expandText(r"$K,$(X[K])"));         // the given values
  debugPrint("${_ev.getUserVars()}");            // all user variables
  debugPrint("datasets: ${_reg.registeredIds}"); // registered datasets
  _ev.eval("1>0 AND 2>1");
  if (_ev.hasError) debugPrint(_ev.lastError);   // why the expression failed
}
```

When `expression()`/`condition()` fail they print `[ERROR] expression # reason` to the console automatically.

---

### 4.8 Crosstab and Chart Tags

#### `<crosstab>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ❌

A declarative crosstab (pivot analysis); describes complex reports using row groups, column groups, and cross-cell aggregation, replacing an external reporting tool — see Chapter 13 for details.

| Attribute | Required/Optional | Description |
|---|---|---|
| `dataset` | (required) | Source dataset |
| `field` | (required) | The numeric field being cross-aggregated |
| `dialog` | (optional) | Field(s) the dialog is based on |
| `autospan` | (optional) | `yes` automatically merges header cells with the same group value |

**Common child tags:** `<row change>`, `<col change>`, an inner `<group>`

```xml
<crosstab dataset="xy" dialog="cno;sdate" field="amount" autospan="yes">
  <row change="xy.cno">...</row>
  <col change="xy.YM">...</col>
</crosstab>
```

#### `<row>` / `<col>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ❌

Define the row group and column group respectively inside `<crosstab>`; the `change` attribute has the same semantics as `<group change>` and can be nested multiple levels deep.

| Attribute | Required/Optional | Description |
|---|---|---|
| `change` | (optional) | The grouping expression |

#### `<chart>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ (the Web usually uses a front-end chart library such as Chart.js instead) | 📱 **Flutter** ❌

Declarative chart output, letting developers produce interactive charts without writing JavaScript; complete attributes are in Section 10.3.

| Attribute | Required/Optional | Description |
|---|---|---|
| `title` | (optional) | Chart title text |
| `dataset` | (optional) | Bound dataset name (dataset-driven mode) |
| `rangeto` | (optional) | Maximum axis scale value |
| `legend` | (optional) | `yes` shows the legend |
| `autocolor` | (optional) | `yes` automatically applies a different color to each data point |
| `xaxisposition` / `yaxisposition` | (optional) | Axis display position; `none` hides it |
| `titlefontsize` | (optional) | Title font size (points) |
| `xresult` | (optional) | Stores the chart's output result into the specified variable |

**Common child tags:** one or more `<serie>`

#### `<serie>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ❌

Defines a single data series inside `<chart>`; complete attributes are in Section 10.4.

| Attribute | Required/Optional | Description |
|---|---|---|
| `type` | (required) | Chart type, 12 in total (complete examples in Section 10.6): line-type `line`/`digitalline`; bar-type `bar`/`stackedbar`/`histogram`; area-type `area`/`stackedarea`; pie-type `pie`/`donut`/`sizedpie`/`sizeddonut`; radar-type `spider` |
| `title` | (optional) | Series name (shown in the legend) |
| `color` | (optional) | Fill color (`#RRGGBB`) |
| `linecolor` / `linewidth` | (optional) | Line color/width (line type) |
| `opacity` | (optional) | Opacity 0–255 (area type) |
| `marker` | (optional) | `yes` shows data-point markers (line type) |
| `valuewidth` | (optional) | Data-point width (bar type) |
| `fieldnamevalue` / `fieldnamexaxis` | (optional) | Value/X-axis field for dataset-driven mode |
| `pielegend`/`pieposition`/`pieleft`/`pietop`/`piesize`/`pieshowvalues`/`pieshowlegendonslice`/`pievalueposition` | (optional) | Attributes specific to pie/donut types |

**Common child tags:** one or more `<point>` (programmatic-generation mode)

#### `<point/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ❌

A single data point inside `<serie>`, typically generated dynamically inside a `<while>` or `<for>` loop. Void element.

| Attribute | Required/Optional | Description |
|---|---|---|
| `label` | (required) | X-axis label or legend name; supports expressions |
| `value` | (required) | Y-axis value; supports expressions |
| `color` | (optional) | Individual data-point color |

```xml
<chart title="line" rangeto="11" legend="yes">
  <serie type="line" linecolor="#f37735" linewidth="2" marker="yes">
    <point label="Jan" value="120"/>
    <point label="Feb" value="95"/>
  </serie>
</chart>
```

---

### 4.9 Navigation and Menu Tags

#### `<include/>`

🖥️ **Win** ⚠️ | 🌐 **Web** ✅ | 📱 **Flutter** ⚠️

Includes the output of another named card — the core mechanism for shared Web-template components (`header`/`footer`/`asider`); see Chapters 9 and 15 for details. Void element.

| Attribute | Required/Optional | Description |
|---|---|---|
| `name` | (required) | The target card's `id` |

```xml
<include name="header"/>
```

#### `<redirect/>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

Void element; redirects to another URL or `.wml`, commonly used after login validation fails or at the end of a flow.

| Attribute | Required/Optional | Description |
|---|---|---|
| `href` | (required) | The target URL or `.wml` |

```xml
<redirect href="index.wml"/>
```

#### `<mainmenu>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

Defines the menu bar of the Windows MDI main window, typically appearing in the main card with `device="MDI"`.

| Attribute | Required/Optional | Description |
|---|---|---|
| `images` | (optional) | The name of the menu icon list (imagelist) source |

**Common child tags:** one or more `<menuitem>` (can nest to represent submenus)

#### `<menuitem>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

A menu item under `<mainmenu>`; can be nested to build multi-level menus.

| Attribute | Required/Optional | Description |
|---|---|---|
| `name` | (optional) | Component id, for dynamic control (e.g. disabling) via `<setprop>` |
| `caption` | (required) | Display text; supports expressions |
| `hint` | (optional) | Hint text or a category marker |
| `imageindex` | (optional) | Index into the `images` icon list |
| `onclick` | (optional) | The target to navigate to on click (e.g. the `href` corresponding to the menu item) |

**Common child tags:** an inner `<menuitem>` (submenu)

```xml
<mainmenu images="imagelist1">
  <menuitem caption="Sales Operations" hint="sub">
    <menuitem name="A001" caption="Shipment Entry" hint="app006.wml"
              imageindex="1" onclick="app006.wml"/>
  </menuitem>
</mainmenu>
```

#### `<tabsheet>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ (the Web implements it by hand with Bootstrap tab components) | 📱 **Flutter** ✅

A tab container, commonly seen in multi-tab search forms or for switching between different view modes on a data-entry page.

| Attribute | Required/Optional | Description |
|---|---|---|
| `caption` | (required) | Tab title |

**Common child tags:** any layout and input tags (the content of that tab)

#### `<pagecontrol>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ✅

The outer container for `<tabsheet>`, managing switching between multiple tabs; can be combined with `<setprop prop="ActivePageIndex">` to dynamically switch the currently displayed tab.

**Common child tags:** one or more `<tabsheet>`

---

### 4.10 System Integration Tags

#### `<mail>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ (Windows uses `<shellexecute>` with a `mailto:` link instead, see Section 14.9) | 📱 **Flutter** ❌

Sends email directly from the server side, requiring no locally installed mail software on the user's machine.

| Attribute | Required/Optional | Description |
|---|---|---|
| `to` | (required) | Recipient |
| `subject` | (optional) | Subject |
| `body` | (optional) | Body |

#### `<shellexecute/>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

Calls an external program or protocol at the operating-system level, commonly used to open the default mail application (`mailto:`) or launch an external application. Void element.

| Attribute | Required/Optional | Description |
|---|---|---|
| `operation` | (required) | Usually `open` |
| `file` | (required) | Target path or protocol URL |

```xml
<shellexecute operation="open" file="mailto:$(cu.email)?subject=Shipment Notification"/>
```

#### `<webcopy/>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

Moves files between the local file system, HTTP and FTP according to the `protocol` attribute; it is the only built-in file transfer mechanism on the Windows side, commonly paired with `<open/>` for a "choose file → upload" image management flow. Empty element. See Chapter 12 for the full protocol behavior, the `host`/`url`/`dir` table and worked examples.

| Attribute | Required/Optional | Description |
|---|---|---|
| `protocol` | (opt., default `file`) | One of `file`/`httpupload`/`httpdownload`/`ftpupload`/`ftpdownload` |
| `host` | Depends on protocol | Meaning changes with `protocol` (target directory / target URL / source URL / FTP host) |
| `url` | Depends on protocol | Meaning changes with `protocol` (source path / local file path / file name on FTP) |
| `dir` | Depends on protocol | Meaning changes with `protocol` (storage directory / directory on FTP); not used by the `file`/`httpupload` protocols |
| `username` / `password` | Required for FTP | FTP login account and password |
| `unique` | (opt.) | Its presence means `true`: names the file from a timestamp, adds a sequence number on a name clash, never overwrites an existing file |
| `result` | (opt.) | On success receives the saved / uploaded file name; on failure the error message |
| `errmsg` | (opt.) | On failure receives the error message; cleared to an empty string on success |
| `response` | (opt., `httpupload` only) | Receives the raw content of the server response |

#### `<open/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ⚠️

Has two completely different uses depending on the attribute combination; the attributes cannot be mixed:

| Use | Attributes | Platforms | Description |
|---|---|---|---|
| Pop up another card | `href` (req.) | 🖥️ **Win** ✅ \| 🌐 **Web** ⚠️ \| 📱 **Flutter** ⚠️ | Opens another card as a pop-up window; `href` is the target card's `id` (often written `#id`); unlike `<include>`, it creates a separate window/dialog instead of embedding the output |
| System file-selection dialog | `filename` (req.), `result` (req.) | 🖥️ **Win** ✅ \| 🌐 **Web** ❌ \| 📱 **Flutter** ⚠️ | Pops up the operating system's native "Open" dialog; `filename` receives the full path the user picked, `result` whether the user confirmed (`1` = confirmed); see Section 12.1 of Chapter 12 |

#### `<upload/>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

Receives a raw HTTP `PUT` request on the server and saves it: the entire request body is the file's bytes, with no multipart wrapper and no file name, compatible with the way a traditional `upload.php` receives files. Empty element. See Section 11.2 of Chapter 11 for the full file-naming order, Content-Type inference and security mechanisms.

| Attribute | Required/Optional | Description |
|---|---|---|
| `destination` | (req.) | Storage directory |
| `filename` | (opt.) | Fixed file name; when empty it is determined by the `Content-Disposition` header or a timestamp |
| `accept` | (opt.) | Whitelist of allowed extensions, comma-separated; empty means no restriction |
| `unique` | (opt.) | With `yes`, a sequence number is added automatically on a name clash to avoid overwriting (same as `nameconflict="unique"`) |
| `result` | (opt.) | The variable that receives the error message / status |
| `size` | (opt.) | The variable that receives the number of bytes received |
| `savedname` | (opt.) | The variable that receives the file name actually saved |

#### `<multiupload>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

Receives on the server the multi-file upload request sent by a browser `<form enctype="multipart/form-data">`; a container element whose child nodes run once for every file saved, so the page can show a thumbnail or write a database record per file. See Section 11.1 of Chapter 11 for the complete example and engine rules.

| Attribute | Req./Opt. | Description |
|---|---|---|
| `filefield` | (req.) | The field name of the corresponding `<input type="file" name="...">` |
| `destination` | (req.) | Storage directory |
| `filename` | (req.) | The variable that receives the saved file name (updated per file inside the loop) |
| `srcname` | (opt.) | The variable that receives the original file name on the user's side |
| `index` | (opt.) | The variable that receives the number of the current file (starting at 1) |
| `count` | (opt.) | The variable that receives, after the upload, the total number of files saved |
| `result` | (opt.) | The variable that receives the error message; an empty string when everything succeeded |
| `accept` | (opt.) | Whitelist of allowed extensions, comma-separated; empty means no restriction |
| `nameconflict` | (opt.) | Name-clash strategy; `unique` adds a timestamp and sequence number automatically to avoid overwriting |

---

### 4.11 Web-Only Tags

#### `<wap>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

A container in the Web environment that outputs raw HTML/text content directly; `$()` interpolation expressions can be used inside it, commonly seen in content cards for AJAX partial loading (see `book-js.wml` in Section 15.5).

**Common child tags:** usually wraps a block of HTML in `<![CDATA[ ]]>`

```xml
<wap><![CDATA[
  $pa.topic
  <div>$pa.pno</div>
]]></wap>
```

**📱 Flutter** (`wapform_report.dart`: `WapPage(src:)`; `wapform_lazarus.dart`: `expandText()`)

```dart
Widget wapBlock() => WapPage(
      title: "Topic",
      src: r'$pa.topic <div>$pa.pno</div>',      // expandText() first, then shown as HTML
      showPrint: false,
    );
```

`src` goes through `expandText()`; to output a literal `$` write `$$`.

#### `<session/>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

The tag that writes server-side Session state, with syntax matching `<setvar>`; empty element. It keeps values that must survive across page requests, such as the user's login state and the shopping-cart serial number. `<setsession>` is an alias of the same tag with exactly the same behavior.

| Attribute | Required/Optional | Description |
|---|---|---|
| `name` | (required) | Session variable name |
| `value` | (req.) | The value to write. **Setting it to an empty string `''` deletes the variable** |
| `expire` | (opt.) | The lifetime of this one variable, in **minutes**. Omitted = no expiry of its own, it follows the lifetime of the whole session; `expire="0"` = clears an existing expiry. **Requires an engine version from 2026-09 or later**; older versions ignore this attribute (same as omitting it) |
| `cnd` | (opt.) | Condition; the write happens only when it holds |

```xml
<session name="usr" value="A"/>              <!-- A is the account the user entered -->
<session name="ord" value="''"/>             <!-- clear the shopping-cart serial number -->
<session name="usr" value="A" expire="480"/> <!-- expires automatically after 8 hours -->
<session name="lang" value="'tw'" cnd="DEFINE(request.lang)"/>
```

The read side does not use the `<session>` tag — instead, it's read in an expression with the `session.field` prefix (e.g. `session.usr`, `session.ord`), the same style as the `sys.*`, `request.*` property prefixes — see Section 7.4 for details.

**Per-variable expiry: the `expire` attribute**

Each variable in the same session can have its own lifetime. On every HTTP request the engine removes expired variables **before** parsing the card — so `DEFINE(session.xxx)` in the card simply no longer sees an expired value, and no page has to check for a time-out itself.

```xml
<!-- login state for 8 hours; the shopping-cart scratch value only 2 hours -->
<session name="usr" value="A"   expire="480"/>
<session name="ord" value="S"   expire="120"/>

<!-- to extend it later, write the same variable again; the expiry is recalculated from now -->
<session name="usr" value="session.usr" expire="480"/>
```

Common conversions: `60` = 1 hour, `480` = 8 hours, `1440` = 1 day, `10080` = 7 days, `43200` = 30 days.

When a variable is deleted with `<delsession>`, its expiry stamp is removed too; `<clearsession>`, which clears the whole session, naturally includes it.

**The three lifetimes of a session**

`expire` can only make a variable expire "earlier"; above it are two upper limits that WML cannot break through:

| Layer | Controlled by | Default | Behavior |
|---|---|---|---|
| Session variable | `<session expire="minutes"/>` | No expiry | Timed per variable, deleted when it expires |
| Browser cookie | Server setting | Expires when the browser closes | Decides how long the user can "come back" |
| Server session | Server setting | Reclaimed after 7 idle days | Reclaimed only after **idle** time-out; every request resets the timer |

Session data lives in server memory, so **everything disappears when the server restarts**. Setting `expire` longer than the cookie or the server reclaim time is therefore pointless — the user is signed out first because the cookie expired or the session was reclaimed; design backwards from the shortest layer.

#### `<operator>`

🌐 **Web** ✅ | 🖥️ **Win** ⚠️ | 📱 **Flutter** ❌

A computation helper tag in Web templates, used to pass simple computation results between template blocks, reducing the need to embed too many `$()` expressions inside HTML.

---

### 4.12 HTML Text and Layout Tags

📱 **Flutter**: none of the tags in this section apply (❌). WapForm for Flutter exports a native Dart/Flutter widget tree without going through HTML; the embedded HTML tags listed in this section exist only in the Web version's output and in HTML template files, so the tables below do not repeat the marker for each tag.

WML's output content (whether inside `<wap>`, `<varblock>`, a report cell, or descriptive text inside `<fieldset>`) can directly embed standard HTML tags. Below are the common tags actually used throughout this book, organized by purpose.

#### Text Effect Tags (inline)

| Tag | Description |
|---|---|
| `<b>...</b>` | Bold |
| `<i>...</i>` | Italic |
| `<u>...</u>` | Underline |
| `<small>...</small>` | Smaller text, commonly used for notes or units |
| `<big>...</big>` | Larger text |
| `<ins>...</ins>` | Annotation/emphasis of inserted content, commonly used to mark changes in remark fields |
| `<span class="...">...</span>` | Inline container, no default styling, appearance controlled via `class` or `style` |
| `<br/>` | Forces a line break, void element |
| `<hr/>` | Horizontal divider, void element |

```xml
<p>Unit Price: <b>$(FORMAT('%.2n',od.price))</b>　<small>(tax excluded)</small></p>
<span class="text-danger">Overdue, not yet collected</span><br/>
```

#### Layout Container Tags (block)

| Tag | Common Attributes | Description |
|---|---|---|
| `<div class="...">...</div>` | `class`, `id`, `style` | Block container, the main container for sectioning a Web layout |
| `<section style="...">...</section>` | `style`, `class` | HTML5 semantic block container, often paired with a `$()` expression to dynamically compute `style` (see the `var()`/`inc()` cross-block state functions in Section 9.10) |
| `<p align="...">...</p>` | `align` | Paragraph |
| `<article>...</article>` | — | Semantic content block, used for manual/article body text (see the manual body text in Section 15.5) |
| `<h1>...</h1>` through `<h6>...</h6>` | — | Heading levels; the smaller the number, the larger the text |

```xml
<div class="card p-3">
  <h4>Customer Information</h4>
  <p align="left">$(cu.cname)</p>
</div>

<!-- section paired with var()/inc() to produce a cycling background color -->
<section style="background-color:$('#'+COLOR2HEX(color[inc('idx',1) mod 5]));">
  ...
</section>
```

#### Table Tags

| Tag | Common Attributes | Description |
|---|---|---|
| `<table>...</table>` | `class`, `width`, `border`, `cols`, `columns`, `rows` | Table container; `rows` is commonly used for a fixed row count in continuous reports (see Section 14.7) |
| `<tr>...</tr>` | — | Table row |
| `<th>...</th>` | `align`, `width` | Header cell |
| `<td>...</td>` | `align`, `valign`, `class`, `width`, `colspan`, `rowspan` | Data cell; `colspan`/`rowspan` are used for merging cells (see the cross-column totals in Section 12.11) |

```xml
<table class="wap" width="100%" border="1" rows="40">
  <tr>
    <th>Order No.</th><th>Amount</th>
  </tr>
  <tr>
    <td>$(rpt_data.work_order_no)</td>
    <td align="right">$(FORMAT('%.2n',rpt_data.order_price))</td>
  </tr>
  <tr>
    <td colspan="4">Prepared by: $aa.prepared_by</td>
  </tr>
</table>
```

**📱 Flutter** (`wapform_report.dart`, `wapform_report_style.dart`, `wapform_colors.dart`)

Reports and `WapPage(src:)` output HTML, so the `<table>`/`<tr>`/`<td>` tags in this section are used as usual, and the `class="wap"` format is supplied by `wapform_report_style.dart` (screen `reportCssScreen`, print `reportCssPrint`). For alternating row colors such as `class="row1"`/`"row2"`, Flutter screens can get the same colors from `WapColors`:

```dart
Future<Color> stripe(int i) async {
  await WapColors.load();                        // reads the CSS in assets/wapform.htm; falls back to built-in defaults
  return i.isEven ? WapColors.trRow1 : WapColors.trRow2;  // or WapColors.flutter("row2")
}
```

`WapColors.hex("row2")` returns the CSS color code, which can be written straight into report HTML.

#### List Tags

| Tag | Description |
|---|---|
| `<ul>...</ul>` | Unordered list container |
| `<ol>...</ol>` | Ordered list container |
| `<li>...</li>` | List item, must be a child of `<ul>`/`<ol>` |

```xml
<ul>
  <li>$(itm.title)</li>
</ul>
```

#### Link and Media Tags

| Tag | Common Attributes | Description |
|---|---|---|
| `<a href="...">...</a>` | `href`, `class`, `op`, `pg`, `gp`, `az` | Hyperlink; Web menu/pagination links often carry custom query parameters after `href` (`op`, `pg`, `gp`, `az`), e.g. a pagination link `shop.wml?op=$op&gp=$gp&pg=$K&az=$az` |
| `<img src="..." />` | `src`, `width`, `height`, `border`, `id` | Image, void element; `src` is often combined with `sys.GSWEB`/`sys.images` to assemble the full path |
| `<link rel="..." href="..." />` | `rel`, `href` | External stylesheet or resource link, used in an HTML template's `<head>` |
| `<script>...</script>` | `src` (external) or inline JS | Embeds or loads JavaScript, such as the definition and call of `loadDoc()` (see Section 15.5) |

```xml
<a href="javascript:loadDoc('book-js.wml?pg=$itm.pno')">$itm.des</a>
<img src="$(sys.GSWEB+pa.pic1)" width="120" border="0"/>
```

#### Document Structure Tags (used only in Web HTML templates)

| Tag | Description |
|---|---|
| `<html>...</html>` | HTML document root container |
| `<head>...</head>` | Document header, containing `<title>`, `<link>`, `<script>` |
| `<body>...</body>` | Document body |
| `<title>...</title>` | Browser title-bar text |

These tags only appear in the Web version's HTML template file itself (e.g. `wapform.html`); a regular `.wml` card's output content is embedded into the template's existing `<body>` block, and doesn't need to declare these again.

---

### 4.13 Tag Quick Reference

| Category | Tags |
|---|---|
| Document and layout | `wml`, `card`, `page`, `section`, `fieldset` |
| Data access | `dbquery`, `dbtable`, `field`, `dbfilter` |
| Data binding and lists | `datasource`, `dbgrid`, `item`, `navigator`, `column` |
| Form input and interaction | `input`, `do`, `prev`, `alert`, `prompt` |
| Flow control | `if`/`elseif`/`else`, `switch`/`case`/`default`, `while`, `for`, `go`, `exit`, `function`, `block`, `platform` |
| Variable and dataset operations | `setvar`, `setprop`, `getprop`, `invoke` |
| Report output | `report`, `group`, `newpage`, `varblock`, `debug` |
| Crosstab and charts | `crosstab`, `row`, `col`, `chart`, `serie`, `point` |
| Navigation and menus | `include`, `redirect`, `mainmenu`, `menuitem`, `tabsheet`, `pagecontrol` |
| System integration | `mail`, `shellexecute`, `webcopy`, `open`, `upload`, `multiupload` |
| Web-only | `wap`, `session`, `operator` |
| HTML text effects | `b`, `i`, `u`, `small`, `big`, `ins`, `span`, `br`, `hr` |
| HTML layout containers | `div`, `p`, `article`, `h1`–`h6` |
| HTML tables | `table`, `tr`, `th`, `td` |
| HTML lists | `ul`, `ol`, `li` |
| HTML links and media | `a`, `img`, `link`, `script` |
| HTML document structure (template files only) | `html`, `head`, `body`, `title` |

For the complete usage context and real examples of each tag, cross-reference with Chapter 3's core patterns and the case studies in Chapters 11–16.

📱 **Flutter support overview** (marked tag by tag in the sections above; see "Platform Support Notation" for the basis): only two groups are entirely unsupported — **crosstabs** (`crosstab`/`row`/`col`) and **charts** (`chart`/`serie`/`point`), which no paid edition supports because of the presentation limits of mobile devices; the **Web-only tags** (`wap`, `session`, `operator`), the system integration tags that exist only in the Web version (`mail`, `upload`, `multiupload`) and the template mechanism (`varblock`, `redirect`, `block`) are not supported either, because Flutter exports the Windows component model rather than the Web template mechanism; all other core capabilities — forms, data, master-detail structures, Lookup, calculated fields, events, dynamic queries, report grouping and pagination, multiple tabs — are supported; a few Windows-desktop-specific tags, or tags this manual could not confirm from the website's information (such as `column`, `prompt`, `debug`, `mainmenu`/`menuitem`, `include`, `shellexecute`, `webcopy`, `open`), are marked ⚠️ — rely on what `wapform_flutter` produces for the actual behavior.

**📱 Flutter module map** (only tags with a corresponding module)

| Tag | Module | API |
|---|---|---|
| `card` (`device="PRV"`/`"PRN"`), `page` | `wapform_report.dart` | `WapPage`, `PAGEPREFIX`/`PAGESUFFIX` |
| `dbquery`, `dbtable` | `wapform_lazarus.dart` | `DbQuery.query()`/`exec()`, `DataSetRegistry` |
| `dbfilter`, `item` (filter) | `wapform_filter.dart` | `WapFilter`, `FilterItem` |
| `input lookup`, `item lookup` | `wapform_lookup_box.dart` | `WapLookupBox` |
| `if`, `switch`, `while` | `wapform_lazarus.dart` | `condition()`, `expression()` |
| `setvar`, `invoke` | `wapform_lazarus.dart` | `setvar()`, `invoke()` |
| `report`, `group`, `newpage` | `wapform_report.dart` | `WapReport`, `expression(idx)`, `forcePageBreak()` |
| `debug` | `wapform_expression.dart` | `getUserVars()`, `lastError` |
| `wap` | `wapform_report.dart` | `WapPage(src:)` |
| `platform` | (generator) | A `name="flutter"` block becomes Dart code as is |
| `$(...)` interpolation | `wapform_lazarus.dart` | `expandText()`, `expandSql()`, `expandSqlAuto()`, `expandSqlQuoted()` |

---

---

## Chapter 5　Arrays

## 5.1 Declaration

A WapForm array is a special Variant value set with `<setvar>`; there are three declaration syntaxes:

### Range Declaration (Pre-allocated, Fixed Length)

```xml
<!-- Integer range, elements initialized to 0 -->
<setvar name="X" value="[1..999]"/>
<setvar name="P" value="[0..1023]"/>
<setvar name="L" value="[1..26]"/>
```

Once declared, the array can be accessed as `X[i]`; the lower bound is the range's starting value (`1` or `0`), and `low(X)` / `high(X)` return the lower/upper bound.

### Literal Declaration (Directly Specifying Initial Contents)

```xml
<!-- Integer array -->
<setvar name="L" value="[31,28,31,30,31,30,31,31,30,31,30,31]"/>

<!-- String array -->
<setvar name="P" value="['COD','Pickup','Monthly','Wire Transfer']"/>

<!-- Color-code array -->
<setvar name="C" value="['#ffeeee','#fff4ea','#ffffe3','#ebffec','#f1f4ff']"/>

<!-- Numeric array -->
<setvar name="myArray" value="[1, 2, 3, 4, 5]"/>
```

A literal array's lower bound is `0`, and the upper bound is the element count minus one.

### Empty-Value Arrays

```xml
<!-- All empty strings -->
<setvar name="VR" value="['','','','','','','','','','','','','','','']"/>

<!-- All zeros -->
<setvar name="XV" value="[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"/>
```

**📱 Flutter** (`wapform_lazarus.dart`: `setvar()`; `wapform_expression.dart`: `WapEvaluator.setVar()`)

The three declaration forms are written as is inside `setvar()`; a `List` you already have in Dart goes into the engine with `_ev.setVar()`:

```dart
void declareArrays() {
  setvar("X", "[1..999]");                                        // range declaration, initial value 0
  setvar("L", "[31,28,31,30,31,30,31,31,30,31,30,31]");          // literal
  setvar("P", "['COD','Pickup','Net30','Transfer']");
  setvar("VR", "['','','','','']");                               // array of empty values
  _ev.setVar("N", [10, 20, 30]);                                  // a Dart List
}
```

Dart arrays start at 0: the range declaration `[1..26]` creates 27 elements with indexes 0–26. Indexes that started at 1 still work as before, but `LOW(X)` returns 0.

---

## 5.2 Access

### Reading an Element

```xml
<!-- Indexing directly in an expression -->
<setvar name="days" value="L[month-1]"/>
<td>$(C[i MOD 5])</td>
<setvar name="sp" value="spec[j]"/>

<!-- Interpolating in output -->
<p>First element: $(myArray[0])</p>
<p>Third element: $(myArray[2])</p>
```

### Writing an Element

```xml
<setvar name="X[K]" value="X[K]+N"/>
<setvar name="C[0]" value="'#ffeeee'"/>
<setvar name="mnu_title[k]" value="mnu.title"/>
```

The index can be any integer expression, including variables and function return values.

**📱 Flutter** (`wapform_lazarus.dart`: `expression()`, `setvar()`, `expandText()`)

```dart
void arrayAccess() {
  setvar("days", "L[month-1]");
  final td = expandText(r"<td>$(C[i MOD 5])</td>");
  setvar("X[K]", "X[K]+N");
  setvar("C[0]", "'#ffeeee'");
  debugPrint(td);
}
```

Writing to an index beyond the length extends the array automatically (padding with `null`), unlike the Windows version, where going past the upper bound is an error.

---

## 5.3 Array Functions

| Function | Description | Notes |
|---|---|---|
| `low(arr)` | Returns the array's lower-bound index | `0` for a literal array; the starting value for a range declaration |
| `high(arr)` | Returns the array's upper-bound index | i.e. the last valid index |
| `COUNT(arr)` | Returns the number of elements in the array | Equal to `high(arr) - low(arr) + 1` |

```xml
<!-- Iterate over all elements -->
<for int="i" from="low(spec)" to="high(spec)">
  <setvar name="sp" value="spec[i]"/>
  <block name="spec-option" id="name(sp)" opt="value(sp)"/>
</for>

<!-- Iterate with while (works on both Win/Web) -->
<setvar name="I" value="low(L)"/>
<while cnd="I&lt;=high(L)">
  <setvar name="total" value="total+L[I]"/>
  <setvar name="I" value="I+1"/>
</while>
```

**📱 Flutter** (`wapform_expression.dart`)

`LOW()`, `HIGH()` and `COUNT()` work as usual; there are also variadic aggregate functions `ARRSUM`, `ARRAVG`, `ARRMAX`, `ARRMIN`, `ARRJOIN` (the last argument is the separator), `ARRUNIQ` and `ARRCONTAINS`.

```dart
void arrayFunctions() {
  setvar("total", "0");
  setvar("I", "LOW(L)");
  while (condition("I<=HIGH(L)")) {
    setvar("total", "total+L[I]");
    setvar("I", "I+1");
  }
  debugPrint("${expression("total")} ${expression("ARRJOIN('a','b','-')")}"); // 365 a-b
}
```

---

## 5.4 The `name()` / `value()` Functions

When an array element is a "key=value" formatted string (such as `'Color=Red'`), `name()` / `value()` can split it into key and value:

| Function | Description |
|---|---|
| `name(s)` | Returns the part of the string before `=` (the key) |
| `value(s)` | Returns the part of the string after `=` (the value) |

```xml
<setvar name="spec" value="['Color=Red','Size=XL','Material=Cotton']"/>
<for int="i" from="low(spec)" to="high(spec)">
  <setvar name="item" value="spec[i]"/>
  <!-- name(item) → 'Color' / value(item) → 'Red' -->
  <block name="spec-row" label="name(item)" val="value(item)"/>
</for>
```

**📱 Flutter** (`wapform_expression.dart`: `NAME()`, `VALUE()`)

```dart
List<String> specRows() {
  setvar("spec", "['Color=Red','Size=XL','Material=Cotton']");
  final rows = <String>[];
  setvar("i", "LOW(spec)");
  while (condition("i<=HIGH(spec)")) {
    setvar("item", "spec[i]");
    rows.add(expandText(r"$(NAME(item)): $(VALUE(item))"));   // Color: Red …
    setvar("i", "i+1");
  }
  return rows;
}
```

---

## 5.5 Arrays as Counters (Report Accumulation)

The most common use of arrays in report output is **column accumulation**; take a crosstab as an example:

```xml
<!-- Declare a column-subtotal array and a column-grand-total array -->
<setvar name="X" value="[1..999]"/>   <!-- Group subtotal, reset per group -->
<setvar name="Y" value="[1..999]"/>   <!-- Global grand total, never reset -->

<!-- Reset the column subtotal at the start of the crosstab's outer group -->
<row change="xy.cno">
  <setvar name="I" value="1"/>
  <while cnd="I&lt;=99">
    <setvar name="X[I]" value="0"/>
    <setvar name="I" value="I+1"/>
  </while>
  ...
  <!-- Accumulate for each cell -->
  <setvar name="K" value="K+1"/>
  <setvar name="X[K]" value="X[K]+N"/>
  <setvar name="Y[K]" value="Y[K]+N"/>
</row>

<!-- Output the group subtotal row -->
<setvar name="I" value="1"/>
<while cnd="I&lt;=K">
  <td align="right">$(FORMAT('%d',X[I]))</td>
  <setvar name="I" value="I+1"/>
</while>
```

**📱 Flutter** (`wapform_report.dart`: accumulating in `WapReport` blocks)

```dart
// part of a WapReport subclass's parseBlock(): X resets per group, Y never resets
void counterBlocks(String id) {
  switch (id) {
    case 'PREFIX':
      setvar("Y", "[1..999]");
      break;
    case 'G1_PREFIX':
      setvar("X", "[1..999]");                     // redeclaring resets it to zero
      setvar("K", "0");
      break;
    case 'RECORD':
      setvar("K", "K+1");
      setvar("X[K]", "X[K]+xy.amount");
      setvar("Y[K]", "Y[K]+xy.amount");
      break;
    case 'G1_SUFFIX':
      final b = StringBuffer('<tr>');
      setvar("I", "1");
      while (condition("I<=K")) {
        b.write(expandText(r"<td align='right'>$(FORMAT('%d',X[I]))</td>"));
        setvar("I", "I+1");
      }
      emitRow('$b</tr>', isFooter: true);
      break;
  }
}
```

---

## 5.6 Arrays as Lookup Tables

After loading from a dataset, an array can be used as an in-memory lookup table to avoid repeated queries:

```xml
<!-- Load menu data from a dataset into several parallel arrays -->
<setvar name="mnu_id"    value="[0..1023]"/>
<setvar name="mnu_typ"   value="[0..1023]"/>
<setvar name="mnu_title" value="[0..1023]"/>
<setvar name="mnu_icon"  value="[0..1023]"/>
<setvar name="k" value="0"/>

<dbquery id="mnu"><![CDATA[
  SELECT id, typ, title, icon FROM menu WHERE active>0 ORDER BY id
]]></dbquery>

<report dataset="mnu">
  <group>
    <setvar name="mnu_id[k]"    value="mnu.id"/>
    <setvar name="mnu_typ[k]"   value="mnu.typ"/>
    <setvar name="mnu_title[k]" value="mnu.title"/>
    <setvar name="mnu_icon[k]"  value="mnu.icon"/>
    <setvar name="k" value="k+1"/>
  </group>
</report>

<!-- Subsequently access directly by index, without querying the database again -->
<setvar name="I" value="0"/>
<while cnd="I&lt;k">
  <if cnd="mnu_typ[I]='b'">
    <td>$(mnu_title[I])</td>
  </if>
  <setvar name="I" value="I+1"/>
</while>
```

**📱 Flutter** (`wapform_lazarus.dart`: `DbQuery`, `invoke()`, `setvar()`)

```dart
Future<void> loadMenuTable() async {
  setvar("mnu_id", "[0..1023]");
  setvar("mnu_typ", "[0..1023]");
  setvar("mnu_title", "[0..1023]");
  setvar("k", "0");
  await db.query("mnu", "SELECT id, typ, title, icon FROM menu WHERE active>0 ORDER BY id");
  invoke("mnu", "first");
  while (!condition("mnu.EOF")) {                   // <report dataset="mnu"><group>
    setvar("mnu_id[k]", "mnu.id");
    setvar("mnu_typ[k]", "mnu.typ");
    setvar("mnu_title[k]", "mnu.title");
    setvar("k", "k+1");
    invoke("mnu", "next");
  }
}
```

---

## 5.7 Arrays as Color Maps

```xml
<!-- Map an index to a Bootstrap style class -->
<setvar name="btn" value="[0..9]"/>
<setvar name="btn[0]" value="'btn-primary'"/>
<setvar name="btn[1]" value="'btn-secondary'"/>
<setvar name="btn[2]" value="'btn-success'"/>
<setvar name="btn[3]" value="'btn-warning'"/>
<setvar name="btn[4]" value="'btn-danger'"/>

<!-- Usage -->
<block name="card-url" style="btn[I MOD 5]" link="midb(s,i+1,j-i-1)"/>
```

```xml
<!-- Days-in-month table (leap-year handling for February done separately) -->
<setvar name="L" value="[31,28,31,30,31,30,31,31,30,31,30,31]"/>
<setvar name="days_this_month" value="L[MONTH(DATE)-1]"/>
```

**📱 Flutter** (`wapform_expression.dart`)

```dart
String buttonStyle(int i) {
  setvar("btn", "['btn-primary','btn-secondary','btn-success','btn-warning','btn-danger']");
  _ev.setVar("I", i);
  return "${expression("btn[I MOD 5]")}";
}

int daysThisMonth() {
  setvar("L", "[31,28,31,30,31,30,31,31,30,31,30,31]");
  return expression("L[MONTH(DATE)-1]") as int;
}
```

---

## 5.8 Array-Style Dataset Access

A `<dbquery>` dataset can be accessed by field position (1-based) using `.FIELDS[n]`:

```xml
<dbquery id="ds"><![CDATA[SELECT col1, col2, col3 FROM t]]></dbquery>

<!-- Get a field value by position -->
<setvar name="v1" value="ds.FIELDS[1]"/>   <!-- col1 -->
<setvar name="v2" value="ds.FIELDS[2]"/>   <!-- col2 -->
```

A dataset's `COUNT`, `EOF`, `BOF` properties are not arrays, but behave similarly:

| Expression | Description |
|---|---|
| `ds.COUNT` | Total number of rows in the query result |
| `ds.EOF` | Whether the cursor is past the last record (Boolean) |
| `ds.BOF` | Whether the cursor is before the first record (Boolean) |
| `ds.FIELDS[n]` | Gets the current record's field value by position (1-based) |

**📱 Flutter** (`wapform_lazarus.dart`: `ds.FIELDS[n]`)

`ds.FIELDS[n]` (1-based), `ds.COUNT`, `ds.EOF` and `ds.BOF` work the same in Flutter:

```dart
Future<void> fieldsByPosition() async {
  await db.query("ds", "SELECT col1, col2, col3 FROM t");
  setvar("v1", "ds.FIELDS[1]");                    // col1
  setvar("v2", "ds.FIELDS[2]");                    // col2
}
```

---

## 5.9 Limitations and Caveats

**No two-dimensional arrays** — WapForm does not support `arr[i][j]`; you need to simulate this with parallel one-dimensional arrays:

```xml
<!-- Simulating two dimensions: distinguish dimensions with a naming convention -->
<setvar name="row1" value="[0..9]"/>
<setvar name="row2" value="[0..9]"/>
```

**Indices start from the declared starting value** — a range declaration `[1..26]` has a starting index of `1`, while a literal declaration `[a,b,c]` has a starting index of `0`. When mixing the two, pay special attention to what `low()` returns.

**No dynamic resizing** — an array's length is fixed at declaration time; elements cannot be added at runtime. Accessing beyond the upper bound produces an error.

**Resetting with a `while` loop** — resetting an array with a `<while>` loop within the same card is the standard pattern; there's no need to re-declare the whole array:

```xml
<!-- Clear, rather than re-declare -->
<setvar name="I" value="1"/>
<while cnd="I&lt;=99">
  <setvar name="X[I]" value="0"/>
  <setvar name="I" value="I+1"/>
</while>
```

**📱 Flutter** (Dart expression engine)

| Item | Windows/Web | Flutter |
|---|---|---|
| Two-dimensional arrays | Not supported | Not supported |
| Starting index | As declared (range declarations can start at 1) | Always 0 (`[1..n]` gets an extra index 0, and `LOW()` is 0) |
| Growing dynamically | No | `setvar("X[i]", ...)` extends the array when past its length |
| Resetting | Zero each element with `while` | Just redeclare: `setvar("X", "[1..99]")` |

---

## Chapter 6　Expressions and the Function Library

WapForm expressions appear in every attribute that accepts a dynamic value (`cnd`, `value`, `message`, `href`, `device`, etc.), as well as in `$variable` and `$(expression)` interpolation within HTML output.

---

## 6.1 Interpolation Syntax

| Syntax | Purpose | Example |
|---|---|---|
| `$varname` | Simple variable substitution | `$total`, `$ds.field` |
| `$(expression)` | Evaluates an arbitrary expression, then outputs it | `$(FORMAT('%.2f',total))`, `$(IF(qty>0,'Yes','No'))` |

The two can be mixed:

```xml
<td>$(sys.GSWEB+pa.pic1)</td>
<setvar name="label" value="'Order '+sn.order_no+' totals '+STR(total)+' dollars'"/>
```

**📱 Flutter** (`wapform_lazarus.dart`: `expandText()`, `expandSql()`, `expandSqlAuto()`, `expandSqlQuoted()`)

All four expansion functions understand `$name`, `$(expression)` and `$$` (outputs one `$`), and turn backticks `` ` `` into `'`; they differ in how values are inserted:

| Function | How values are inserted | Use for |
|---|---|---|
| `expandText(s)` | As is | Screen text, report HTML |
| `expandSql(s)` | As is | Inserting whole SQL conditions (`$S`); the default of `DbQuery.query()` |
| `expandSqlAuto(s)` | Strings get single quotes and escaping automatically, numbers don't | Inserting a single value |
| `expandSqlQuoted(s)` | Always single quotes and escaping | Inserting a single value |

```dart
void expandDemo() {
  _ev.setVar("cname", "O'Brien");
  debugPrint(expandSql(r"where cname='$cname'"));            // where cname='O'Brien'   ← broken
  debugPrint(expandSqlAuto(r"where cname=$cname"));          // where cname='O''Brien'  ← correct
  debugPrint(expandSql(r"where cname=$(AsQuoted(cname))"));  // same as above
  debugPrint(expandText(r"$(sys.GSWEB+pa.pic1) total $$100"));  // $$ → $
}
```

---

## 6.2 Operators

### Arithmetic

| Operator | Description | Example |
|---|---|---|
| `+` | Addition; string concatenation if either operand is a string | `qty * price`, `'Code: '+sn.code` |
| `-` | Subtraction | `total - discount` |
| `*` | Multiplication | `sn.qty * sn.price` |
| `/` | Division (floating point) | `AZ/AY*100` |
| `MOD` | Remainder (integer) | `seq MOD 2` |
| `DIV` | Integer division | `n DIV 3` |

### Comparison

| Operator | XML Attribute Form | Description |
|---|---|---|
| `=` | `=` | Equal to |
| `<>` | `&lt;&gt;` | Not equal to |
| `<` | `&lt;` | Less than |
| `>` | `&gt;` | Greater than |
| `<=` | `&lt;=` | Less than or equal to |
| `>=` | `&gt;=` | Greater than or equal to |

> Angle brackets in XML attributes (`cnd`, `value`, etc.) **must** be entity-encoded. Inside `<![CDATA[...]]>`, `<` and `>` can be written directly.

### Logical

| Operator | Description | Example |
|---|---|---|
| `AND` | Logical AND | `qty>0 AND active='Y'` |
| `OR` | Logical OR | `status='A' OR status='B'` |
| `NOT(expr)` | Logical NOT (function form) | `NOT(ds.EOF)` |

### String Concatenation

`+` automatically switches to concatenation when either operand is a string:

```xml
<setvar name="S" value="S+' AND dept=`'+filter+'`'"/>
<setvar name="key" value="FORMAT('%3.3d',YEAR(DATE)-1911)+FORMAT('%2.2d',MONTH(DATE))"/>
```

### Precedence (Highest to Lowest)

1. Function calls, parentheses `()`
2. Multiplication/division: `*` `/` `MOD` `DIV`
3. Addition/subtraction / concatenation: `+` `-`
4. Comparison: `=` `<>` `<` `>` `<=` `>=`
5. `NOT`
6. `AND`
7. `OR`

**📱 Flutter** (`wapform_expression.dart`: `WapEvaluator`)

How the Dart engine differs from the Windows version:

- **Comparisons on both sides of `AND`/`OR` need parentheses**: `(qty>0) AND (active='Y')`. Written as `qty>0 AND active='Y'`, it reports `Invalid end token` and `condition()` returns `false`.
- In Dart strings write `<` and `>` directly; `&lt;` and `&gt;` are not needed.
- `+`, `-` and `*` between two integers give an integer; everything else (including `/`) gives a floating-point number.

Using the engine directly:

```dart
void evaluatorDemo() {
  final ev = WapEvaluator();
  ev.setVar("qty", 3);
  ev.setVar("price", 99.5);
  final total = ev.eval("qty*price");                // 298.5
  final ok = ev.cond("(qty>0) AND (price<100)");     // true
  ev.addFunction1Param("TAXED", (v) => (v as num) * 1.05); // custom function
  debugPrint("$total $ok ${ev.eval("TAXED(100)")}"); // 298.5 true 105.0
}
```

| `WapEvaluator` member | Description |
|---|---|
| `eval(expr, {nul})`/`evalNul(expr)` | Evaluates an expression; on error `lastError` is set |
| `cond(expr)` | Evaluates a condition and returns a `bool` |
| `setVar(name, value)`/`getVar(name)` | Reads and writes variables (values are not evaluated) |
| `setRow(table, map)` | Sets a whole row at once: both `table.field` and `field` names are set |
| `clearVars()`/`getUserVars()` | Clears/lists user variables |
| `addFunction0Param`–`addFunction4Param`, `addFunctionAParam` | Registers custom functions with 0–4 parameters or variadic parameters (an existing function of the same name is not overwritten) |
| `datasetResolver` | Dataset resolver (`useEngine()` sets it to `DataSetRegistry.resolveDataSet`) |
| `hasError`/`lastError` | Error state |

See Appendix C for how functions differ in Flutter.

---

## Chapter 7　Dataset Object Reference

WapForm's dataset is a record-set object with a cursor, declared with `<dbquery id="ds">` or `<dbtable name="ds">`. Once declared, the dataset's field values, state properties, and lookup prefix can all be referenced directly in expressions.

---

## 7.1 Field Value Access

### `ds.fieldname`

Accesses the `fieldname` field's value on dataset `ds`'s current record.

```xml
$xy.city
$(sn.qty * sn.unit_price)
<if cnd="oh.work_order_no&lt;&gt;''">
```

**📱 Flutter** (`wapform_lazarus.dart`: `expression()`, `expandText()`)

```dart
void readFields() {
  final city = expandText(r"$xy.city");
  final amt = expression("sn.qty * sn.unit_price");
  final hasNo = condition("oh.work_order_no<>''");
  debugPrint("$city $amt $hasNo");
}
```

A dataset an expression refers to must be registered in the `DataSetRegistry` given to `useEngine()` (`db.query()` registers it automatically).

### Writing a Field (via `<setvar>`)

Concatenate the dataset id with the field name as the `<setvar>`'s `name`:

```xml
<!-- The order_date field of dataset oh -->
<setvar name="ohorder_date" value="DATE"/>

<!-- The material_name field of dataset sn -->
<setvar name="snmaterial_name" value="luppm.material_name"/>
```

Naming rule: `{dataset_id}{fieldname}`, with no separator.

**📱 Flutter** (`wapform_lazarus.dart`: `setvar("ds.field", ...)`)

```dart
void writeFields() {
  setvar("oh.order_date", "DATE");                   // ohorder_date
  setvar("sn.material_name", "pm.material_name");    // snmaterial_name
}
```

Flutter uses `ds.field` (with a dot), not concatenated names such as `ohorder_date`.

---

## 7.2 Dataset State Properties

### `ds.COUNT`

The total number of rows in the query result (integer).

```xml
<if cnd="em.COUNT=0">
  <alert message="No data found"/>
  <exit/>
</if>
<if cnd="xx.count&gt;0">
  <!-- Takes this path when a record already exists -->
</if>
```

**📱 Flutter**: `condition("em.COUNT=0")`; `em.RECORDCOUNT` also works.

### `ds.EOF`

Whether the cursor is **past** the last record (Boolean). `True` once iteration reaches the end.

```xml
<while cnd="NOT(ds.EOF)">
  ...
  <invoke instance="ds" method="Next"/>
</while>
```

**📱 Flutter**

```dart
void walkAll() {
  invoke("ds", "first");
  while (condition("NOT(ds.EOF)")) {
    // ...
    invoke("ds", "next");
  }
}
```

### `ds.BOF`

Whether the cursor is **before** the first record (Boolean). `True` right after opening an empty dataset.

```xml
<newpage cnd="not(cu.bof)"/>
```

**📱 Flutter**: `condition("not(cu.bof)")`.

### `ds.FIELDS[n]`

Gets the current record's field value by position (1-based), without needing to know the field name.

```xml
<dbquery id="ds"><![CDATA[SELECT col1, col2, col3 FROM t]]></dbquery>
<setvar name="v1" value="ds.FIELDS[1]"/>   <!-- col1 -->
<setvar name="v2" value="ds.FIELDS[2]"/>   <!-- col2 -->
```

**📱 Flutter**: `setvar("v1", "ds.FIELDS[1]")` works as usual (1-based).

### `ds.state` *(Windows only)*

A string describing the dataset's current edit state.

| Value | Description |
|---|---|
| `'BROWSE'` | Browse mode (read-only) |
| `'EDIT'` | Edit mode |
| `'INSERT'` | Insert mode |

```xml
<if cnd="em.state='INSERT'">
  <!-- Auto-fill the creation date in insert mode -->
  <setvar name="emcreate_date" value="DATE"/>
</if>
```

**📱 Flutter**: `ds.STATE` is also available in Flutter and returns `BROWSE`, `EDIT`, `INSERT` or `INACTIVE`: `if (condition("em.state='INSERT'")) setvar("em.create_date", "DATE");`

---

## 7.3 The Lookup Prefix (`lup{dataset}`)

When an `<input>` uses the `lookup` attribute, once the user selects a record from the lookup list, the system automatically creates a temporary dataset prefixed with `lup`, from which all fields of the selected row can be read.

```xml
<input field="material_code" lookup="pm;material_code;material_name" size="12">
  <onevent type="oncloseup">
    <!-- lup + dataset_id = luppm -->
    <setvar name="snmaterial_name" value="luppm.material_name"/>
    <setvar name="snunit_price"    value="luppm.unit_price"/>
  </onevent>
</input>
```

**Format:** `lup{dataset_id}.{fieldname}`

**Lookup attribute format:** `"dataset_id;key_field;display_field"`

| Part | Description |
|---|---|
| `dataset_id` | The dataset id of the query source (`<dbquery id>` or `<dbtable name>`) |
| `key_field` | The key field written back to the target field |
| `display_field` | The field displayed in the input box |

**SQL-based lookup:**

```xml
<input field="color_no"
       lookup="sql;color_no;SELECT color_no, color_name FROM colors ORDER BY color_no"
       size="10">
  <onevent type="oncloseup">
    <setvar name="sncolor_name" value="lupyy.color_name"/>
    <!-- When dataset_id is sql, the prefix is fixed as lupyy -->
  </onevent>
</input>
```

**📱 Flutter** (`wapform_lookup_box.dart`: `WapLookupBox`)

Flutter does not create a separate `luppm` dataset; `onPicked` receives the chosen code, and to read other fields of the chosen row, move the source dataset to that row (example in Section 3.4). `WapLookupBox` parameters:

| Parameter | Description |
|---|---|
| `value` | The current code (required) |
| `dataSet` + `keyField` + `displayFields` | Builds the list from a dataset (corresponds to `lookup="ds;key;display"`) |
| `lookupItems` | One-column list `{code: display text}` |
| `lookupColumns` + `colWidths` | Multi-column list `{code: [col1, col2, ...]}` and column widths |
| `onPicked` | Called when an item is picked from the drop-down (corresponds to `oncloseup`) |
| `onChanged` | Called on typed input or when the value is filled back on losing focus |
| `readOnly` | Read-only |
| `width`/`height`/`textStyle` | Appearance (default 130 × 28) |
| `autofocus`, `tapRegionGroupId` | Focus control |
| `forGrid`, `onTab`, `onTabPrev` | Inside a grid cell (no border, Tab moves between cells) |

---

## 7.5 Web Environment Objects

### `request.*`

Accesses parameter values from an HTTP GET / POST request. Parameter names are referenced directly like field names.

| Mode | Description |
|---|---|
| Read | `$request.gp`, `$(val(request.pg))` |
| Existence check | `DEFINE(request.gp)` |

**Standard read pattern (with a default value):**

```xml
<setvar name="gp" value="'0001'"/>
<setvar name="gp" value="request.gp" cnd="DEFINE(request.gp)"/>

<setvar name="pg" value="1"/>
<setvar name="pg" value="val(request.pg)" cnd="DEFINE(request.pg)"/>
```

**Operation-dispatch pattern:**

```xml
<if cnd="DEFINE(request.del)">
  <dbquery><![CDATA[DELETE FROM rn WHERE sno='$session.ord']]></dbquery>
  <redirect href="cart.wml"/>
  <exit/>
</if>
<if cnd="DEFINE(request.ok)">
  <!-- Confirm submission -->
</if>
```

---

### `session.*`

Accesses server-side session variables, preserving user state across HTTP requests.

| Operation | Syntax |
|---|---|
| Read | `$session.usr`, `$(session.ord)` |
| Write | `<session name="usr" value="A"/>` |
| Timed write | `<session name="usr" value="A" expire="480"/>` (expires after 480 minutes; requires an engine version from 2026-09 or later) |
| Conditional write | `<session name="lang" value="request.lang" cnd="DEFINE(request.lang)"/>` |
| Clear | `<session name="usr" value="''"/>` |
| Existence check | `DEFINE(session.usr)` |

**Session lifecycle management:**

```xml
<!-- Login: set the session -->
<session name="usr" value="A"/>     <!-- A is the account the user entered -->
<session name="ord" value="''"/>    <!-- Clear the old shopping cart -->
<redirect href="index.wml"/>

<!-- Logout: clear all session values -->
<session name="usr" value="''"/>
<session name="ord" value="''"/>
<redirect href="index.wml"/>

<!-- Session guard: redirect to the login page if not logged in -->
<if cnd="NOT(DEFINE(session.usr))">
  <redirect href="login.wml"/>
  <exit/>
</if>
```

**Per-variable expiry (`expire`):**

`expire`, in minutes, gives the variables in the same session different lifetimes. Before parsing the card on every request the engine removes expired variables, so the reading side needs no extra check — `DEFINE(session.usr)` is simply false.

```xml
<!-- login state 8 hours, shopping-cart scratch value 2 hours -->
<session name="usr" value="A" expire="480"/>
<session name="ord" value="S" expire="120"/>

<!-- to renew it, write it again; the expiry is recalculated from now -->
<session name="usr" value="session.usr" expire="480"/>
```

Above `expire` there are two more upper limits, the cookie and the server's `SessionTimeout`; setting it longer than them has no effect. See `<session/>` in Section 4.11 of Chapter 4 for the full description and attribute table, and Section 15.9 of Chapter 15 for a worked case.

---

## 7.6 Report Environment Special Variables

These variables are maintained automatically by the report engine, and are only valid within the output environment of `<report>` / `<crosstab>`.

### `$(PAGE)`

The current page number, starting from `1`, automatically incremented by the framework.

```xml
<th align="right">Page $(PAGE)</th>
```

**📱 Flutter** (`wapform_report.dart`: `wap.wapPageNo`)

The Dart engine does not set `PAGE` automatically; put the page number into the engine in the `PAGEPREFIX` block:

```dart
// part of a WapReport subclass's parseBlock()
void pageNoBlock(String id) {
  if (id == 'PAGEPREFIX') {
    currentEvaluator!.setVar("PAGE", wap.wapPageNo);
    emit(expandText(r'<p align="right">Page $(PAGE)</p>'));
  }
}
```

### `cell` (inside `<crosstab>`)

Inside a `<crosstab>`'s `<col change>` tag, `cell` automatically corresponds to the value of the field currently being rendered, without needing to manually reference `$ds.fieldname`.

```xml
<col change="xy.area">
  <setvar name="C" value="cell"/>              <!-- cell = the current value of xy.area -->
  <setvar name="R" value="cell" cnd="col=1"/> <!-- record the row header on the first column -->
  <if cnd="row&lt;3">
    <th>$(IF(cell='',' ',cell))</th>
  <else/>
    <setvar name="N" value="VAL(cell)"/>
  </if>
</col>
```

### `row` / `col` (inside `<crosstab>`)

During a `<crosstab>`'s rendering process, the framework maintains the current row coordinate (`row`) and column coordinate (`col`), both 1-based integers.

```xml
<if cnd="(row&lt;3) or (col&lt;3)">
  <!-- Header area (first two rows or first two columns) -->
  <th width="60">...</th>
<else/>
  <!-- Data area -->
  <td align="right">...</td>
</if>
```

| Coordinate | Description |
|---|---|
| `row=1` | The header row for the first `<row change>` field |
| `row=2` | The header row for the second `<row change>` field |
| `row>2` | A data row |
| `col=1` | The header column for the first `<col change>` field |
| `col=2` | The header column for the second `<col change>` field |
| `col>2` | A data column |

---

## 7.7 Dataset Method Quick Reference

Called via `<invoke>`.

| Method | Win | Web | Description |
|---|---|---|---|
| `First` | ✅ | ✅ | Moves to the first record |
| `Last` | ✅ | ✅ | Moves to the last record |
| `Next` | ✅ | ✅ | Moves to the next record |
| `Prior` | ✅ | ✅ | Moves to the previous record |
| `locate` | ✅ | ✅ | Positions the record by key value |
| `post` | ✅ | ⚠️ | Saves changes to the current record |
| `cancel` | ✅ | ⚠️ | Discards changes to the current record |
| `refresh` | ✅ | ⚠️ | Re-runs the query, reloading from the database |
| `edit` | ✅ | ❌ | Switches to edit mode |
| `insert` | ✅ | ❌ | Inserts a new blank record |
| `delete` | ✅ | ❌ | Deletes the current record |
| `open` | ✅ | ⚠️ | Opens the dataset (runs the query) |
| `close` | ✅ | ⚠️ | Closes the dataset |
| `GetBookmark` | ✅ | ❌ | Gets a bookmark for the current cursor position, stored into the `result` variable |
| `GoToBookmark` | ✅ | ❌ | Returns to the specified bookmark position |
| `FreeBookmark` | ✅ | ❌ | Frees the bookmark's memory |
| `DisableControls` | ✅ | ❌ | Freezes UI updates (used during iteration) |
| `EnableControls` | ✅ | ❌ | Resumes UI updates |

**The bookmark pattern** (the standard way to iterate a bound dataset in the Windows environment):

```xml
<invoke instance="ds" method="GetBookmark" result="bm"/>
<invoke instance="ds" method="DisableControls"/>
<invoke instance="ds" method="First"/>
<while cnd="NOT(ds.EOF)">
  ...process...
  <invoke instance="ds" method="Next"/>
</while>
<invoke instance="ds" method="EnableControls"/>
<invoke instance="ds" method="GoToBookmark" params="bm"/>
<invoke instance="ds" method="FreeBookmark"/>
```

**📱 Flutter** (`wapform_lazarus.dart`: `invoke()`, `varChangeHooks`)

`First`, `Last`, `Next`, `Prior`, `post`, `cancel`, `edit`, `insert`, `delete`, `GetBookmark`, `GoToBookmark`, `FreeBookmark`, `DisableControls` and `EnableControls` can all be called with `invoke("ds", "method")` (case-insensitive); for `refresh`/`open`, re-query with `db.query("ds", sql)`. The bookmark pattern:

```dart
void bookmarkWalk() {
  invoke("ds", "getbookmark", result: "bm");
  invoke("ds", "disablecontrols");
  try {
    invoke("ds", "first");
    while (condition("NOT(ds.EOF)")) {
      // ...process...
      invoke("ds", "next");
    }
  } finally {
    invoke("ds", "enablecontrols");
    invoke("ds", "gotobookmark", params: _ev.getVar("bm"));
  }
}
```

**Keeping the screen in sync:** when `setvar()` changes an ordinary variable, it calls every function in `varChangeHooks`, so the screen can update the input box that shows that variable:

```dart
late final void Function(String) _onVar = (name) {
  if (name.toUpperCase() == "TOTAL" && mounted) setState(() {});
};
void hookVars() => varChangeHooks.add(_onVar);       // when the screen initializes
void unhookVars() => varChangeHooks.remove(_onVar);  // when the screen is disposed
```

---

## Chapter 8　Windows System Login and Access Control

🖥️ **Windows-only**

---

## 8.1 The Three-Layer Cooperative Architecture

WapForm for Windows' login and permission system runs on three cooperating layers, each with its own role:

```
┌─ Layer 1: Database ──────────────────────────────────────┐
│  users table: account / password / group                 │
│  mnu   table: menu definitions (id, title, href, sub)      │
│  login table: permission value w for each user/menu item  │
└───────────────────────────────────────────────────────────┘
           ↓ Once login validation passes
┌─ Layer 2: wapform.wml ───────────────────────────────────┐
│  Queries mnu LEFT JOIN login                              │
│  login.w determines:                                      │
│    ① Whether the menu item is clickable (menuitem enabled) │
│    ② The framework's runtime LoginLevel value              │
└───────────────────────────────────────────────────────────┘
           ↓ The user clicks a menu item to open a feature
┌─ Layer 3: Each feature's .wml ───────────────────────────┐
│  <author level="n"> wraps a group of input fields          │
│  The framework checks: LoginLevel > n?                     │
│    Yes → Writable=False → fields are read-only             │
│    No  → Writable=True  → fields are writable              │
└───────────────────────────────────────────────────────────┘
```

---

## 8.2 The Login Dialog

Built into the framework — developers don't need to write the UI; it pops up automatically when the application starts.

| Field | Description |
|---|---|
| **Computer** | The database server connection address (`http://host:port/path/`), remembers connection history |
| **Username** | The user's account, injected by the framework as the global variable `$username` |
| **Password** | The user's password, injected by the framework as the global variable `$password` |
| **Connect** | Confirms the connection, loads `wapform.wml` |
| **Cancel** | Cancels, closes the application |

`$username` and `$password` are globally valid throughout the entire `wapform.wml` runtime.

---

## 8.3 Authentication

```xml
<card id="P" title="mainmenu" device="MDI">

  <!-- Look up the account -->
  <dbquery id="usr">
    select pwd from users where userid='$username'
  </dbquery>

  <!-- Account doesn't exist → back to the login dialog -->
  <if cnd="usr.count=0">
    <alert message="Account does not exist"/>
    <prev/>
  </if>

  <!-- Wrong password (UPPER() for a case-insensitive comparison) -->
  <if cnd="upper(usr.pwd)&lt;&gt;upper(password)">
    <alert message="Password error"/>
    <prev/>
  </if>

  ...
</card>
```

`<prev/>` in an MDI card's behavior is to **return to the login dialog**, letting the user try again, without closing the application.

> **Security recommendation:** in production, store password hashes with `MD5()`:
> ```xml
> <if cnd="usr.pwd&lt;&gt;MD5(password)">
> ```

---

## 8.4 Menu Construction and LoginLevel Settings

Once validation passes, `wapform.wml` dynamically builds the main menu with two nested `<while>` loops, while also reading each menu item's permission value `w` for the current user through a LEFT JOIN:

```xml
<setvar name="K" value="0"/>

<!-- Query the top-level menu groups (sub=-1) -->
<dbquery id="sub"><![CDATA[
  select id, title, href from mnu
  where active=1 and sub=-1
  order by id
]]></dbquery>

<mainmenu images="imagelist1">
  <while cnd="NOT(sub.EOF)">
    <menuitem caption="$sub.title" hint="sub">

      <!-- Sub-item query: LEFT JOIN to get the permission value w -->
      <dbquery id="itm"><![CDATA[
        SELECT mnu.id, mnu.title, mnu.href, login.uid, login.w
        FROM mnu
        LEFT JOIN login
               ON mnu.id = login.id
              AND login.uid = '$username'
        WHERE mnu.active = 1
          AND mnu.sub = $sub.id
        ORDER BY mnu.id
      ]]></dbquery>

      <while cnd="NOT(itm.EOF)">
        <setvar name="I" value="-1"/>                              <!-- Default: no permission -->
        <setvar name="I" value="itm.w" cnd="itm.w&gt;0"/>         <!-- Only updated when a record exists and w>0 -->

        <setvar name="K" value="K+1"/>
        <setvar name="ID" value="'A'+FORMAT('%3.3d',K)"/>

        <menuitem name="$ID" caption="$(itm.title)"
                  hint="$itm.href" imageindex="$I" onclick="$itm.href"/>

        <setprop name="$ID" prop="enabled" value="0" cnd="I=-1"/> <!-- Disable if no permission -->

        <invoke instance="itm" method="Next"/>
      </while>
    </menuitem>
    <invoke instance="sub" method="Next"/>
  </while>
</mainmenu>
```

### Menu Item Enable Logic

| `login` record status | `itm.w` | `I` | `menuitem` |
|---|---|---|---|
| No record (LEFT JOIN → NULL) | NULL | `-1` | Disabled (grayed out, not clickable) |
| Record exists, `w = 0` | `0` | `-1` | Disabled |
| Record exists, `w > 0` | `w` value | `w` value | **Enabled**, `imageindex` shows the corresponding icon |

`imageindex` plays double duty as both the icon index and the permission flag: `-1` means no icon, and also triggers `enabled=0`.

### Where LoginLevel Comes From

While building the menu, the framework records each `itm.w` it reads (the effective value) as that user's runtime `LoginLevel`. **`login.w` is the sole source of `LoginLevel`.**

---

## 8.5 Field-Block Permissions: the `<author>` Tag

`<author>` wraps a group of input fields into a **block whose writability is controlled**. When the framework renders `<author>`, it first evaluates the `level` attribute to determine the `Writable` flag, then renders all inner child nodes (`<input>`, `<table>`, etc.).

### Syntax

```xml
<author level="n" color="#RRGGBB" yy="row" cnd="expr">
  <!-- The controlled group of input fields -->
</author>
```

### Attributes

| Attribute | Required/Optional | Description |
|---|---|---|
| `level="n"` | Optional | The writable-permission threshold. When `LoginLevel > n`, all `<input>` elements in the block are read-only; when omitted or `n=0`, always writable. |
| `color="#RRGGBB"` | Optional | Temporarily overrides the label text color inside the block, automatically restored after `</author>`. |
| `yy="n"` | Optional | Sets the current row number (`Wap.CurrentLine`), controlling layout position. |
| `cnd="expr"` | Optional | A reserved attribute; the current version doesn't affect rendering logic. |
| `id="name"` | Optional | Block identifier, reserved for code to locate it. |

### Permission-Comparison Rule

**The smaller the number, the higher the permission.** Read-only when `LoginLevel > level` is true:

| User's `LoginLevel` | `<author level="1">` | `<author level="2">` | `<author level="3">` | `<author>` |
|---|---|---|---|---|
| `1` (highest) | ✅ Writable | ✅ Writable | ✅ Writable | ✅ Writable |
| `2` | ❌ Read-only | ✅ Writable | ✅ Writable | ✅ Writable |
| `3` | ❌ Read-only | ❌ Read-only | ✅ Writable | ✅ Writable |
| `5` (lowest) | ❌ Read-only | ❌ Read-only | ❌ Read-only | ✅ Writable |

---

## 8.6 Worked Example: Order Sign-Off Block

Below is the actual usage from `order.wml`: the sign-off fields are wrapped in `<author>`, ensuring only specific personnel can fill them in:

```xml
<!-- General business fields: no level, editable by any logged-in user -->
<author>
  <table columns="7" align="LLLLLLL"><tr>
    <td>Factory Ship Date 1: <input field="factory_ship_date_1" size="12"/>
                     <input field="factory_ship_qty_1"  size="12"/></td>
    <td width="10"></td>
    <td>ETD1: <input field="etd_1" size="12"/></td>
    <td width="10"></td>
    <td>INVOICE NO.1: <input field="invoice_no_1" size="20"/></td>
    <td width="10"></td>
    <td>Payment Date 1: <input field="payment_date_1" size="12"/></td>
  </tr></table>
</author>

<!-- Mother vessel / ETA: another group of business fields -->
<author>
  <table columns="3" align="LLL">
    <tr>
      <td>Vessel 1: <input field="vessel_1" size="40"/></td>
      <td>ETA1: <input field="eta_1" size="12"/></td>
      <td width="500"></td>
    </tr>
    <tr>
      <td>Vessel 2: <input field="vessel_2" size="40"/></td>
      <td>ETA2: <input field="eta_2" size="12"/></td>
      <td></td>
    </tr>
    <tr>
      <td>Vessel 3: <input field="vessel_3" size="40"/></td>
      <td>ETA3: <input field="eta_3" size="12"/></td>
      <td></td>
    </tr>
    <tr>
      <td>Vessel 4: <input field="vessel_4" size="40"/></td>
      <td>ETA4: <input field="eta_4" size="12"/></td>
      <td></td>
    </tr>
  </table>
</author>

<!-- Sign-off row: by business convention, usually paired with level so only a manager can fill it in -->
<author>
  <table columns="6" align="CCCCCC"><tr>
    <td>Approved by: <input field="approved_by" size="12"
          lookup="sql;approved_by;select distinct username from users where grp='A'"/></td>
    <td>Sales Rep: <input field="sales_rep" size="12"
          lookup="sql;sales_rep;select distinct username from users where grp='B'"/></td>
    <td>Buyer: <input field="buyer_rep" size="12"
          lookup="sql;buyer_rep;select distinct username from users where grp='C'"/></td>
    <td>Prepared by: <input field="prepared_by" size="12"
          lookup="sql;prepared_by;select distinct username from users where grp='D'"/></td>
    <td>Form Date: <input field="form_date" size="14"/></td>
    <td>Fax Date: <input field="fax_date" size="14"/></td>
    <td><input value="Production Order Sheet" type="button" onclick="@BOM"/></td>
  </tr></table>
</author>

<!-- A single field can also be controlled on its own -->
<author>
  Sample No.: <input field="sample_no" size="20"/>
</author>
```

**What it actually means for `<author>` to have no `level=`:**

In the existing project, `<author>` almost always appears without a `level=` attribute — `Level` defaults to `0`, so on the Delphi side `if Level > 0` is false, and `Writable` is always `True`. In this case, `<author>` serves as a **semantic marker**: explicitly flagging which fields belong, from a business standpoint, to a sign-off area that "should require authorization to modify," reserving the architectural placement for enabling the `level=` mechanism in the future.

---

## 8.7 Complete Data Flow

```
User enters account / password
          ↓
Framework injects $username, $password
          ↓
wapform.wml executes:
  ① Queries users WHERE userid='$username'
     → Verifies pwd (UPPER comparison or MD5)
     → Failure → <alert> + <prev/> (back to the dialog)
  ② Queries mnu LEFT JOIN login WHERE uid='$username'
     → login.w > 0  → menuitem enabled, imageindex=w
     → login.w missing/0 → menuitem disabled, imageindex=-1
     → The framework records LoginLevel = w
          ↓
User clicks a menu item, opening xxx.wml
          ↓
When the framework renders <author level="n">:
  Checks: Wap.LoginLevel > n?
  True  → Writable=False → all <input> in the block are read-only (gray background)
  False → Writable=True  → all <input> in the block are editable (white background)
  </author> → Writable restored to True
          ↓
User operates the form (writable fields work normally, read-only fields are view-only)
```

---

## 8.8 Database Design Reference

```sql
-- User account table
CREATE TABLE users (
  userid  VARCHAR(20) PRIMARY KEY,
  pwd     VARCHAR(100),   -- MD5 hash
  grp     VARCHAR(5)      -- Functional group: A=Approval B=Sales C=Purchasing D=Data Entry
);

-- Menu definition table
CREATE TABLE mnu (
  id      VARCHAR(10) PRIMARY KEY,
  sub     VARCHAR(10),    -- Parent menu id; -1 = top-level group
  title   VARCHAR(50),
  href    VARCHAR(100),
  active  INT DEFAULT 1
);

-- User menu permission table
CREATE TABLE login (
  uid     VARCHAR(20),    -- Corresponds to users.userid
  id      VARCHAR(10),    -- Corresponds to mnu.id
  w       INT             -- Permission value (1=highest, larger number=lower permission)
);

-- Suggested w value assignments
-- w=1: System administrator (can edit all blocks with level="1" or lower)
-- w=2: Manager / approver (can edit blocks with level="2" or lower)
-- w=3: General operator (can edit blocks with level="3" or lower)
-- w=5: Read-only query account (can only write to <author> blocks with no level)

-- Example: three users, three permission levels
INSERT INTO users VALUES ('admin',  MD5('admin123'), 'A');
INSERT INTO users VALUES ('mgr01',  MD5('mgr001'),   'A');
INSERT INTO users VALUES ('sales1', MD5('sales001'), 'B');

-- Menu groups
INSERT INTO mnu VALUES ('10', '-1', 'Sales Management',    '',            1);
INSERT INTO mnu VALUES ('20', '-1', 'Inventory Management', '',            1);
INSERT INTO mnu VALUES ('11', '10', 'Order Inquiry', 'order.wml',  1);
INSERT INTO mnu VALUES ('12', '10', 'Order Entry',   'order.wml',  1);
INSERT INTO mnu VALUES ('21', '20', 'Inventory Inquiry', 'inv.wml',    1);

-- admin (w=1): full access
INSERT INTO login VALUES ('admin', '11', 1);
INSERT INTO login VALUES ('admin', '12', 1);
INSERT INTO login VALUES ('admin', '21', 1);

-- mgr01 (w=2): can inquire and enter data, but level="1" blocks in order.wml are read-only
INSERT INTO login VALUES ('mgr01', '11', 2);
INSERT INTO login VALUES ('mgr01', '12', 2);

-- sales1 (w=3): can only inquire orders; level="2" or higher blocks in order.wml are read-only
INSERT INTO login VALUES ('sales1', '11', 3);
-- sales1 has no login record for '12' → the "Order Entry" menu item is disabled
```

---

## 8.9 Design-Point Summary

| Mechanism | Scope of Control | Condition Checked |
|---|---|---|
| `login.w = 0` or no record | Menu item disabled (feature not clickable) | `I=-1` → `<setprop enabled=0>` |
| `login.w > 0` | Menu item enabled, and `LoginLevel` set | `itm.w` written into `I` and `Wap.LoginLevel` |
| `<author>` with no `level` | Editable by all users | `Level=0`, `if Level>0` is false |
| `<author level="n">` | Read-only for users with `LoginLevel > n` | Delphi: `Writable := False` |
| `imageindex="$I"` | Dual role: icon + permission flag | `-1` means no icon and triggers disabling |
| `UPPER()` password comparison | Case-insensitive account matching | Recommended to upgrade to `MD5()` |
| `<prev/>` on validation failure | Back to the login dialog, allowing a retry | The semantics of `<prev/>` in an MDI card |

---

## Chapter 9　The Web Template System

🌐 **Web-only**

---

## 9.1 Concept: WML-Driven HTML Templates

One of WapForm for Web's core features is the **report-templating mechanism**: a static HTML template (such as `wapform.html`) defines the complete visual skeleton, while the WML program handles logic, data queries, and content output. The two are merged by the framework at runtime, producing the final complete HTML page.

The essence of it in one sentence:

> **WapForm's report-templating mechanism implements layout-driven component injection — the program doesn't actively assemble the page; the template defines the page structure, the program only declares the layout, and the framework automatically completes the wiring.**

This brings several key advantages:

- **Complete separation of visuals and logic**: front-end designers maintain HTML/CSS, back-end logic is written only in `.wml`, and neither interferes with the other.
- **One template, shared site-wide**: swap the template and you swap the whole site's appearance, with zero changes to WML logic.
- **The layout can evolve independently**: a designer moves a sidebar from the right to the left, or adds a new region — zero changes to WML logic; the back end changes a query — zero changes to the HTML.
- **Can plug into any HTML framework**: Bootstrap, Metronic, Tailwind — any static HTML can be used.

---

## 9.2 Triggered Blocks

Triggered blocks are WapForm's most distinctive design among frameworks of its kind, and the concrete realization of "layout-driven component injection."

### The Problem: Traditional Frameworks' Code Knows Too Much

In most frameworks (PHP, Django, Rails, Laravel Blade), page assembly is **program-led**:

```php
// The code decides what to assemble and where to put it
$this->render('layout', [
    'header'   => $this->renderHeader(),
    'sidebar'  => $this->renderSidebar($category),
    'content'  => $this->renderContent($articles),
    'footer'   => $this->renderFooter(),
]);
```

The code has to know what regions the layout has and what data each region needs. Change the layout (say, add a "related recommendations" column) and the code has to change along with it. Front end and back end are effectively coupled.

### WapForm's Approach: The Template Leads, the Program Only Declares the Layout

```xml
<!-- The WML code only needs to declare the layout name -->
<block name="onnote"/>
<!-- Done. The framework automatically handles everything else -->
```

This one line triggers the output of the `onnote` block in `wapform.html`, and inside that block, all the `#(card_id)` injection points are already arranged — when the framework sees `#(breadcrumb)`, it runs the `breadcrumb` sub card; when it sees `#(content)`, it runs the `content` sub card; when it sees `#(side)`, it runs the `side` sub card. **The code has no idea, and doesn't need to know, how many regions the layout has or where each one goes.**

```
Traditional frameworks need to write:      WapForm needs only one line:

  include('header.php')
  include('breadcrumb.php')    →    <block name="onnote"/>
  include('sidebar.php')
  include('content.php')
  include('footer.php')
```

### This Brings a Real Engineering Advantage

Because the layout structure exists in only one place — `wapform.html` — this means:

- A designer moves `onnote`'s sidebar from the right to the left — zero changes to WML
- A designer adds a `#(related)` recommendation block to `onnote` — only needs a new corresponding sub card, zero changes to the main WML flow
- The back end changes the `content` card's query logic — zero changes to HTML

Front end and back end can genuinely evolve independently, not just "be kept in separate files."

### The Implicit Naming Contract

This design has a cost that needs to be stated honestly: **the `#(card_id)` names in the template and the sub card `id`s in WML must match exactly** — this is an implicit naming contract, with no static type system checking it for you. If a sub card's `id` is misspelled, that region silently ends up blank, with no error thrown.

Development recommendation: first confirm which `#(...)` injection-point names the template uses, and build the sub cards to match — not the other way around.

### Full Walkthrough of the note.wml Example

`note.wml` is the best demonstration of the triggered-block mechanism: a knowledge-base document page containing a breadcrumb, a right-hand table-of-contents column, and left-hand article content — three completely independent regions, wired up with just one line:

```xml
<?xml version="1.0"?>
<wml>
  <card id="P" device="wapform.html">

    <!-- 1. Read the URL parameter -->
    <setvar name="gp" value="'note'"/>
    <setvar name="gp" value="request.gp" cnd="DEFINE(request.gp)"/>

    <!-- 2. Trace upward through category levels to find the top-level category id (up to three levels) -->
    <dbquery id="pa"><![CDATA[select des from pa where pno='$gp']]></dbquery>
    <setvar name="title" value="pa.des"/>

    <dbquery id="grp"><![CDATA[
      select pno, gid, des from pa where pno='$gp' and active>0
    ]]></dbquery>
    <setvar name="id" value="grp.pno"/>
    <setvar name="gid" value="grp.gid"/>
    <setvar name="category" value="grp.des"/>

    <if cnd="gid&lt;&gt;'0000'">
      <dbquery id="grp"><![CDATA[
        select pno, gid, des from pa where pno='$gid' and active>0
      ]]></dbquery>
      <setvar name="id" value="grp.pno"/>
      <setvar name="gid" value="grp.gid"/>
      <setvar name="category" value="grp.des"/>
      <if cnd="gid&lt;&gt;'0000'">
        <dbquery id="grp"><![CDATA[
          select pno, gid, des from pa where pno='$gid' and active>0
        ]]></dbquery>
        <setvar name="id" value="grp.pno"/>
        <setvar name="category" value="grp.des"/>
      </if>
    </if>

    <!-- 3. Assemble the page -->
    <block name="wapform.aa"/>
    <block name="wrapper.aa"/>
    <include name="header"/>

    <!-- ★ The key: one line triggers the onnote layout, automatically wiring up three sub cards -->
    <block name="onnote"/>

    <include name="footer"/>
    <include name="footer2"/>
    <block name="wrapper.zz"/>
    <block name="wapform.zz"/>
  </card>

  <!-- Sub card 1: breadcrumb -->
  <card id="breadcrumb" device="sub">
    <block name="breadcrumb" one="category"/>
  </card>

  <!-- Sub card 2: right-hand table-of-contents column -->
  <card id="side" device="sub">
    <block name="notebar.aa"/>
    <dbquery id="mnu"><![CDATA[
      select pno, gid, des, typ
      from pa where gid='$id' and active>0 order by pno
    ]]></dbquery>
    <while cnd="not(mnu.eof)">
      <dbquery id="itm"><![CDATA[
        select pno, gid, des
        from pa where gid='$mnu.pno' and active>0 order by pno
      ]]></dbquery>
      <if cnd="itm.count&gt;0">
        <block name="notebar-list.aa"/>
        <while cnd="not(itm.eof)">
          <block name="notebar-item"/>
          <invoke instance="itm" method="next"/>
        </while>
        <block name="notebar-list.zz"/>
      <else/>
        <block name="notebar-mark"/>
      </if>
      <invoke instance="mnu" method="next"/>
    </while>
    <block name="notebar.zz"/>
  </card>

  <!-- Sub card 3: main content area -->
  <card id="content" device="sub">
    <dbquery id="pa"><![CDATA[
      select pno, gid, des, typ, topic
      from pa where gid='$gp' and active>0 order by pno
    ]]></dbquery>
    <if cnd="pa.count&gt;0">
      <!-- Has sub-items: output an article-list card -->
      <![CDATA[<div id="xyz"><article>]]>
      <block name="shop.aa"/>
      <block name="shop-list.aa" column="5"/>
      <while cnd="not(pa.eof)">
        <block name="shop-note"/>
        <invoke instance="pa" method="next"/>
      </while>
      <block name="shop-list.zz"/>
      <block name="shop.zz"/>
      <![CDATA[</article></div>]]>
    <else/>
      <!-- No sub-items: AJAX-load the article body -->
      <![CDATA[<div id="note"></div>
      <script>loadDoc('note','note-js.wml?pg=$gp');</script>]]>
    </if>
  </card>

</wml>
```

### The Triggered Block's Execution Flow

The line `<block name="onnote"/>` triggers the following complete flow:

```
<block name="onnote"/>
         │
         ▼
The <!-- onnote.aa --> block in wapform.html begins outputting
┌─────────────────────────────────────────────────────┐
│  #(breadcrumb)                                      │
│      └─► Runs <card id="breadcrumb" device="sub">  │
│           <block name="breadcrumb" one="category"/> │
│           Outputs the "Home > Manual" breadcrumb HTML │
│                                                     │
│  <div class="d-flex flex-column flex-xl-row">       │
│    <div class="flex-lg-row-fluid">                  │
│      #(content)                                     │
│          └─► Runs <card id="content" device="sub"> │
│               Queries pa where gid='$gp'           │
│               if has sub-items → outputs article card list │
│               else             → outputs the AJAX-load script │
│    </div>                                           │
│    <div class="mw-lg-300px">                        │
│      #(side)                                        │
│          └─► Runs <card id="side" device="sub">   │
│               Queries the menu database, outputs the directory tree with while │
│    </div>                                           │
│  </div>                                             │
└─────────────────────────────────────────────────────┘
<!-- onnote.zz -->
```

Corresponding to the template definition in `wapform.html`:

```html
<!-- onnote.aa -->
#(breadcrumb)
<div class="d-flex flex-column-fluid align-items-start container-xxl xyz">
    <div class="content flex-row-fluid py-10 xyz">
        <div class="d-flex flex-column flex-xl-row p-7 xyz">

            <div class="flex-lg-row-fluid me-xl-15 mb-20 xyz">
                #(content)      ← Main content: article list, or an AJAX-loaded article
            </div>

            <div class="flex-column flex-lg-row-auto mw-lg-300px mw-xxl-350px">
                <div class="card-rounded bg-primary bg-opacity-5 p-10 cls">
                    #(side)     ← Sidebar: table of contents
                </div>
            </div>

        </div>
    </div>
</div>
<!-- onnote.zz -->
```

**The key point**: the three sub cards (`breadcrumb`, `content`, `side`) each write their own logic independently, with no need to know of each other's existence, and no need to know where they're placed on the page — the layout is entirely determined by the template.

---

## 9.3 HTML Template Structure: Block Markers

`wapform.html` uses HTML comments to mark the boundaries of every **named block**, with the naming convention `blockname.aa` (start) / `blockname.zz` (end):

```html
<!-- wapform.aa -->
<head>
  <title>...</title>
  <link rel="stylesheet" href="assets/css/style.bundle.css"/>
  <!-- $(var('idx',-1)) -->  ← Initializes a cross-block counter
</head>
<body>

<!-- wrapper.aa -->
<div class="d-flex flex-column flex-root app-root">

  <!--menu.aa-->
    <!--menu-link.aa--><!--menu-link.zz-->
    <!--menu-list.aa-->
      <!--menu-item.aa--><a href="$(app).wml?gp=$(itm.pno)">$itm.des</a><!--menu-item.zz-->
    <!--menu-list.zz-->
  <!--menu.zz-->
  $(menu)                    ← varblock injection point

  <!-- onnote.aa -->
  #(breadcrumb)              ← sub card injection point
  <div ...>
    #(content)               ← sub card injection point
    #(side)                  ← sub card injection point
  </div>
  <!-- onnote.zz -->

  <!-- footer.aa -->
  <div>
    $(sys.company)
    <!-- footer-item.aa --><a href="$(app).wml?gp=$(itm.pno)">$itm.des</a><!-- footer-item.zz -->
  </div>
  <!-- footer.zz -->
  $(footer)                  ← varblock injection point

<!-- wrapper.zz -->
<!-- wapform.zz -->
<script src="assets/js/scripts.bundle.js"></script>
```

### Marker Syntax Reference

| Syntax | Description |
|---|---|
| `<!-- blockname.aa -->` | Start of a named block |
| `<!-- blockname.zz -->` | End of a named block |
| `#(card_id)` | Sub card injection point; the framework automatically calls the corresponding sub card |
| `$(varname)` | Variable or varblock accumulated-result injection point |

---

## 9.4 Layout Modes: Choosing `<block name="on..."/>`

`wapform.html` pre-defines several layouts, each with its `#(...)` injection points arranged differently. WML only needs to call one line, and the layout is set:

| `<block name="..."/>` | Layout Description | Injection Points |
|---|---|---|
| `onreport` | Standard layout: breadcrumb + full-width content | `#(breadcrumb)` `#(content)` |
| `onshop` | E-commerce layout: breadcrumb + left sidebar + main content | `#(breadcrumb)` `#(side)` `#(content)` |
| `onfull` | Full-width layout: breadcrumb + no sidebar | `#(breadcrumb)` `#(content)` |
| `onnote` | Document layout: breadcrumb + main content + right sidebar | `#(breadcrumb)` `#(content)` `#(side)` |
| `onzero` | Minimal layout: breadcrumb + content only | `#(breadcrumb)` `#(content)` |
| `onpage` | Article layout: padded card frame | `#(breadcrumb)` `#(content)` |
| `onlogin` | Login layout: centered card, no top navigation | `#(content)` |

**The same set of sub cards, paired with a different layout block, produces a completely different page structure**, with no changes needed to WML logic at all:

```xml
<block name="onnote"/>    → Document layout: main text left + table of contents right
<block name="onfull"/>    → Full-width layout: main text, no sidebar
<block name="onlogin"/>   → Login layout: centered card
```

---

## 9.5 The notebar Directory Tree: Side Sub Cards in Detail

`note.wml`'s `side` card demonstrates running a **two-level nested query** inside a sub card, dynamically assembling an expandable directory tree:

```xml
<card id="side" device="sub">
  <block name="notebar.aa"/>        ← Start of the directory container (includes the category title $category)

  <dbquery id="mnu"><![CDATA[
    select pno, gid, des, typ
    from pa where gid='$id' and active>0 order by pno
  ]]></dbquery>

  <while cnd="not(mnu.eof)">
    <dbquery id="itm"><![CDATA[
      select pno, gid, des
      from pa where gid='$mnu.pno' and active>0 order by pno
    ]]></dbquery>

    <if cnd="itm.count&gt;0">
      <!-- Has sub-items: an expandable group -->
      <block name="notebar-list.aa"/>
      <while cnd="not(itm.eof)">
        <block name="notebar-item"/>
        <invoke instance="itm" method="next"/>
      </while>
      <block name="notebar-list.zz"/>
    <else/>
      <!-- No sub-items: a leaf-node link -->
      <block name="notebar-mark"/>
    </if>

    <invoke instance="mnu" method="next"/>
  </while>

  <block name="notebar.zz"/>
</card>
```

Corresponding to four directory blocks in `wapform.html`:

```html
<!-- notebar.aa -->
<div class="menu menu-column" id="kt_docs_aside_menu" data-kt-menu="true">
    <div class="menu-item">
        <h4 class="menu-content text-muted mb-0 fs-7">$category</h4>
    </div>

    <!-- notebar-mark.aa -->
    <!-- Leaf node: direct link, clicking AJAX-loads the article -->
    <div class="menu-item">
        <a class="menu-link py-2"
           href="javascript:loadDoc('note','note-js.wml?pg=$mnu.pno')">
            <span class="menu-title">$mnu.des</span>
        </a>
    </div>
    <!-- notebar-mark.zz -->

    <!-- notebar-list.aa -->
    <!-- Group node: expandable, contains sub-items -->
    <div data-kt-menu-trigger="click" class="menu-item menu-accordion">
        <span class="menu-link py-2">
            <span class="menu-title">$mnu.des</span>
            <span class="menu-arrow"></span>
        </span>
        <div class="menu-sub menu-sub-accordion">

            <!-- notebar-item.aa -->
            <div class="menu-item">
                <a class="menu-link py-2"
                   href="javascript:loadDoc('note','note-js.wml?pg=$itm.pno')">
                    <span class="bullet bullet-dot"></span>
                    <span class="menu-title">$itm.des</span>
                </a>
            </div>
            <!-- notebar-item.zz -->

        </div>
    </div>
    <!-- notebar-list.zz -->

<!-- notebar.zz -->
</div>
```

Every link in the directory is `javascript:loadDoc(...)` — clicking it doesn't navigate to a new page; it uses AJAX to directly replace the article in the main content area. That's the focus of the next section.

---

## 9.6 AJAX On-Demand Loading and the `<wap>` Tag

### The content Sub Card's Two Paths

`note.wml`'s `content` card takes one of two paths depending on the data:

```xml
<card id="content" device="sub">
  <dbquery id="pa"><![CDATA[
    select pno, gid, des, typ, topic
    from pa where gid='$gp' and active>0 order by pno
  ]]></dbquery>

  <if cnd="pa.count&gt;0">
    <!-- Path A: gp is a category node with sub-items → output an article card list -->
    <![CDATA[<div id="xyz"><article>]]>
    <block name="shop.aa"/>
    <block name="shop-list.aa" column="5"/>
    <while cnd="not(pa.eof)">
      <block name="shop-note"/>
      <invoke instance="pa" method="next"/>
    </while>
    <block name="shop-list.zz"/>
    <block name="shop.zz"/>
    <![CDATA[</article></div>]]>

  <else/>
    <!-- Path B: gp is a leaf node, directly an article → AJAX-load the body -->
    <![CDATA[
    <div id="note"></div>
    <script>loadDoc('note','note-js.wml?pg=$gp');</script>
    ]]>
  </if>
</card>
```

**Path A**: `gp` points to a category with sub-articles beneath it; outputs article cards for the user to choose from.

**Path B**: `gp` points directly to a single article; to avoid making the main page framework wait for a long article to load, it's fetched on-demand via AJAX instead.

### `loadDoc()` — the Template's Built-In AJAX Function

`wapform.html` pre-declares this in `<head>`:

```javascript
function loadDoc(id, url) {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (xhttp.readyState == 4 && xhttp.status == 200) {
            document.getElementById(id).innerHTML = xhttp.responseText;
        }
    }
    xhttp.open("GET", url, true);
    xhttp.send();
}
```

Two usage scenarios:

**Scenario 1**: the content card's Path B, called immediately once the page finishes loading:

```html
<div id="note"></div>
<script>loadDoc('note', 'note-js.wml?pg=$gp');</script>
```

**Scenario 2**: a notebar directory link, called when the user clicks it, replacing the same `<div id="note">`:

```html
<a href="javascript:loadDoc('note', 'note-js.wml?pg=$itm.pno')">
    $itm.des
</a>
```

Both point to `note-js.wml`; they differ only in when they're triggered. The page frame is built only once, and the article body can be swapped an unlimited number of times.

### `note-js.wml` and the `<wap>` Tag

`note-js.wml` is a minimal WML file designed specifically for AJAX responses:

```xml
<?xml version="1.0"?>
<wml>
  <card id="P" device="wapform-js.html">
    <setvar name="pg" value="'500120001'"/>
    <setvar name="pg" value="request.pg" cnd="DEFINE(request.pg)"/>
    <dbquery id="pa">
      select pno, des, topic from pa where pno='$pg'
    </dbquery>
    <wap>
      <![CDATA[<article>$(pa.topic)</article>]]>
    </wap>
  </card>
</wml>
```

**`device="wapform-js.html"`** — uses a lightweight template with no complete page skeleton (no header, footer, or menu), outputting only a plain HTML fragment.

**The `<wap>` tag** — Web-only, marks "output this content only in Web mode." It queries the database to get `pa.topic` (the article's HTML body) and returns it wrapped in `<article>`.

The response to the AJAX request `note-js.wml?pg=500120001` is a plain HTML fragment:

```html
<article>
  (article HTML body)
</article>
```

Once `loadDoc()` receives it, it's placed directly into `<div id="note">` — the page doesn't reload, and the framework structure (header, directory column) stays unchanged.

### The Overall Data Flow

```
User visits note.wml?gp=500100
        │
        ▼
Main card: traces up through three category levels, sets id, category
        │
        ▼
<block name="onnote"/> triggers

  ├─ #(breadcrumb) → breadcrumb card
  │    <block name="breadcrumb" one="category"/>
  │    → Outputs "Home > Manual"
  │
  ├─ #(content) → content card
  │    Queries pa where gid='500100'
  │    if pa.count > 0
  │      → Outputs an article card list (the shop-note block)
  │    else
  │      → Outputs an empty div + loadDoc('note','note-js.wml?pg=500100')
  │         │  AJAX call after the page loads
  │         └─► note-js.wml?pg=500100
  │               Queries pa where pno='500100'
  │               <wap> outputs <article>$pa.topic</article>
  │               ↩ Returns a plain HTML fragment, placed into <div id="note">
  │
  └─ #(side) → side card
       Queries mnu where gid='$id' (the top-level category's sub-items)
       while over each level-1 item
         Queries itm (level-2 items)
         if itm.count > 0
           → notebar-list.aa + notebar-item × N + notebar-list.zz
             Each notebar-item link:
             javascript:loadDoc('note','note-js.wml?pg=$itm.pno')
         else
           → notebar-mark (a leaf node, also pointing at loadDoc)
       → The directory tree is complete

User clicks a directory link
  → loadDoc('note','note-js.wml?pg=500120001')
  → AJAX fetches the new article HTML
  → Placed into <div id="note"> (no full-page reload)
```

---

## 9.7 Three Content-Injection Mechanisms

WapForm's templating has three injection methods in total, each suited to different scenarios:

### `#(card_id)` — Synchronous Sub Card Injection

When the framework outputs the template HTML and encounters `#(card_id)`, it immediately runs the corresponding sub card:

```html
#(breadcrumb)   ← Synchronously runs <card id="breadcrumb" device="sub">
#(content)      ← Synchronously runs <card id="content"    device="sub">
#(side)         ← Synchronously runs <card id="side"       device="sub">
```

### `$(varname)` — varblock Pre-Accumulated Injection

In the WML flow, `<varblock>` accumulates HTML into a named variable piece by piece, and `$(varname)` at the end of the template inserts it all at once:

```xml
<report dataset="mnu">
  <varblock name="footer" block="footer.aa"/>
    <varblock name="footer" block="footer-item"/>
  <varblock name="footer" block="footer.zz"/>
</report>
```

```html
$(footer)    ← Inserts the complete accumulated footer HTML
$(footer2)
```

### `loadDoc()` — Asynchronous AJAX Injection

An empty div is reserved, and after the page loads or when the user clicks, an HTML fragment is fetched asynchronously from a lightweight WML file and placed in:

```html
<div id="note"></div>
<script>loadDoc('note', 'note-js.wml?pg=$gp');</script>
```

**Comparing the three mechanisms:**

| Mechanism | Trigger Timing | Suited For | Declaration Method |
|---|---|---|---|
| `#(card_id)` | Synchronously, when the framework outputs the template | Main content area, breadcrumb, sidebar | sub card + template injection point |
| `$(varname)` | Pre-accumulated during the WML flow, output all at once | Accumulator structures like menus, footers | `<varblock>` + template variable |
| `loadDoc()` | After the page loads, or on user click | Long articles, on-demand replacement | Empty div + JS + lightweight WML |

---

## 9.8 Two Kinds of HTML Templates

| Property | `wapform.html` | `wapform-js.html` |
|---|---|---|
| Purpose | Complete page skeleton | Plain content fragment for AJAX responses |
| Contains | CSS/JS/header/footer/menu | Minimal wrapping only |
| WML `device` value | `"wapform.html"` | `"wapform-js.html"` |
| Tags used with it | `<block>`, sub card, `<varblock>` | `<wap>` |
| Injection mechanism | `#(card_id)`, `$(varname)` | `loadDoc()` AJAX |

---

## 9.9 Parameter Passing on `<block>` Calls

When `<block>` calls a template block, it can carry arbitrary attributes as named parameters, which the block's HTML accesses with `$attributename`:

```xml
<block name="breadcrumb" one="category"/>
<block name="shop-list.aa" column="5"/>
<block name="card-url"
       href="midb(s,j+1,lenb(s)-j)"
       style="btn[midb(s,1,1)]"
       link="midb(s,i+1,j-i-1)"/>
```

```html
<!-- breadcrumb.aa -->
<ul class="breadcrumb">
    <li><a href="index.wml">Home</a></li>
    <li>$one</li>       ← Accesses the passed-in one parameter (= the value of the category variable)
    <li>$category</li>
</ul>
<!-- breadcrumb.zz -->
```

Parameter values support the full WapForm expression syntax, evaluated at call time before being passed in.

---

## 9.10 Expressions and State Functions Inside Templates

WapForm expressions can be used directly inside `wapform.html`, evaluated by the framework as part of the templating process:

```html
<h6>$(sys.company)</h6>
<a href="$(app).wml?gp=$(itm.pno)">$itm.des</a>
<ins class="$(IF(pa.pricec&gt;0,'text-red',''))">
    On sale $(IF(pa.pricea&gt;pa.price1,99999,pa.price1))
</ins>
<section style="background-color:$('#'+COLOR2HEX(color[inc('idx',1) mod 5]));">
```

### `var()` and `inc()` — Template Cross-Block State Functions

| Function | Description |
|---|---|
| `var('name', default)` | Reads a state variable; initializes it with `default` and returns that if it doesn't yet exist |
| `inc('name', step)` | Increments a state variable by `step`, then returns the new value |

```html
<!-- Initialized in wapform.aa -->
<!-- $(var('idx',-1)) -->

<!-- Auto-increments in each output block, producing a 5-color cycling background -->
<section style="background-color:$('#'+COLOR2HEX(color[inc('idx',1) mod 5]));">
```

`var()`/`inc()`'s state stays valid throughout the entire page-request cycle, and the count can be shared across the output of multiple sub cards.

---

## 9.11 Full Correspondence: note.wml ↔ wapform.html

```
note.wml                               wapform.html
─────────────────────────────────────────────────────────────────────
<card id="P" device="wapform.html">    ← Specifies the template

Traces up through three category      (The main card is pure flow, no
levels, sets id, category              template involvement here)

<block name="wapform.aa"/>             <!-- wapform.aa -->
                                       <head>CSS/JS</head><body>
                                       <!-- $(var('idx',-1)) -->

<block name="wrapper.aa"/>             <!-- wrapper.aa -->
                                       <div class="d-flex flex-column...">

<include name="header"/>               ← header.wml runs, outputs the nav bar
                                       The template's $(menu) inserts the menu varblock result

<block name="onnote"/>                 ← ★ Triggers the block
                                       <!-- onnote.aa -->
                                       #(breadcrumb)
  <card id="breadcrumb" device="sub">  ├─ breadcrumb card runs
    <block name="breadcrumb"           │    <!-- breadcrumb.aa -->
           one="category"/>            │    Home > $one (= category)
                                       │    <!-- breadcrumb.zz -->
                                       <div class="flex-xl-row">
                                         <div class="flex-lg-row-fluid">
                                           #(content)
  <card id="content" device="sub">     ├─ content card runs
    if pa.count > 0                    │    Path A: outputs an article card list
      <block name="shop-note"/> × N    │    Path B: outputs an empty div + loadDoc()
    else                               │            ↓ AJAX
      loadDoc('note','note-js.wml')    │      note-js.wml
                                       │      <wap> <article>$pa.topic
                                         </div>
                                         <div class="mw-lg-300px">
                                           #(side)
  <card id="side" device="sub">        └─ side card runs
    notebar.aa                              Directory tree HTML
    while mnu                               Each link: loadDoc(...)
      if itm.count > 0
        notebar-list + notebar-item × N
      else
        notebar-mark
    notebar.zz
                                       </div>
                                       <!-- onnote.zz -->

<include name="footer"/>               footer card → varblock → $footer
<include name="footer2"/>              footer2 card → varblock → $footer2
                                       Inserted at the end of the template: $(footer)$(footer2)

<block name="wrapper.zz"/>             <!-- wrapper.zz --> </div>
<block name="wapform.zz"/>             <!-- wapform.zz --> JS </body>
```

---

## 9.12 Report-Templating Mechanism Summary

| Rule | Description |
|---|---|
| `device="wapform.html"` | The main card specifies the template; the framework uses this HTML as the skeleton |
| `device="wapform-js.html"` | A lightweight template dedicated to AJAX fragments, used with `<wap>` |
| `device="sub"` | The sub card corresponding to an injection point; outputs only an HTML fragment |
| `<block name="on..."/>` | Triggers a layout block, one line automatically wiring up all `#(...)` injection points |
| `<block name="x"/>` | Calls the HTML from `<!-- x.aa -->` to `<!-- x.zz -->` in the template |
| `#(card_id)` | A template injection point; the framework synchronously runs the corresponding sub card |
| `$(varname)` | Inserts a WapForm variable or a varblock's accumulated result |
| `<varblock>` | Accumulates HTML piece by piece into a named variable within a loop |
| `loadDoc(id, url)` | AJAX on-demand loading, filled into the specified div |
| `<wap>` | Inside an AJAX-response WML file, marks that only this section of HTML should be output |
| Block parameters | Passed in via `<block name="x" param="val"/>`, accessed inside the block as `$param` |
| `var()` / `inc()` | Cross-block counter state within the template, used for scenarios like cycling colors |

---

## Chapter 10　Charts

🖥️ **Win** ✅ | 🌐 **Web** ✅

---

## 10.1 Overview

WapForm's `<chart>` element lets developers produce interactive charts by declaring them directly in WML, without writing any JavaScript. There are two ways to source chart data:

- **Dataset-driven**: bind a `<dbquery>` dataset, with fields automatically mapped to the axes.
- **Programmatically generated**: inside `<serie>`, use a `<while>` or `<for>` loop paired with `<point>` to inject data points one by one.

The two methods can be mixed, and a single `<chart>` supports multiple `<serie>` elements (multiple series), letting different chart types be layered on the same chart.

---

## 10.2 Basic Structure

```xml
<chart title="Chart Title" ...chart attributes...>
  <serie type="chart type" ...series attributes...>
    <!-- Data source: choose one of two -->

    <!-- Method 1: programmatically generate data points -->
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(100,300)"/>
    </while>

    <!-- Method 2: bind a dataset (declare dataset at the <chart> level, <point> omitted here) -->
  </serie>

  <!-- A second series can be added -->
  <serie type="line" ...>...</serie>
</chart>
```

---

## 10.3 `<chart>` — Chart Container Attributes

| Attribute | Required/Optional | Description |
|---|---|---|
| `title` | Optional | Chart title text |
| `dataset` | Optional | Bound dataset name (dataset-driven mode) |
| `rangeto` | Optional | Maximum X-axis scale value (for axis range in dataset mode) |
| `legend` | Optional | `"yes"` shows the legend |
| `autocolor` | Optional | `"yes"` automatically applies a different color to each data point (commonly used for pie-type charts) |
| `xaxisposition` | Optional | X-axis position; set to `"none"` to hide the X axis |
| `yaxisposition` | Optional | Y-axis position; set to `"none"` to hide the Y axis |
| `titlefontsize` | Optional | Title font size (points) |
| `xresult` | Optional | Stores the chart's output result into the specified variable (e.g. `"s"`) |

---

## 10.4 `<serie>` — Series Attributes

### Common Attributes (All Chart Types)

| Attribute | Required/Optional | Description |
|---|---|---|
| `type` | Required | The chart type (see the complete list in Section 10.6) |
| `color` | Optional | Fill color (`#RRGGBB`), used for chart types with a filled area, such as bar, area, pie |
| `linecolor` | Optional | Line color (`#RRGGBB`), used for line, digitalline |
| `linewidth` | Optional | Line width (pixels) |
| `opacity` | Optional | Opacity (0–255, used for area types) |
| `marker` | Optional | `"yes"` shows marker points at data points (used for line) |
| `valuewidth` | Optional | Data-point width (pixels, used for bar) |
| `title` | Optional | Series name (shown in the legend) |

### Dataset-Binding Attributes

| Attribute | Required/Optional | Description |
|---|---|---|
| `fieldnamevalue` | Optional | The value field name (dataset-driven mode) |
| `fieldnamexaxis` | Optional | The X-axis label field name; set to `"no"` to use automatic sequence numbers |

### Attributes Specific to Pie/Donut Types

| Attribute | Required/Optional | Description |
|---|---|---|
| `pielegend` | Optional | `"yes"` shows the pie legend |
| `pieposition` | Optional | `"custom"` for a custom pie position |
| `pieleft` | Optional | Pie center X coordinate (pixels) |
| `pietop` | Optional | Pie center Y coordinate (pixels) |
| `piesize` | Optional | Pie radius (pixels) |
| `pieshowvalues` | Optional | `"yes"` shows values on the slices |
| `pieshowlegendonslice` | Optional | `"yes"` shows labels on the slices |
| `pievalueposition` | Optional | `"outside"` shows value labels outside the slices |

---

## 10.5 `<point>` — Data Points

```xml
<point label="Label Text" value="Value" color="C[I mod 5]"/>
```

| Attribute | Required/Optional | Description |
|---|---|---|
| `label` | Required | X-axis label or legend name; supports expressions |
| `value` | Required | Y-axis value; supports expressions (including functions, variables) |
| `color` | Optional | Individual data-point color (array index or `#RRGGBB`) |

`<point>` is typically generated dynamically inside a `<while>` or `<for>` loop, but can also be listed statically one by one.

---

## 10.6 Complete Chart-Type List

WapForm supports 12 chart types, grouped by category:

### Line Types

#### `line` — Line Chart

Continuous value trends, supports layering multiple series.

```xml
<chart title="line" rangeto="11" dataset="xy" legend="yes">
  <serie type="line" linecolor="#f37735" linewidth="2"
         fieldnamevalue="a" fieldnamexaxis="no">
  </serie>
  <serie type="line" linecolor="#00aedb" linewidth="2"
         fieldnamevalue="b" fieldnamexaxis="no" marker="yes">
  </serie>
</chart>
```

- `dataset="xy"` binds the query result, `fieldnamevalue` specifies the value field.
- `marker="yes"` adds a marker dot at each data point.
- Multiple `<serie>` elements are automatically layered on the same chart.

#### `digitalline` — Digital Line Chart

A stepped line, suitable for expressing discrete state changes (such as on/off, 0/1 values). Supports negative values.

```xml
<chart title="digitalline" rangeto="11">
  <serie type="digitalline" linecolor="#f37735" linewidth="2">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(-300,300)"/>
    </while>
  </serie>
</chart>
```

---

### Bar Types

#### `bar` — Grouped Bar Chart

Side-by-side bars, suitable for multi-category comparisons.

```xml
<chart title="bar" rangeto="11">
  <serie type="bar" color="#f37735" valuewidth="60">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(100,300)"/>
    </while>
  </serie>
  <serie type="bar" color="#00aedb" valuewidth="60">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(100,300)"/>
    </while>
  </serie>
</chart>
```

- `valuewidth` controls the width of each bar.
- Multiple `<serie>` elements are shown side by side (grouped mode).

#### `stackedbar` — Stacked Bar Chart

Multiple series' values stacked vertically, suitable for showing composition proportions and totals.

```xml
<chart title="stackedbar" rangeto="11">
  <serie type="stackedbar" color="#f37735">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(100,300)"/>
    </while>
  </serie>
  <serie type="stackedbar" color="#00aedb">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(100,300)"/>
    </while>
  </serie>
</chart>
```

#### `histogram` — Histogram

A single-series bar chart, supports negative values (bars extending downward), suitable for frequency distributions.

```xml
<chart title="histogram" rangeto="11">
  <serie type="histogram">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(-300,300)"/>
    </while>
  </serie>
</chart>
```

---

### Area Types

#### `area` — Area Chart

Fills the area below the line, with `opacity` controlling transparency, suitable for visualizing trend and magnitude together.

```xml
<chart title="area" rangeto="11">
  <serie type="area" color="#f37735" opacity="150">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(100,300)"/>
    </while>
  </serie>
  <serie type="area" color="#00aedb" opacity="150">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(100,300)"/>
    </while>
  </serie>
</chart>
```

- `opacity="150"` sets the fill's transparency (0=fully transparent, 255=opaque); when multiple series overlap, the layer underneath remains visible.

#### `stackedarea` — Stacked Area Chart

Multiple series' areas stacked vertically, suitable for showing individual amounts and the aggregate trend at the same time.

```xml
<chart title="stackedarea" rangeto="11">
  <serie type="stackedarea" color="#f37735">
    ...
  </serie>
  <serie type="stackedarea" color="#00aedb">
    ...
  </serie>
</chart>
```

---

### Pie Types

Pie-type charts usually hide the X/Y axes (`xaxisposition="none" yaxisposition="none"`), and control their appearance via a set of `pie*` attributes.

#### `pie` — Pie Chart

Each slice's area is proportional, suitable for showing shares of a whole. Each `<point>` can specify its own color.

```xml
<setvar name="C" value="[0..9]"/>
<setvar name="C[0]" value="#00aedb"/>
<setvar name="C[1]" value="#a200ff"/>
<setvar name="C[2]" value="#f47835"/>
<setvar name="C[3]" value="#d41243"/>
<setvar name="C[4]" value="#8ec127"/>

<chart title="pie" xaxisposition="none" yaxisposition="none">
  <serie type="pie"
         pielegend="yes"
         pieposition="custom" pieleft="120" pietop="100"
         pieshowvalues="yes" pieshowlegendonslice="yes"
         pievalueposition="outside" piesize="90">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;5">
      <point label="$('A'+STR(I))" value="RandomRange(100,300)" color="C[I mod 5]"/>
      <setvar name="I" value="I+1"/>
    </while>
  </serie>
</chart>
```

- The color array `C[]` is declared ahead of time outside the chart, applied one by one with `<point color="C[I mod 5]">`.
- `pievalueposition="outside"` shows value labels outside the slices.

#### `donut` — Donut Chart

The pie's center is hollowed out, suitable for pairing with center text. `autocolor="yes"` lets the framework auto-assign colors.

```xml
<chart title="donut" autocolor="yes" xaxisposition="none" yaxisposition="none">
  <serie type="donut"
         pielegend="yes"
         pieposition="custom" pieleft="120" pietop="100"
         pieshowvalues="yes" pieshowlegendonslice="yes"
         pievalueposition="outside" piesize="90">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=5">
      <setvar name="I" value="I+1"/>
      <point label="$('A'+STR(I))" value="RandomRange(100,300)"/>
    </while>
  </serie>
</chart>
```

#### `sizedpie` — Sized Pie Chart

Slice area is represented by the circle's size (not angle), suitable for emphasizing differences in absolute magnitude.

```xml
<chart title="sizedpie" autocolor="yes" xaxisposition="none" yaxisposition="none">
  <serie type="sizedpie"
         pielegend="yes"
         pieposition="custom" pieleft="120" pietop="100"
         pieshowvalues="yes" pieshowlegendonslice="yes"
         pievalueposition="outside" piesize="90">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=5">
      <setvar name="I" value="I+1"/>
      <point label="$('A'+STR(I))" value="RandomRange(200,300)"/>
    </while>
  </serie>
</chart>
```

#### `sizeddonut` — Sized Donut Chart

The donut version of `sizedpie`.

```xml
<chart title="sizeddonut" autocolor="yes" xaxisposition="none" yaxisposition="none">
  <serie type="sizeddonut" ...>
    ...
  </serie>
</chart>
```

---

### Radar Types

#### `spider` — Spider Chart (Radar Chart)

Multi-dimensional metric comparison, with each axis radiating outward from the center. Also uses the `pie*` attribute group to control layout.

```xml
<chart title="spider" xaxisposition="none" yaxisposition="none">
  <serie type="spider"
         color="#f37735"
         pielegend="yes"
         pieposition="custom" pieleft="120" pietop="100"
         pieshowvalues="yes" pieshowlegendonslice="yes"
         pievalueposition="outside" piesize="90">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=5">
      <setvar name="I" value="I+1"/>
      <point label="$('A'+STR(I))" value="RandomRange(10,20)"/>
    </while>
  </serie>
</chart>
```

---

## 10.7 Chart-Type Quick Reference

| Chart Type `type` | Name | Negative Values | Multiple Series | Auto Color | Suited For |
|---|---|---|---|---|---|
| `line` | Line chart | ✅ | ✅ | ❌ | Trends, time series |
| `digitalline` | Digital line chart | ✅ | ✅ | ❌ | State changes, 0/1 signals |
| `bar` | Grouped bar chart | ❌ | ✅ | ❌ | Category comparison |
| `stackedbar` | Stacked bar chart | ❌ | ✅ | ❌ | Composition proportion + total |
| `histogram` | Histogram | ✅ | ❌ | ❌ | Frequency distribution, positive/negative values |
| `area` | Area chart | ❌ | ✅ | ❌ | Trend + magnitude |
| `stackedarea` | Stacked area chart | ❌ | ✅ | ❌ | Composition trend |
| `pie` | Pie chart | ❌ | ❌ | ⚠️ Manual | Share of total (individual coloring) |
| `donut` | Donut chart | ❌ | ❌ | ✅ | Share of total (auto coloring) |
| `sizedpie` | Sized pie chart | ❌ | ❌ | ✅ | Absolute-magnitude differences |
| `sizeddonut` | Sized donut chart | ❌ | ❌ | ✅ | Absolute-magnitude differences (donut) |
| `spider` | Spider chart | ❌ | ❌ | ❌ | Multi-dimensional radar |

---

## 10.8 Data Sources: Two Modes

### Mode 1: Dataset-Driven

`<chart>` binds a `<dbquery>` dataset, and `<serie>` specifies fields via `fieldnamevalue` / `fieldnamexaxis`, with no `<point>` needed:

```xml
<dbquery id="xy"><![CDATA[
  SELECT TOP 12 no, a, b FROM zp
]]></dbquery>

<chart title="Monthly Sales Trend" rangeto="11" dataset="xy" legend="yes">
  <serie type="line" linecolor="#f37735" linewidth="2"
         fieldnamevalue="a" fieldnamexaxis="no">
  </serie>
  <serie type="line" linecolor="#00aedb" linewidth="2"
         fieldnamevalue="b" fieldnamexaxis="no" marker="yes">
  </serie>
</chart>
```

- `fieldnamexaxis="no"` uses automatic integer sequence numbers as X-axis labels; supplying a field name uses that field's value instead.
- `rangeto="11"` specifies the maximum scale displayed on the X axis.

### Mode 2: Programmatically Generated Data Points

Inject dynamically inside `<serie>` using a `<while>` / `<for>` loop + `<point>`, suitable for scenarios needing real-time computation or that don't rely on a fixed query format:

```xml
<chart title="Random Distribution" rangeto="11">
  <serie type="bar" color="#f37735" valuewidth="60">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(100,300)"/>
    </while>
  </serie>
</chart>
```

- `RandomRange(min, max)` produces a random integer within the range (a 🌐 **Web** environment function).
- Both `label` and `value` support the full WapForm expression syntax.

### Mixed Example: Database + Dynamic Computation

```xml
<dbquery id="sales"><![CDATA[
  SELECT month, amount FROM monthly_sales WHERE year=$year
]]></dbquery>

<chart title="Sales vs. Target" dataset="sales" legend="yes">
  <!-- Series 1: reads actual sales from the dataset -->
  <serie type="bar" color="#00aedb"
         fieldnamevalue="amount" fieldnamexaxis="month">
  </serie>
  <!-- Series 2: target value (a fixed constant, injected via a loop) -->
  <serie type="line" linecolor="#f47835" linewidth="2">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="500000"/>
    </while>
  </serie>
</chart>
```

---

## 10.9 Color-Array Technique

Individual data-point coloring for pie charts, by pre-declaring a color array and referencing it by index:

```xml
<!-- Declare the color array at the top level of the card -->
<setvar name="C" value="[0..9]"/>
<setvar name="C[0]" value="#00aedb"/>
<setvar name="C[1]" value="#a200ff"/>
<setvar name="C[2]" value="#f47835"/>
<setvar name="C[3]" value="#d41243"/>
<setvar name="C[4]" value="#8ec127"/>

<!-- Cycle through colors with mod inside <point> -->
<while cnd="I&lt;5">
  <point label="$('Category '+STR(I))"
         value="RandomRange(100,300)"
         color="C[I mod 5]"/>
  <setvar name="I" value="I+1"/>
</while>
```

`color="C[I mod 5]"` passes in an array element (a `"#RRGGBB"` string); `mod 5` makes the color cycle without going out of the array's bounds.

`autocolor="yes"` (declared at the `<chart>` level) instead lets the framework auto-assign colors, with no need to manage an array by hand.

---

## 10.10 Multiple Charts Side by Side: `<table>` Layout

Use `<table columns="N">` to arrange multiple charts into a grid:

```xml
<table columns="4" align="LLLL">
  <tr>
    <td><chart title="line"      ...>...</chart></td>
    <td><chart title="bar"       ...>...</chart></td>
    <td><chart title="area"      ...>...</chart></td>
    <td><chart title="histogram" ...>...</chart></td>
  </tr>
  <tr>
    <td><chart title="digitalline"  ...>...</chart></td>
    <td><chart title="stackedbar"   ...>...</chart></td>
    <td><chart title="stackedarea"  ...>...</chart></td>
    <td><chart title="spider"       ...>...</chart></td>
  </tr>
  <tr>
    <td><chart title="pie"       ...>...</chart></td>
    <td><chart title="donut"     ...>...</chart></td>
    <td><chart title="sizedpie"  ...>...</chart></td>
    <td><chart title="sizeddonut"...>...</chart></td>
  </tr>
</table>
```

`columns="4"` tells the engine this table has 4 columns, `align="LLLL"` sets each column to left-align.

---

## 10.11 Platform Differences

| Feature | 🖥️ Win | 🌐 Web |
|---|---|---|
| All 12 chart types | ✅ | ✅ |
| Dataset-driven (`dataset=`) | ✅ | ✅ |
| Programmatically generated (`<point>`) | ✅ | ✅ |
| `RandomRange(min,max)` | ❌ | ✅ |
| Embedded in a report card (`device="prv"`) | ✅ | ❌ |
| Embedded in a Web sub card | ❌ | ✅ |
| `autocolor="yes"` | ✅ | ✅ |
| `<table columns="N">` side by side | ✅ | ✅ |

In the Windows environment, charts typically appear inside an output card with `device="prv"` (print preview); in the Web environment, they're placed inside a `device="sub"` content card, outputting HTML directly.

---

## 10.12 Common Patterns at a Glance

```xml
<!-- Line chart: driven by a database query, two series -->
<dbquery id="xy"><![CDATA[SELECT TOP 12 no, a, b FROM zp]]></dbquery>
<chart title="Trend" rangeto="11" dataset="xy" legend="yes">
  <serie type="line" linecolor="#f37735" linewidth="2"
         fieldnamevalue="a" fieldnamexaxis="no"/>
  <serie type="line" linecolor="#00aedb" linewidth="2"
         fieldnamevalue="b" fieldnamexaxis="no" marker="yes"/>
</chart>

<!-- Bar chart: generated by code, two series side by side -->
<chart title="Comparison" rangeto="11">
  <serie type="bar" color="#f37735" valuewidth="60">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(100,300)"/>
    </while>
  </serie>
  <serie type="bar" color="#00aedb" valuewidth="60">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(100,300)"/>
    </while>
  </serie>
</chart>

<!-- Pie chart: manual color array -->
<setvar name="C" value="[0..4]"/>
<setvar name="C[0]" value="#00aedb"/>
<setvar name="C[1]" value="#a200ff"/>
<setvar name="C[2]" value="#f47835"/>
<setvar name="C[3]" value="#d41243"/>
<setvar name="C[4]" value="#8ec127"/>
<chart title="Share" xaxisposition="none" yaxisposition="none">
  <serie type="pie" pielegend="yes" pieposition="custom"
         pieleft="120" pietop="100" piesize="90"
         pieshowvalues="yes" pievalueposition="outside">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;5">
      <point label="$('Item'+STR(I))"
             value="RandomRange(100,300)"
             color="C[I mod 5]"/>
      <setvar name="I" value="I+1"/>
    </while>
  </serie>
</chart>

<!-- Donut chart: automatic colors -->
<chart title="Distribution" autocolor="yes" xaxisposition="none" yaxisposition="none">
  <serie type="donut" pielegend="yes" pieposition="custom"
         pieleft="120" pietop="100" piesize="90"
         pieshowvalues="yes" pievalueposition="outside">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=5">
      <setvar name="I" value="I+1"/>
      <point label="$('A'+STR(I))" value="RandomRange(100,300)"/>
    </while>
  </serie>
</chart>
```

---

## Chapter 11　Web File Uploads in Practice: `<upload>` and `<multiupload>`

— Two upload requests of completely different shapes, each with its own receiving logic

🌐 **Web only**

A browser sending a file to a server can use two completely different shapes of HTTP request. WapForm for Web has one tag for each, and they are not interchangeable:

| | `<multiupload>` | `<upload>` |
|---|---|---|
| Request format | `multipart/form-data` (sent by a `<form>`) | Raw PUT (the whole body is the file itself) |
| Files per request | Several | One |
| Where the file name comes from | The request carries the original file name | The request has no file name; the server decides it |
| Typical scenario | A user clicks "Choose file" on a web page | A program (Windows client, curl) sends the file bytes directly as the body, compatible with a traditional `upload.php` |

Both have a built-in extension whitelist, always block `.wml` (so that if the upload directory sits under the web root it cannot be executed by the engine as a template), and verify the magic bytes of the file header for "known formats", so a disguised file that merely had its extension changed cannot get through.

---

### 11.1 `<multiupload>`: Multi-File Multipart Upload

`<multiupload>` handles the request sent by a browser `<form enctype="multipart/form-data">`. It is a **container element**: every time a file has been saved, its child nodes run once, so the page can show a thumbnail per file, write a database record, and so on.

#### Attributes

| Attribute | Req./Opt. | Description |
|---|---|---|
| `filefield` | (req.) | The field name of the corresponding `<input type="file" name="...">` |
| `destination` | (req.) | Storage directory, ending with a path separator |
| `filename` | (req.) | The variable that receives the saved file name (updated per file inside the loop) |
| `srcname` | (opt.) | The variable that receives the original file name on the user's side |
| `index` | (opt.) | The variable that receives the number of the current file (starting at 1) |
| `count` | (opt.) | The variable that receives, after the upload, the total number of files saved |
| `result` | (opt.) | The variable that receives the error message; an empty string when everything succeeded |
| `accept` | (opt.) | Whitelist of allowed extensions, comma-separated; empty means no restriction |
| `nameconflict` | (opt.) | Name-clash strategy; `unique` adds a timestamp and sequence number automatically to avoid overwriting |

Inside the child nodes you can refer directly to the variables named by `filename`/`srcname`/`index` and render file by file.

#### Complete example: `multiupload.wml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<wml>

  <card id="upload" title="File Upload">

    <div class="narrow">

    <div class="wf-head">
      <div class="wf-badge">WapForm for Web · Example</div>
      <div class="wf-title">File Upload</div>
      <div class="wf-sub">Select several files at once; the server renames duplicates automatically and reports the result.</div>
    </div>

    <div class="res">

      <multiupload filefield="myfile"
              destination="C:\Wapform\wap\upload\"
              filename="fn"
              srcname="src"
              index="no"
              count="n"
              result="err"
              accept="jpg,jpeg,png,gif,pdf,txt,csv,xlsx,docx,pptx,xls,doc,ppt,zip"
              nameconflict="unique">

        <setvar name="isimg" value="0"/>
        <if cnd="(LOWER(ExtractFileExt(fn))='.jpg') or (LOWER(ExtractFileExt(fn))='.jpeg') or (LOWER(ExtractFileExt(fn))='.png') or (LOWER(ExtractFileExt(fn))='.gif')">
          <setvar name="isimg" value="1"/>
        </if>

        <div class="file">
          <if cnd="isimg=1">
            <img class="file-thumb" src="upload/$(fn)" alt="$(src)"/>
          <else/>
            <div class="file-ic">✓</div>
          </if>
          <div class="file-body">
            <div class="file-name">$(src)</div>
            <div class="file-meta">$(fn)</div>
          </div>
          <div class="file-no">#$(no)</div>
        </div>

        <!--
          To write each file into the database, uncomment the line below and change it to your own dataset.

        <dbquery id="q" sql="insert into upfile (fname, oname, utime) values ('$(fn)', '$(src)', now())"/>
        -->

      </multiupload>

      <if cnd="n > 0">
        <div class="res-bar">
          <span>✓</span>
          <span>Uploaded <b>$(n)</b> file(s)<if cnd="memo &lt;> ''">, note: $(memo)</if></span>
        </div>
      </if>

      <if cnd="err &lt;> ''">
        <div class="alert">
          <span>!</span>
          <span>$(err)</span>
        </div>
      </if>

    </div>

    <div class="card">

      <div class="card-title">Choose the files to upload</div>
      <div class="card-note">Multiple selection is supported. Files with the same name automatically get a timestamp and sequence number and never overwrite each other. Accepts jpg / png / gif / pdf / txt / csv / xlsx / docx / zip.</div>

      <form action="multiupload.wml" method="post" enctype="multipart/form-data">

        <input type="hidden" name="card" value="upload"/>

        <div class="drop">
          <div class="drop-ic">⬆</div>
          <div class="drop-main">Click here to choose files</div>
          <div class="drop-hint">Hold Ctrl or Shift to select several at once</div>
          <operator><![CDATA[<input type="file" name="myfile" multiple="multiple"/>]]></operator>
        </div>

        <operator><![CDATA[<div class="picked" id="picked"></div>]]></operator>

        <div class="field" style="margin-top:1.25rem;">
          <span class="field-label">Note (optional)</span>
          <input type="text" name="memo" size="40"/>
        </div>

        <div class="actions">
          <input type="submit" value="Start upload"/>
          <span class="actions-note">After uploading, the saved name of each file is listed</span>
        </div>

      </form>

    </div>

    <div class="foot">
      The layout comes from <code>wapform.htm</code>; the flow and data are defined by <code>multiupload.wml</code>.<br/>
      Designers change the layout without touching the wml; engineers change the logic without touching the htm.
    </div>

    </div>

  </card>

</wml>
```

#### Engine rules you are likely to run into

| # | Rule |
|---|---|
| 1 | `<form>` / `<div>` are not engine tags; they are output as is, attributes (including `class`) preserved. |
| 2 | The file field cannot use `<input>`, because the engine's `_input` does not output `multiple`; use `<operator>` to write the raw HTML directly (its content is still `$()`-expanded). |
| 3 | `_input` does not output `class`, so wrap it in a `<div class="field">` and style it with a descendant selector (`.field input`). |
| 4 | The child nodes of `<multiupload>` run once for every file saved. |
| 5 | `cnd=` and `value=` take expressions; wrap string literals in single quotes yourself. |
| 6 | Only fields sent in this request exist in the variable table; `memo` in the example does not exist on the first `GET`, so refer to it only in a block where a `POST` has certainly happened. The five variables named by `filename`/`srcname`/`index`/`count`/`result` are created by `<multiupload>` itself and can be referred to at any time. |
| 7 | An element without child nodes is output as `<div/>`, which in HTML is an unclosed start tag that swallows the content after it; for empty containers (filled in by front-end JS), always write the raw HTML directly with `<operator>`. |
| 8 | If `destination` lies under the web root (as `C:\Wapform\wap\` does in the example), uploaded files can be reached directly by URL without a separate download wml; `.wml` is always blocked by the engine, and other types are narrowed by the `accept` whitelist. To isolate access completely, point `destination` outside the web root and write a separate download wml that controls access. |
| 9 | Image preview: use the built-in expression functions `ExtractFileExt`/`LOWER` to check whether the extension is an image type, and if so show it directly with `<img src="upload/$(fn)">`. |

---

### 11.2 `<upload>`: Raw PUT Single-File Upload

`<upload>` receives a request of a completely different shape: the entire request body is the file's bytes, with no multipart wrapper, no field name and no file name. The tag was designed to be compatible with the way a traditional `upload.php` receives files (`fopen('php://input')` reads the body and writes it out as a file unchanged). It is an **empty element**.

#### Attributes

| Attribute | Req./Opt. | Description |
|---|---|---|
| `destination` | (req.) | Storage directory |
| `filename` | (opt.) | Fixed file name; when empty it is determined by the `Content-Disposition` header or a timestamp (see below) |
| `accept` | (opt.) | Whitelist of allowed extensions, comma-separated; empty means no restriction |
| `unique` | (opt.) | With `yes`, if a file of the same name already exists in the directory, `_01`, `_02`, … is added automatically to avoid overwriting (same as `nameconflict="unique"`; both forms are recognized) |
| `result` | (opt.) | The variable that receives the error message / status; receives `'empty body'` when there is no body |
| `size` | (opt.) | The variable that receives the number of bytes received |
| `savedname` | (opt.) | The variable that receives the file name actually saved (since only the tag itself knows a dynamic file name, the page needs it to show a preview) |

#### How the file name is decided

A raw PUT request carries no file name, so `<upload>` decides the saved name in this order:

1. **`filename` is set** → that name is always used (consistent with `upload.php`: uploading again overwrites the same file; together with `unique="yes"`, a sequence number is added only on a clash).
2. **No `filename`, but the request carries `Content-Disposition: attachment; filename="..."`** → that file name is used as is (`httpupload` of `<webcopy>` adds this header automatically, see Chapter 12).
3. **Neither** → a file name is generated from a timestamp (`yymmddhhnnsszzz`), with the extension inferred from the request's `Content-Type` (see the table below); unrecognized types always become `.jpg`.

`filename` can also take external input, for example `filename="$(name)"` together with `?name=...` in the URL; the tag strips the path, blocks `..` and drive letters, and then checks the extension whitelist, preventing path-traversal attacks.

`unique="yes"` deals with name clashes: when a file of the same name already exists in the directory, `_01`, `_02`, … is appended until the name is unique, so nothing is overwritten; it is independent of how the file name is decided.

#### Content-Type → extension inference

| Content-Type | Extension |
|---|---|
| `image/jpeg` | `.jpg` |
| `image/png` | `.png` |
| `image/gif` | `.gif` |
| `image/bmp` | `.bmp` |
| `application/pdf` | `.pdf` |
| `application/zip` | `.zip` |
| `text/plain` | `.txt` |
| `text/csv` | `.csv` |
| `application/msword` | `.doc` |
| `application/vnd.ms-excel` | `.xls` |
| `application/vnd.ms-powerpoint` | `.ppt` |
| `...officedocument.wordprocessingml.document` | `.docx` |
| `...officedocument.spreadsheetml.sheet` | `.xlsx` |
| `...officedocument.presentationml.presentation` | `.pptx` |
| Other | `.jpg` (default) |

The `Content-Type` sent must match the actual file type — for example, sending a PDF but declaring `image/jpeg` gets it inferred as `.jpg`; the header check then finds the content is really a PDF that does not match `.jpg`, and the file is rejected. If you do not want to rely on inference, specifying the extension with the `filename` attribute is the most reliable.

#### ★ The easiest trap: always specify the correct Content-Type

When the sending side calls `<upload>`, it **must specify a `Content-Type`, and it must not be `application/x-www-form-urlencoded`** (the default of many HTTP libraries, including curl's `--data-binary` and ICS's `THttpCli`).

The symptom is subtle: the server "receives something" and the length is exactly right, but the first bytes of the file have been quietly changed and the saved image will not open. The reason is that the server-side HTTP component sees `application/x-www-form-urlencoded`, decides the body is form text, and processes it once as a string before handing it to any logic; along the way a Windows best-fit character conversion happens: the bytes are taken as Latin-1 characters and converted to the ANSI code page, and bytes with no mapping are replaced by the "most similar" ASCII letter (for example `FF` → `y`, `D8` → `O`, `E0` → `a`). The JPEG header `FF D8 FF E0` is turned into other bytes this way, while bytes `< 0x80` are unaffected, so it looks as if "only the first few bytes are broken". This happens before the server reads the body, so the `<upload>` tag cannot repair it; only the sending side can avoid it by specifying a correct `Content-Type` from the start (`image/jpeg`, `image/png`, `application/octet-stream`, etc. are all fine).

#### Complete example: `upload.wml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<wml>

  <card id="upload" title="Raw PUT Single-File Upload">

    <div class="narrow">
      <div class="wf-head">
        <div class="wf-badge">WapForm for Web · Example</div>
        <div class="wf-title">Raw PUT Single-File Upload</div>
        <div class="wf-sub">The whole request body is one file, without a multipart wrapper, compatible with the way upload.php receives files.</div>
      </div>
    </div>

    <div class="narrow">

      <upload destination="C:\Wapform\wap\upload\"
                 accept="jpg,jpeg,png,gif,bmp,pdf,txt,csv,xlsx,docx,pptx,xls,doc,ppt,zip"
                 result="up_err"
                 size="up_size"
                 savedname="up_name"/>

      <if cnd="up_size &gt; 0">
        <div class="res-bar">
          <span>✓</span>
          <span>Saved <b>$(up_name)</b>, $(up_size) bytes.</span>
        </div>
        <div class="card">
          <div class="card-title">Result</div>
          <img class="up-preview" src="upload/$(up_name)" alt="$(up_name)"/>
        </div>
      </if>

      <if cnd="up_err &lt;> ''">
        <div class="alert">
          <span>!</span>
          <span>Nothing was saved this time: $(up_err)</span>
        </div>
      </if>

      <div class="card">
        <div class="card-title">How to test</div>
        <div class="card-note">
          This is not a form page and has no file button — a raw PUT cannot be sent by an ordinary browser form;
          a program (or curl) sends the file content directly as the request body.
        </div>

        <div class="alert">
          <span>!</span>
          <span>
            When sending, <b>always specify the Content-Type</b> (for example <code>image/jpeg</code>);
            do not use the default <code>application/x-www-form-urlencoded</code>.
          </span>
        </div>

        <div class="card-note">
          <b>With the Windows client (UploadFile in Unit2.pas):</b>
        </div>
        <div class="code-block">
          HttpCli.URL := 'http://localhost:8080/wap/upload.wml';<br/>
          HttpCli.ContentTypePost := 'image/jpeg';<br/>
          HttpCli.SendStream := Stream;<br/>
          HttpCli.RequestVer := '1.1';<br/>
          HttpCli.Put;
        </div>

        <div class="card-note">
          <b>With curl:</b>
        </div>
        <div class="code-block">
          curl -X PUT --data-binary "@C:\Wapform\a02.jpg" -H "Content-Type: image/jpeg" http://localhost:8080/wap/upload.wml<br/>
          <br/>
          For a PDF, use the matching type instead of image/jpeg:<br/>
          curl -X PUT --data-binary "@C:\Wapform\aaa.pdf" -H "Content-Type: application/pdf" http://localhost:8080/wap/upload.wml<br/>
          <br/>
          To specify the saved file name, add a Content-Disposition header:<br/>
          curl -X PUT --data-binary "@C:\Wapform\a02.jpg" -H "Content-Type: image/jpeg" -H "Content-Disposition: attachment; filename=\"a02.jpg\"" http://localhost:8080/wap/upload.wml
        </div>
      </div>

    </div>

    <div class="narrow">
      <div class="foot">
        The layout comes from <code>wapform.htm</code>; the receiving logic comes from the <code>&lt;upload&gt;</code> tag.<br/>
        <code>multiupload.wml</code> is a different upload shape — that page uses a browser form with
        multipart, this page uses a raw PUT; the two tags are not interchangeable.
      </div>
    </div>

  </card>

</wml>
```

Opening this page directly in a browser (`GET`) does not cause an error; with no body, `result` simply receives `'empty body'` and the page shows the instructions block.

---

### 11.3 Security Summary

Both `<upload>` and `<multiupload>` have three built-in layers of protection:

| Layer | Mechanism |
|---|---|
| Extension whitelist | The `accept` attribute lists the allowed extensions, comma-separated; empty means no restriction |
| Templates always blocked | `.wml` is not controlled by `accept` and is always rejected — if the upload directory lies under the web root, a `.wml` would be "executed" by the engine, so whoever can upload could run any template |
| Header magic-byte check | The real content of "known formats" is verified again: `jpg/jpeg`, `png`, `gif`, `bmp`, `pdf`, `zip` (`docx`/`xlsx`/`pptx` are zip files, all with the header `PK`), `doc/xls/ppt` (Office 97-2003 OLE2 compound documents, all with the header `D0 CF 11 E0`). Formats without a fixed header (`txt`, `csv`, etc.) are not checked and pass directly |

This blocks "something else sent up with a changed extension" — for example, a PDF renamed to `.jpg` is rejected.

---

### 11.4 Chapter Summary

| Scenario | Which tag |
|---|---|
| A "Choose file" form on a web page, possibly with multiple selection | `<multiupload>` (`multipart/form-data`) |
| A program or curl PUTs the file bytes directly as the body, compatible with `upload.php` | `<upload>` (raw PUT) |
| The Windows side sends a local file to one of these two receiving pages | See `<webcopy protocol="httpupload">` in Chapter 12 — the shape of the request it sends matches `<upload>`, and it adds `Content-Disposition` and the correct `Content-Type` automatically |

---

## Chapter 12　Windows File Transfer in Practice: `<open>` and `<webcopy>`

— Choosing, moving, uploading and downloading local files

🖥️ **Windows only**

The Windows side has no browser `<form>`; local files get in and out of the system through two tags working together: `<open>` pops up the system file-selection dialog, and `<webcopy>` moves files between the file system, HTTP and FTP according to its `protocol` attribute. They often appear as a pair: the user chooses a file → it is uploaded or moved to its destination.

---

### 12.1 `<open/>`: The System File-Selection Dialog

Empty element; pops up the operating system's native "Open" dialog so the user can pick a local file.

| Attribute | Req./Opt. | Description |
|---|---|---|
| `filename` | (req.) | The variable that receives the full path the user picked |
| `result` | (req.) | The variable that receives whether the user confirmed; `1` means confirmed, anything else cancelled |

```xml
<setvar name="I" value="0"/>
<setvar name="F" value="''"/>
<open filename="F" result="I"/>
<if cnd="I=1">
  <!-- the user picked a file; F is the full path -->
</if>
```

Always check `result` (`I=1` in the example) before using the content of the `filename` variable; otherwise, when the user cancels, the variable may still hold a value left over from before.

---

### 12.2 `<webcopy/>`: File Transfer over Five Protocols

Empty element whose behavior is decided by the `protocol` attribute; it moves files between the "local file system", "HTTP" and "FTP", and is the only built-in file transfer mechanism on the Windows side (the Web side has no matching tag; it receives files on the server with `<upload>` / `<multiupload>` from Chapter 11).

#### Attribute overview

| Attribute | Req./Opt. | Description |
|---|---|---|
| `protocol` | (opt., default `file`) | One of `file`/`httpupload`/`httpdownload`/`ftpupload`/`ftpdownload` |
| `host` | Depends on protocol | Meaning changes with `protocol`, see the table below |
| `url` | Depends on protocol | Meaning changes with `protocol`, see the table below |
| `dir` | Depends on protocol | Meaning changes with `protocol`, see the table below |
| `username` / `password` | Required for FTP | FTP login account and password |
| `unique` | (opt.) | Its presence means `true`: the file name is generated from a timestamp (`yyyymmddhhnnsszzz`); if it still clashes in the `dir` directory, `_01`, `_02`, … is added until it is unique (at most 999 attempts) |
| `result` | (opt.) | On success receives the file name actually saved / uploaded; on failure the error message |
| `errmsg` | (opt.) | On failure receives the error message; cleared to an empty string on success |
| `response` | (opt., `httpupload` only) | Receives the raw content of the server response (HTTP response body) |

#### `host` / `url` / `dir` for the five protocols

| `protocol` | `host` | `url` | `dir` |
|---|---|---|---|
| `file` | Target directory (ending with `\`) | Full source path | — |
| `httpupload` | Target URL | Local file path | — |
| `httpdownload` | Source URL | — | Storage directory |
| `ftpupload` | FTP host | Local file path | Directory on FTP |
| `ftpdownload` | FTP host | File name on FTP | Local storage directory |

Behavior of each protocol:

- **`file`**: copies within the local file system. If the source (`url`) does not exist, an error is returned; if a file of the same name already exists at the destination (`host` + file name), it is **not overwritten** — the copy is skipped and "file already exists" is reported.
- **`httpupload`**: uploads the local file (`url`) to `host` with HTTP `PUT`. It sets the correct `Content-Type` from the extension automatically (covering `.jpg/.png/.gif/.bmp/.pdf/.zip/.txt/.csv/.doc/.xls/.ppt/.docx/.xlsx/.pptx`; all other types are sent as `application/octet-stream`), adds a `Content-Disposition: attachment; filename="..."` header automatically, and appends `?name=` or `&name=` to the URL — which is exactly why the receiving side gets the original file name when paired with the `<upload>` tag of Chapter 11. An HTTP status other than `200` counts as a failure.
- **`httpdownload`**: downloads from `host` into the `dir` directory with HTTP `GET`. If no file name is given or can be inferred, it falls back to the file name in the source URL, then to a timestamp. An HTTP status other than `200` counts as a failure.
- **`ftpupload`** / **`ftpdownload`**: transfer over FTP; `username`/`password` are the required login details.

#### Complete example: `webcopy.wml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<wml>

  <card id="webcopy" title="File Transfer Test" width="960">

    <setvar name="wc_result" value="''"/>
    <setvar name="wc_err" value="''"/>

    <setvar name="SRC_JPG"  value="'C:\Wapform\300x300.jpg'"/>
    <setvar name="SRC_PDF"  value="'C:\Wapform\aaa.pdf'"/>
    <setvar name="DST_DIR"  value="'C:\Wapform\temp\'"/>
    <setvar name="DST_DIR2" value="'C:\Wapform\temp'"/>
    <setvar name="UP_URL"   value="'http://localhost:8080/wap/upload.wml'"/>
    <setvar name="DL_URL"   value="'http://localhost:8080/wap/upload/a02.jpg'"/>

    <setvar name="FTP_HOST" value="''"/>
    <setvar name="FTP_USER" value="''"/>
    <setvar name="FTP_PWD"  value="''"/>
    <setvar name="FTP_DIR"  value="''"/>

    <table columns="2" align="LL">
      <tr>
        <td width="60">result: </td>
        <td width="900"><label name="R">(not run yet)</label></td>
      </tr>
      <tr>
        <td>errmsg: </td>
        <td><label name="E">(not run yet)</label></td>
      </tr>
    </table>

    <do type="accept" label="file copy">
      <webcopy protocol="file"
               host="$(DST_DIR)"
               url="$(SRC_JPG)"
               unique="yes"
               result="wc_result"
               errmsg="wc_err"/>
      <setprop name="R" prop="caption" value="wc_result"/>
      <setprop name="E" prop="caption" value="wc_err"/>
    </do>

    <do type="accept" label="httpdownload">
      <webcopy protocol="httpdownload"
               host="$(DL_URL)"
               dir="$(DST_DIR2)"
               unique="yes"
               result="wc_result"
               errmsg="wc_err"/>
      <setprop name="R" prop="caption" value="wc_result"/>
      <setprop name="E" prop="caption" value="wc_err"/>
    </do>

    <do type="accept" label="httpupload JPG">
      <webcopy protocol="httpupload"
               host="$(UP_URL)"
               url="$(SRC_JPG)"
               result="wc_result"
               errmsg="wc_err"/>
      <setprop name="R" prop="caption" value="wc_result"/>
      <setprop name="E" prop="caption" value="wc_err"/>
    </do>

    <do type="accept" label="httpupload PDF">
      <webcopy protocol="httpupload"
               host="$(UP_URL)"
               url="$(SRC_PDF)"
               result="wc_result"
               errmsg="wc_err"/>
      <setprop name="R" prop="caption" value="wc_result"/>
      <setprop name="E" prop="caption" value="wc_err"/>
    </do>

    <do type="accept" label="ftpupload">
      <webcopy protocol="ftpupload"
               host="$(FTP_HOST)"
               username="$(FTP_USER)"
               password="$(FTP_PWD)"
               url="$(SRC_JPG)"
               dir="$(FTP_DIR)"
               result="wc_result"
               errmsg="wc_err"/>
      <setprop name="R" prop="caption" value="wc_result"/>
      <setprop name="E" prop="caption" value="wc_err"/>
    </do>

    <do type="accept" label="ftpdownload">
      <webcopy protocol="ftpdownload"
               host="$(FTP_HOST)"
               username="$(FTP_USER)"
               password="$(FTP_PWD)"
               url="a02.jpg"
               dir="$(DST_DIR2)"
               result="wc_result"
               errmsg="wc_err"/>
      <setprop name="R" prop="caption" value="wc_result"/>
      <setprop name="E" prop="caption" value="wc_err"/>
    </do>

    <do type="prev" label="Close">
      <prev/>
    </do>

  </card>

</wml>
```

This page turns each protocol into a button; press one and the result appears immediately in the `result` / `errmsg` labels — a good protocol verification page when starting a new project. The meaning of the three attributes `host`/`url`/`dir` differs for every protocol, and one round of real tests is more reliable than memorizing the table.

---

### 12.3 Putting It Together: `<open>` + `<webcopy httpupload>` Image Upload and Preview

`app002.wml` (product master) shows the most common image management combination on the Windows side: the user clicks "Open" to choose an image → `<webcopy protocol="httpupload">` uploads it immediately to `upload.wml` on the Web side → after a successful upload, the returned file name is used to build the image URL and the preview on screen is refreshed at once.

```xml
<function id="A0">
  <setvar name="I" value="0"/>
  <setvar name="F" value="''"/>
  <setvar name="R" value="''"/>
  <setvar name="E" value="''"/>
  <open filename="F" result="I"/>
  <if cnd="I=1">
    <log message="filename: $F"/>
      <webcopy protocol="httpupload"
               host="http://localhost:8080/wap/upload.wml"
               url="$F"
               result="R"
               errmsg="E"/>
    <if cnd="Pos('failed', R)=0">
      <log message="$(R)"/>
      <setvar name="paicon" value="R"/>
      <setprop name="g0" prop="img" value="'$('http://localhost:8080/wap/upload/'+paicon)'"/>
    <else>
      <log message="Upload failed: $R"/>
      <setvar name="paicon" value="''"/>
    </else>
    </if>
  </if>
</function>

<function id="B0">
  <setvar name="paicon" value="'300x300.jpg'"/>
  <setprop name="g0" prop="img" value="'$('http://localhost:8080/wap/upload/'+paicon)'"/>
</function>
```

The trigger on screen and its pairing with the `afterscroll` event:

```xml
<td>Icon: <a href="@A0">Open</a>|<a href="@B0">Clear</a><br/><br/>
    <img id="g0" width="300" height="300" src="$('http://localhost:8080/wap/upload/'+paicon)"/>
</td>
```

```xml
<onevent type="afterscroll">
  <log message="$(paicon)"/>
  <setprop name="g0" prop="img" value="'$('http://localhost:8080/wap/upload/'+paicon)'"/>
</onevent>
```

**Step by step:**

| Step | Description |
|---|---|
| 1. `<open filename="F" result="I"/>` | Pops up the file-selection dialog; `I=1` means the user confirmed, `F` is the full local path |
| 2. `<webcopy protocol="httpupload" ...>` | Uploads the local file `F` points to with `httpupload` to `upload.wml` on the Web side (the page with the `<upload>` tag of Chapter 11); on success `R` receives the saved file name, on failure an error message containing `failed` |
| 3. `Pos('failed', R)=0` | Checks by string search whether the upload succeeded — the `SetErr` family of error messages all start with the protocol name and contain `failed`, making this the usual way to check `<webcopy>` |
| 4. Success: `paicon` keeps the file name, `<setprop img>` resets the image URL | If the Web-side upload directory is under the web root (see Section 11.1 of Chapter 11), the saved file can be reached by URL directly, without a separate download wml |
| 5. `B0` / Clear | Sets `paicon` back to a fixed default image file name, "restoring the default image" |
| 6. `afterscroll` | When moving to another record (`navigator` / scrolling the record cursor), the URL for `paicon` is applied again, so the image follows the record |

> This combination is exactly where Chapters 11 and 12 meet: the request sent by `<webcopy protocol="httpupload">` (`Content-Type` set automatically from the extension, `Content-Disposition` carrying the original file name, `?name=` appended to the URL) matches exactly the format the `<upload>` tag of Chapter 11 expects, with no conversion needed on either side.

**📱 Flutter**

`<open>` and `<webcopy>` have no corresponding tags in WapForm for Flutter. When the same `.wml` must also upload images in Flutter, use `<platform>` to separate the Windows code from the Flutter Dart code; the complete example (`app002.wml`) is in Section 4.5, `<platform>`.

---

### 12.4 Chapter Summary

| Technique | Use |
|---|---|
| `<open filename result/>` | Pops up the system file-selection dialog and gets a local file path |
| `<webcopy protocol="file">` | Copies within the local file system; does not overwrite an existing file of the same name at the destination |
| `<webcopy protocol="httpupload">` | Uploads a local file with HTTP PUT, adding `Content-Type` and `Content-Disposition` automatically; connects directly to the `<upload>` tag of Chapter 11 |
| `<webcopy protocol="httpdownload">` | Downloads a file into a local directory with HTTP GET |
| `<webcopy protocol="ftpupload">` / `protocol="ftpdownload">` | Upload / download over FTP |
| `unique="yes"` | Name-clash protection shared by all five protocols: adds a timestamp and sequence number, never overwrites an existing file |
| `result` / `errmsg` | The usual pair: the file name on success, the error message on failure |
| `Pos('failed', R)=0` | The usual way to check whether `<webcopy>` succeeded |

---

## Chapter 13　Crosstab Case Study

— A Sales Analysis Case Study

🌐 **Web version**

---

## 13.1 The Nature of WapForm Crosstabs

WapForm's crosstab lets developers describe pivot analysis in purely declarative XML — row groups, column groups, cross-cell aggregation, subtotal rows, grand-total rows — all done through combinations of `<crosstab>`, `<row change>`, `<col change>`, and `<setvar>`.

Under the hood, `<crosstab>` shares the same row/column-grouping mechanism as `<report>` (see Section 4.7 of Chapter 4), but adds one more dimension: `<report>` only has "rows" (grouping + detail), while `<crosstab>` is a two-dimensional "row × column" matrix, where each cross-cell is an aggregated value.

This chapter's output target is an **HTML `<table>` rendered by the browser** — that is, the default path when a `card` tag doesn't specify a `device=` attribute. WapForm also supports output modes such as `device="prv"` (print preview) and `device="prn"` (direct print), which follow different code branches not covered in this chapter — we haven't actually tested those paths, and where something is uncertain, we'd rather leave it out than have content that looks complete but is wrong.

This chapter uses the sales-analysis "Sales Crosstab" (`crosstab.wml`) as an example: two-level year and year-month groups on the horizontal axis, two-level salesperson and customer groups on the vertical axis, sales amount in the cross-cells, with subtotals and grand totals for each row and column generated automatically. This example currently runs live on WapForm for Web's online example site (the "Crosstab Analysis" card on the `example.wml` homepage) — it's not a paper exercise.

> **On this chapter's reliability**: the crosstab is the most logically complex, and most error-prone, feature in the whole WapForm engine. Every piece of code and every variable's role in this document is the result of actual deployment, actual crashes, actual fixes, and actual screenshot verification — not something inferred from reading the source code. We've given extra space to the pitfalls we hit along the way (especially the variable choice in Section 13.8), because that's exactly where it's easiest to repeat the same mistake.

---

## 13.2 System Overview

```
Sales Crosstab (crosstab.wml)

Execution flow:
  card crosstab — Main report (rendered by the browser, no device= attribute)
    ↓
  dbquery xy — Queries sales detail from sh (sales order header) + cu (customer); the SQL side does a group by aggregation first
    ↓
  <crosstab> — The crosstab engine

Data structure:
  Row axis (Row, using two nested levels of <row change>):
    eno   — Salesperson code (level 1 group)
    cno   — Customer code (level 2 group)
  Column axis (Column, using two nested levels of <col change>):
    yy    — Year (level 1 group)
    ym    — Year + month (level 2 group, e.g. 202006)
  Value field:
    amount — Sales amount, already summed via group by on the SQL side; the cross-cell only needs filling once

Control variables:
  I, J, K     — Loop and column counters
  N           — The current cell's value (after VAL conversion)
  T           — Reserved field, currently unused
  C, R        — The current column header value, the current row group's name
  A, B        — Row subtotal (year subtotal), the whole row's horizontal total
  X[1..999]   — Column-total array for the current salesperson's group
  Y[1..999]   — Column grand-total array across all salespeople
```

---

## 13.3 Data Query: From Detail Rows to a Pivot

The crosstab's dataset needs to supply the **row-axis fields**, the **column-axis fields**, and the **value field** all at once. This example additionally does one thing — **it uses `group by` to sum the amounts on the SQL side first**, rather than throwing detail rows at the engine one by one and expecting `<crosstab>`'s own accumulation logic to handle the duplicates:

```sql
select
  year(s.sdate)                          yy,
  date_format(s.sdate, '%Y%m')           ym,
  s.Eno                                  eno,
  s.Cno                                  cno,
  sum(coalesce(s.Amount, 0))             amount
from sh s
left join cu c on c.Cno = s.Cno
where s.sdate >= '2020-06-01' and s.sdate < '2021-04-01'
group by
  date_format(s.sdate, '%Y%m'),
  s.Eno,
  s.Cno
order by yy, ym, eno, cno
```

**Why group by on the SQL side first**: after SQL summing, every `(year-month, salesperson, customer)` combination returns exactly one row, so the crosstab's internal accumulation logic (the `Cell()` function) only needs to handle the case of "this cell being written for the first time" — it doesn't need to rely on correctly accumulating a cell that's written to multiple times. The behavior is more predictable, and it's also faster.

**`order by` is not optional**: `<row change="...">` / `<col change="...">` determine grouping boundaries by comparing against the previous row to see if the value changed. If the data isn't sorted by the grouping key, the same group gets split into several segments, with headers printed repeatedly. The `order by` sequence here (`yy, ym, eno, cno`) is deliberately made to match the nesting order of the grouping levels — the outer column key first, the inner column key after; the outer row key first, the inner row key after.

**The date range deliberately spans two years**: `2020-06-01` to `2021-04-01` spans both 2020 and 2021, used to verify that the two-level `yy` (outer column, year) → `ym` (inner column, year-month) column grouping also works correctly across a year boundary. With only a single year, the outer `yy` grouping would always have just one value, and there'd be no way to test whether the cross-year grouping boundary is correct.

---

## 13.4 The `crosstab` Root-Element Attributes

```xml
<crosstab dataset="xy" dialog="cno;sdate" field="amount" autospan="yes">
```

| Attribute | Value | Actual Status |
|---|---|---|
| `dataset` | `xy` | **Has an effect**, specifies the data source (the `<dbquery>`'s id) |
| `field` | `amount` | **Has an effect**, the cross-cell's value field name |
| `dialog` | `cno;sdate` | **Only parsed, not used, in the current version of the engine** — writing it produces no dialog at all |
| `autospan` | `yes` | **Has an effect**, merges adjacent header cells with identical content (`colspan`/`rowspan`) |

The name of the `dialog=` attribute sounds as if it shows a "filter dialog before running", but tracing the source of `_report`/`_crosstab` shows that `Dlg` is a local variable that, once read, is never read again anywhere — effectively dead code: writing it pops up no dialog, and filtering still has to be written into the SQL `where` condition yourself.

**`autospan=` genuinely does have an effect**, though it isn't in `_crosstab`'s own code — it's a field on `TCard`. `_crosstab` is only responsible for setting it based on the attribute value; the code that actually reads and applies it is `_td`, which renders the cells. It works as a standard two-phase "measure then merge":

1. **Measurement phase** (`Printable=0`): compares each cell's content against its neighbor to see if it's the same; if so, accumulates "how many consecutive cells are the same" into an internal array.
2. **Rendering phase** (`Printable=1`): reads back this accumulated count; if it's greater than 1, outputs `colspan="N"` or `rowspan="N"` on the `<th>`/`<td>`, merging those cells into one.

This mechanism **only takes effect in the header area** (the salesperson/customer/year/year-month columns or rows, determined by the same `Row.Count`/`Col.Count` threshold mentioned in Section 13.8), and doesn't affect the data cells. The practical effect is: when a salesperson has several customers underneath them, the salesperson code is only shown once in the merged cell, vertically centered, rather than being repeated on every row — this is the browser's default rendering behavior for `rowspan` cells, not extra styling.

---

## 13.5 Initializing State Variables

The `<setvar>` elements under the `<crosstab>` root declare the state variables shared throughout the whole report cycle:

```xml
<setvar name="I" value="0"/>    <!-- General-purpose loop counter -->
<setvar name="J" value="0"/>    <!-- Reserved, currently unused -->
<setvar name="K" value="0"/>    <!-- Current column-cell count (including the subtotal column), used to align subtotal/total rows -->
<setvar name="N" value="0"/>    <!-- The current cell's value (after VAL conversion) -->
<setvar name="T" value="0"/>    <!-- Reserved, currently unused -->
<setvar name="C" value="''"/>   <!-- The current column group's header (the year value) -->
<setvar name="R" value="''"/>   <!-- The current row group's header (the salesperson code) -->
<setvar name="A" value="0"/>    <!-- The subtotal for this row, this year -->
<setvar name="B" value="0"/>    <!-- The full-period total for this row (a single customer) -->
<setvar name="X" value="[1..999]"/>  <!-- The current salesperson's column-total array -->
<setvar name="Y" value="[1..999]"/>  <!-- The column grand-total array across all salespeople -->
```

`X` and `Y` are declared as `[1..999]` arrays, meaning up to 999 columns can be handled (including the TOTAL/AMOUNT subtotal columns), which in practice is far more than enough. `I` and `K` are integers used as indices, `C` and `R` are strings, and `A`, `B`, `N` are numbers — these types are determined by **the value given in the first `<setvar>`**; after that, the same variable can only hold something of the same type, and if a value of a different type is assigned, the framework will attempt to force-convert it, and if that conversion fails, the server will throw an exception (see the debugging story in Section 13.8 for details).

---

## 13.6 The Table Container and Pagination Settings

```xml
<page>
  <table class="xtab-table" rows="20" cols="15">
```

`rows=`/`cols=` **genuinely do have an effect** — these two attributes drive the framework's internal `Wap.LinesPerPage`/`CrossRow`/`CrossCol`, and when the data's row or column count exceeds this number, a page break (`NewPage()`) is triggered automatically.

> **Known issue: page breaks in a browser-viewing context produce invalid HTML.**
>
> When `NewPage()` breaks the page, it does two things: it first prints a `<p class="newpage"></p>`, then **reopens a `<table>` tag without first closing the previous one**. When the browser receives HTML this invalid — "a table opened again inside a table" — it tries to fix it itself, and the fix usually results in the header ending up randomly in the middle of the data, with the two table segments visually stuck together, rather than a clean page break.
>
> This is a behavior of the engine itself, not something CSS alone can fully solve. The web version usually already has horizontal/vertical scrolling available, so automatic pagination isn't necessarily needed; if you don't need the page-break effect, the simplest approach is to **not write the `rows=`/`cols=` attributes at all** (or give them a number large enough that it never triggers), and the whole crosstab will render as one continuous, clean `<table>`. These two attributes are better suited to `device="prn"`/`device="prv"` output scenarios — printers and print preview — where "pagination" is a meaningful physical concept; in a browser it usually isn't needed.

---

## 13.7 Defining the Row Axis: `<row change>`

The row axis's structure is defined by two nested levels of `<row change>`, from the outer level (salesperson) to the inner level (customer):

```xml
<row change="xy.eno">
  <setvar name="I" value="1"/>
  <while cnd="I&lt;=99">
    <setvar name="X[I]" value="0"/>    <!-- Clears the column totals every time a new salesperson group starts -->
    <setvar name="I" value="I+1"/>
  </while>

  <row change="xy.cno">
    <setvar name="K" value="0"/>       <!-- Resets this row's cell counter -->
    <setvar name="B" value="0"/>       <!-- Resets this row's horizontal total -->
    <tr>
      ...
    </tr>
  </row>
</row>
```

`<row change="xy.eno">` fires when the salesperson code changes, and its job is to reset the column-total array `X[1]`–`X[99]`, preparing to re-accumulate values for the next salesperson group. `<row change="xy.cno">` fires when the customer code changes (i.e. for every row the report outputs); `K` and `B` are zeroed here, serving as the starting point for this row's accumulation.

---

## 13.8 The Row Axis and Cell Rendering: `cellrow`/`cellcol`/`cell`, Not `row`/`col`

This is **the easiest place in the whole crosstab mechanism to get wrong — and one we actually stumbled into ourselves** — worth explaining in full.

While rendering each cell, the engine maintains **two completely different sets of position variables at the same time**:

| Variable | Starting Value | Source | Purpose |
|---|---|---|---|
| `AROW` / `ACOL` | Starts at 0 | The crosstab's internal grid index (the `ARow`/`ACol` variables) | Used internally by the engine, **not recommended for direct reference in the template** |
| `cellrow` / `cellcol` | Starts at 1 | `Wap.RowNumber` / `Wap.ColNumber`, a counter that increments naturally as `<tr>`/`<td>` render, shared with regular tables | **This is the pair the template should use** |

The two sets are independent of each other and completely unrelated — this isn't a case-sensitivity issue. `cell` (lowercase) maps to the engine's internal `CELL` (uppercase) because the framework's `SetVar`/`GetVar` both uppercase the identifier internally before looking it up — identifiers are inherently case-insensitive. But `cellrow`/`cellcol` and `AROW`/`ACOL` are two variables with entirely different names, with no such case-equivalence relationship.

If the template mistakenly uses `AROW`/`ACOL` as the basis for judging the header/data boundary, at best the on-screen headers won't line up with the data; at worst, a cross-cell's text label (say, the year header `'2020'`) gets misjudged as a data cell, gets fed into a numeric-conversion function, and directly crashes the server with an exception. This is exactly the error that actually happened when we deployed this example — two different exception types, `EConvertError` (`'Q1' is not a valid integer value`) and `EVariantInvalidArgError` (`Invalid argument`), both rooted in the same thing: using the wrong position variable.

The correct approach (the actually-deployed version, including one extra styling decision):

```xml
<col change="xy.YM">
  <log message="$cellrow $cellcol $cell"/>
  <setvar name="C" value="cell"/>
  <setvar name="R" value="cell" cnd="cellcol=1"/>
  <setvar name="N" value="0"/>
  <if cnd="(cellrow&lt;3) or (cellcol&lt;3)">
    <if cnd="(cellrow=2) and (cellcol&lt;3)">
    <td width="120" align="center"><i>$(IF(cell='',' ',cell))</i></td>
    <else/>
    <td align="center">$(IF(cell='',' ',cell))</td>
    </if>
    <else/>
    <setvar name="N" value="VAL(cell)"/>
    <td width="60" align="right">$(IF(N=0,' ',FORMAT('%d',N)))</td>
    <setvar name="A" value="A+N"/>
    <setvar name="B" value="B+N"/>
    <setvar name="K" value="K+1"/>
    <setvar name="X[K]" value="X[K]+N"/>
    <setvar name="Y[K]" value="Y[K]+N"/>
  </if>
</col>
```

**Where the threshold number "3" comes from**: `cellrow`/`cellcol` start at 1; the number of header rows equals the number of column-group levels (two levels in this example: `YY`, `YM`), and the number of header columns equals the number of row-group levels (two levels in this example: `eno`, `cno`) — both are 2 levels, so the header area occupies rows 1–2 and columns 1–2; `cellrow<3`/`cellcol<3` covers exactly this range, with data starting from row 3, column 3. If the number of grouping levels isn't two, this threshold needs to be adjusted along with it (threshold = number of levels + 1).

**A compound condition like `(cellrow<3) or (cellcol<3)` is usable**: actually tested, `Condiction()` supports combining conditions with `or`/`and` keywords, with no need to break it apart into nested `<elseif>`s.

**The nested `(cellrow=2) and (cellcol<3)` is an extra styling decision**: within the header area, there's a further subdivision — row 2 cells that also fall in the row-header column (`cellcol<3`) are rendered in `<i>` italics with a fixed width of 120px, while the rest of the header cells use the normal style. This isn't necessary logic — it's purely a layout tweak this example makes for header text at a specific position, which can be removed or adjusted as needed.

**`<debug message="...">` currently outputs nothing at all**: this tag maps to the framework's `_log` function, which currently only parses the `message=` attribute and doesn't write the content anywhere at all (no echo, no file write). The `<log message="$cellrow $cellcol $cell"/>` kept in this example is left in because it has zero effect on the output either way — removing it or keeping it makes no difference. To actually check the current values of `cellrow`/`cellcol`/`cell` during development, use a tag that genuinely outputs content instead, such as temporarily inserting `<label>[$(cellrow),$(cellcol),$(cell)]</label>`.

---

## 13.9 The Row-End Subtotal Column (the TOTAL Column)

The rightmost side of each year group automatically appends a subtotal column, triggered for output by `<if cnd="cellcol>3">`:

```xml
<if cnd="cellcol&gt;3">
  <if cnd="cellrow=1">
    <th width="60" align="center">$C</th>       <!-- Header row 1: shows the year value -->
  </if>
  <if cnd="cellrow=2">
    <th width="60" align="center">TOTAL</th>    <!-- Header row 2: always shows "TOTAL" -->
  </if>
  <if cnd="cellrow&gt;2">
    <td align="right">$(FORMAT('%d',A))</td>    <!-- Data row: outputs this year's horizontal subtotal -->
  </if>
  <setvar name="K" value="K+1"/>
  <setvar name="X[K]" value="X[K]+A"/>          <!-- The subtotal column is also included in the column-total array -->
  <setvar name="Y[K]" value="Y[K]+A"/>
</if>
```

This block sits inside the **outer** `<col change="xy.YY">`, after the inner `<col change="xy.YM">` — the engine's nested `<col>` tag content, the part positioned after the nested child level, only fires once when the outer grouping key is about to change, which happens to line up with "after running through every month of a year, print that year's subtotal once."

---

## 13.10 The Row-End AMOUNT Column (Horizontal Grand Total)

The far right of every row outputs the row's overall horizontal grand total, positioned outside `<col change="xy.YY">`, before `</tr>`:

```xml
<if cnd="cellrow=1">
  <th width="60" align="center"> </th>
</if>
<if cnd="cellrow=2">
  <th width="60" align="center">AMOUNT</th>
</if>
<if cnd="cellrow&gt;2">
  <td align="right">$(FORMAT('%d',B))</td>
</if>
<setvar name="K" value="K+1"/>
<setvar name="X[K]" value="X[K]+B"/>
<setvar name="Y[K]" value="Y[K]+B"/>
```

`B` accumulates cell by cell as this row is scanned (every data cell does `B := B+N`); here its final value is output directly. `K` continues to advance to record this column's position in the array, ensuring the subtotal and total rows that follow also line up and output this column correctly.

---

## 13.11 Group-End Subtotal Rows (TOTAL Rows)

After the inner `<row change="xy.cno">` ends, if a data row has already been reached (`cellrow>3`), a horizontal subtotal row grouped by salesperson is output:

```xml
<if cnd="cellrow&gt;3">
  <tr class="xtab-total-row">
    <th width="60">$R</th>
    <th width="60">TOTAL</th>
    <setvar name="I" value="1"/>
    <while cnd="I&lt;=K">
      <td width="60" align="right">$(FORMAT('%d',X[I]))</td>
      <setvar name="I" value="I+1"/>
    </while>
  </tr>
</if>
```

`R` is stored with the current row group's name when `cellcol=1` on every row (`<setvar name="R" value="cell" cnd="cellcol=1"/>`), and is referenced directly for output here. The loop over `X[1]`–`X[K]` ensures every column in the subtotal row lines up with its corresponding data column, including the year group's TOTAL column and the rightmost AMOUNT column.

**The meaning of the `cellrow>3` threshold**: cross-referencing Section 13.8, data starts at `cellrow=3`; this condition excludes the very first trigger (`cellrow=3`, the initial state before anything has been accumulated), only printing the subtotal at the point where it's genuinely "about to switch to the next salesperson" — this is the standard pattern for a control-break report, not an arbitrarily chosen number.

---

## 13.12 The Final Grand-Total Row (AMOUNT Total)

After all `<row change>` elements have finished, the vertical grand-total row for the whole report is output:

```xml
<tr class="xtab-grand-row">
  <th width="60"> </th>
  <th width="60">AMOUNT</th>
  <setvar name="I" value="1"/>
  <while cnd="I&lt;=K">
    <td width="60" align="right">$(FORMAT('%d',Y[I]))</td>
    <setvar name="I" value="I+1"/>
  </while>
</tr>
```

`Y[1]`–`Y[K]` accumulate across every cell of every row, zeroed only once at the very start, so what's output here is the whole report's grand total — it doesn't get reset when the salesperson group changes.

---

## 13.13 Complete WML Source

```xml
<?xml version="1.0" encoding="utf-8"?>
<wml>

  <card id="crosstab" title="Sales Crosstab Analysis">

    <dbquery id="xy">
      <![CDATA[
select
  year(s.sdate)                          yy,
  date_format(s.sdate, '%Y%m')           ym,
  s.Eno                                  eno,
  s.Cno                                  cno,
  sum(coalesce(s.Amount, 0))             amount
from sh s
left join cu c on c.Cno = s.Cno
where s.sdate >= '2020-06-01' and s.sdate < '2021-04-01'
group by
  date_format(s.sdate, '%Y%m'),
  s.Eno,
  s.Cno
order by yy, ym, eno, cno
      ]]>
    </dbquery>

    <crosstab dataset="xy" dialog="cno;sdate" field="amount" autospan="yes">
      <setvar name="I" value="0"/>
      <setvar name="J" value="0"/>
      <setvar name="K" value="0"/>
      <setvar name="N" value="0"/>
      <setvar name="T" value="0"/>
      <setvar name="C" value="''"/>
      <setvar name="R" value="''"/>
      <setvar name="A" value="0"/>
      <setvar name="B" value="0"/>
      <setvar name="X" value="[1..999]"/>
      <setvar name="Y" value="[1..999]"/>
      <page>
        <table class="xtab-table" rows="20" cols="15">
          <row change="xy.eno">
            <setvar name="I" value="1"/>
            <while cnd="I&lt;=99">
              <setvar name="X[I]" value="0"/>
              <setvar name="I" value="I+1"/>
            </while>
            <row change="xy.cno">
              <setvar name="K" value="0"/>
              <setvar name="B" value="0"/>
              <tr>
                <col change="xy.YY">
                  <setvar name="A" value="0"/>
                  <col change="xy.YM">
                    <log message="$cellrow $cellcol $cell"/>
                    <setvar name="C" value="cell"/>
                    <setvar name="R" value="cell" cnd="cellcol=1"/>
                    <setvar name="N" value="0"/>
                    <if cnd="(cellrow&lt;3) or (cellcol&lt;3)">
                      <if cnd="(cellrow=2) and (cellcol&lt;3)">
                      <td width="120" align="center"><i>$(IF(cell='',' ',cell))</i></td>
                      <else/>
                      <td align="center">$(IF(cell='',' ',cell))</td>
                      </if>
                      <else/>
                      <setvar name="N" value="VAL(cell)"/>
                      <td width="60" align="right">$(IF(N=0,' ',FORMAT('%d',N)))</td>
                      <setvar name="A" value="A+N"/>
                      <setvar name="B" value="B+N"/>
                      <setvar name="K" value="K+1"/>
                      <setvar name="X[K]" value="X[K]+N"/>
                      <setvar name="Y[K]" value="Y[K]+N"/>
                    </if>
                  </col>
                  <if cnd="cellcol&gt;3">
                    <if cnd="cellrow=1">
                      <th width="60" align="center">$C</th>
                    </if>
                    <if cnd="cellrow=2">
                      <th width="60" align="center">TOTAL</th>
                    </if>
                    <if cnd="cellrow&gt;2">
                      <td align="right">$(FORMAT('%d',A))</td>
                    </if>
                    <setvar name="K" value="K+1"/>
                    <setvar name="X[K]" value="X[K]+A"/>
                    <setvar name="Y[K]" value="Y[K]+A"/>
                  </if>
                </col>
                <if cnd="cellrow=1">
                  <th width="60" align="center"> </th>
                </if>
                <if cnd="cellrow=2">
                  <th width="60" align="center">AMOUNT</th>
                </if>
                <if cnd="cellrow&gt;2">
                  <td align="right">$(FORMAT('%d',B))</td>
                </if>
                <setvar name="K" value="K+1"/>
                <setvar name="X[K]" value="X[K]+B"/>
                <setvar name="Y[K]" value="Y[K]+B"/>
              </tr>
            </row>
            <if cnd="cellrow&gt;3">
              <tr class="xtab-total-row">
                <th width="60">$R</th>
                <th width="60">TOTAL</th>
                <setvar name="I" value="1"/>
                <while cnd="I&lt;=K">
                  <td width="60" align="right">$(FORMAT('%d',X[I]))</td>
                  <setvar name="I" value="I+1"/>
                </while>
              </tr>
            </if>
          </row>
          <tr class="xtab-grand-row">
            <th width="60"> </th>
            <th width="60">AMOUNT</th>
            <setvar name="I" value="1"/>
            <while cnd="I&lt;=K">
              <td width="60" align="right">$(FORMAT('%d',Y[I]))</td>
              <setvar name="I" value="I+1"/>
            </while>
          </tr>
        </table>
      </page>
    </crosstab>

  </card>

</wml>
```

`class="xtab-table"`, `class="xtab-total-row"`, and `class="xtab-grand-row"` are the WapForm for Web example site's own CSS styles (defined in the shared `wapform.htm` layout shell), unrelated to the `<crosstab>` engine itself — swapping in a different stylesheet has no effect at all on the crosstab's computation logic. Layout and logic are two separate concerns, which is also a design principle of the whole example site.

---

## 13.14 Report Design Pattern Summary

| Technique | Actual Status | Application in This Example |
|---|---|---|
| `<crosstab dataset= field=>` | Has an effect | Specifies the dataset and the cross-cell value field |
| `dialog=` | **Unused in the current version of the engine** | Writing it doesn't cause an error, but has no effect either — don't rely on it |
| `autospan=` | **Has an effect** | Adjacent header cells with identical content are automatically merged with `colspan`/`rowspan`, see Section 13.4 |
| Two-level `<row change>` | Has an effect | eno (salesperson, outer) → cno (customer, inner) |
| Two-level `<col change>` | Has an effect | yy (year, outer) → ym (year-month, inner) |
| `cellrow` / `cellcol` / `cell` | **Use this pair, not AROW/ACOL/CELL** | Determining the header/data boundary, extracting the label, see Section 13.8 |
| Compound condition `(A) or (B)` | Has an effect | `Condiction()` supports `or`/`and` keywords, no need to break it apart into `<elseif>` |
| `<debug message="...">` | **Currently outputs nothing at all** | Maps to `_log`, which is currently an empty function |
| SQL-side `group by` summing first | Recommended practice | Makes the cross-cell accumulation logic more predictable, and also faster |
| `order by` aligned with grouping levels | **Required** | Without sorting, the same group gets split into several segments, with headers printed repeatedly |
| `rows=` / `cols=` automatic pagination | Has an effect, but has a known HTML-structure issue in a browser context | See Section 13.6; if pagination isn't needed, it's recommended to omit these two attributes |
| Dynamic column-total array `X[]` | Has an effect | Cleared and re-accumulated for each salesperson group |
| Cross-group total array `Y[]` | Has an effect | Never reset, output at the end as the Grand Total row |
| Group-end subtotal row | Has an effect | `<if cnd="cellrow>3">`, the standard pattern for a control-break report |
| Zero-value blank handling | Has an effect | `$(IF(N=0,' ',FORMAT('%d',N)))` makes blank cells easier to read |

---

## Chapter 14　Building a Sales Management System

*(Using a "stationery retail" sales/collections ERP system as an example, explaining WapForm for Windows' architecture and key code)*

This chapter breaks down a real Windows desktop ERP running in a production environment: covering basic master-data entry, the shipment master-detail structure, dynamic queries, two-part continuous report printing, grouped-summary statements, and account permission management, across 12 `.wml` files.

### 14.1 System Overview

| File | Role | Type |
|---|---|---|
| `app001.wml` | System parameter entry | Single-record form |
| `app002.wml` | Product data entry | Three tabs — list + entry + description, with dynamic query |
| `app003.wml` | Brand data entry | List + quick filter |
| `app004.wml` | Customer data entry | List + quick filter + batch printing |
| `app005.wml` | Employee data entry | List + quick filter |
| `app006.wml` | Shipment entry | **Master-detail structure + dynamic query + continuous report printing** (this chapter's core) |
| `app007.wml` | Customer data sheet printing | Batch grouped report |
| `app012.wml` | A/R statement printing | Multi-level grouped summary + opening-balance carry-forward |
| `app023.wml` | Payment record inquiry | Dynamic query (read-only list) |
| `app037.wml` | Freight carrier data entry | Simplest list CRUD |
| `app901.wml` | Account management | Master table + auto-expanding sub-table |
| `app902.wml` | Password (permission) data entry | Nested master-detail + embedded sub-grid |

The table relationships radiate outward from the shipment as the core:

```
sys (system parameters) ─┐
cu (customer) ────────────┼── sh (shipment header) ── sn (shipment lines, detail)
em (employee) ────────────┤         │
fm (freight carrier) ─────┤         └── num (a date-based sequence counter)
ve (brand) ────────────────┘
pa (product, master-detail sn.pno → pa.pno)

users (account) ── login (permission, master-detail mnu.id → login.id)
```

### 14.2 Three Ways to Write Single-Table CRUD

For the same task of "maintaining one table," this system adopts three different approaches depending on the data volume and usage context, rather than applying the same template uniformly:

**(1) Single-record form** (`app001.wml`, system parameters, only ever one row of data system-wide) — `<dbquery>` paired directly with `<datasource>` outputting fields, with no `<dbgrid>`, no `<navigator>`, because there's simply no need to switch records:

```xml
<dbquery id="sys">
  <![CDATA[select * from sys]]>
  <field fieldname="Company" displaylabel="Company Name"/>
  ...
</dbquery>
<datasource dataset="sys">
  <p><fieldset>
    Company Name:<input field="Company" size="30"/><br/>
    ...
  </fieldset></p>
</datasource>
```

**(2) List + quick filter** (`app003`/`app004`/`app005`/`app037`, moderate master-data volume) — a `<dbgrid>` list paired with `<dbfilter>`, with the filter condition inputs generated automatically by the framework; the `onfilter` event assembles the user's input into `$R` and passes it back to the query:

```xml
<dbfilter result="R">
  <item field="cno" size="20" />
  <item field="cname" size="20" />
  <onevent type="onfilter">
    <dbquery id="cu"><![CDATA[select * from cu where $R order by cno]]></dbquery>
  </onevent>
</dbfilter>
```

This is WapForm's built-in declarative filter, which handles 80% of simple-condition queries, with no string concatenation the developer needs to hand-write.

**(3) The dynamic-WHERE trio** (`app002`/`app006`/`app023`, many fields, complex condition combinations) — when the filtering conditions exceed what `<dbfilter>` can express (such as an "unpaid" checkbox, an "amount including tax equals" exact match, multiple from/to ranges), you have to hand-write the three `<function>` elements `xyz`/`clr`/`set` — see the next section for details.

### 14.3 The Dynamic-Query Trio: `xyz` / `clr` / `set`

The same hand-written pattern recurs repeatedly across `app002`, `app006`, and `app023`, and is the most representative "heavyweight search" pattern in this system. Taking `app006.wml`'s shipment search tab as an example:

```xml
<function id="xyz">
  <setvar name="QUERYGUARD" value="QUERYGUARD+1"/>
  <if cnd="QUERYGUARD=1">
    <setvar name="SQL_WHERE" value="' AND 2>1'"/>
    <setvar name="SQL_WHERE" value="SQL_WHERE+' AND sh.sdate &gt;= '''+SHIPDATE_FROM+''''" cnd="SHIPDATE_FROM&lt;&gt;''"/>
    <setvar name="SQL_WHERE" value="SQL_WHERE+' AND sh.sdate &lt;= '''+SHIPDATE_TO+''''" cnd="SHIPDATE_TO&lt;&gt;''"/>
    <if cnd="CUSTNO_TO=''">
      <setvar name="SQL_WHERE" value="SQL_WHERE+' AND sh.cno like '''+CUSTNO_FROM+'%'''" cnd="CUSTNO_FROM&lt;&gt;''"/>
      <else/>
      <setvar name="SQL_WHERE" value="SQL_WHERE+' AND sh.cno &gt;= '''+CUSTNO_FROM+''''" cnd="CUSTNO_FROM&lt;&gt;''"/>
      <setvar name="SQL_WHERE" value="SQL_WHERE+' AND sh.cno &lt;= '''+CUSTNO_TO+''''" cnd="CUSTNO_TO&lt;&gt;''"/>
    </if>
    <setvar name="SQL_WHERE" value="SQL_WHERE+' AND sh.AmountTax-ifnull(sh.Paid,0)>0'" cnd="UNPAID_ONLY='Y'"/>
    ...
    <dbquery id="xy"><![CDATA[select ... from sh, cu where sh.cno=cu.cno $SQL_WHERE order by sh.sno]]></dbquery>
  </if>
  <setvar name="QUERYGUARD" value="0"/>
</function>
```

The three functions each have their own role:

| Function | Role |
|---|---|
| `xyz` | Based on the current filter input values, checks each `cnd` one by one to see if it's filled in, and if so, concatenates it into `SQL_WHERE`, then re-runs the query |
| `clr` | Clears all the filter input boxes, then calls `@xyz` to re-query (equivalent to "clear and re-search") |
| `set` | After the query runs, saves the current filter values into shadow variables prefixed with `_`; when the screen redraws, the shadow variables fill the input boxes back in, so the filter conditions don't disappear when the user switches tabs or double-clicks a list |

**`QUERYGUARD` is the most noteworthy detail in this code**: `xyz` starts by incrementing `QUERYGUARD` by one, and only actually runs the query when it equals 1, resetting it to zero at the end. This is a re-entrancy guard preventing "an event triggered during the query turning around and calling `xyz` again," which would cause infinite recursion or repeated queries — the same technique recurs word-for-word in `app002.wml`'s product query too, making it a fixed convention across this system, not a coincidence on a single page.

Whether `CUSTNO_TO` is empty determines whether the query logic switches from "single-prefix matching" to "from/to range matching," which is also common practical flexibility: when the user only fills in the "from" field, the system treats it as `LIKE 'prefix%'`; only when both from and to are filled does it switch to a genuine range query.

**📱 Flutter** (`wapform_filter.dart`: `WapFilter`)

`xyz` (search) and `clr` (clear) can be replaced directly by the **Search**/**Clear** buttons of `WapFilter` (`<dbfilter>` in Section 4.2). When you need custom conditions, keep the hand-written functions:

```dart
Future<void> xyz(String cnoFilter) async {          // search
  _ev.setVar("cno_f", cnoFilter.trim());
  setvar("S", "'1=1'");
  if (condition("cno_f<>''")) setvar("S", "S+' AND cno LIKE `'+AsSqlStr(cno_f)+'%`'");
  await db.query("sh", r"select * from sh where $S order by sno");
}

Future<void> clr() async {                          // clear
  setvar("cno_f", "''");                            // notifies varChangeHooks, so the screen can clear too
  await xyz('');
}
```

### 14.4 Shipment Master-Detail: Serial Numbers and Live Detail Totals

The "Shipment Entry" tab in `app006.wml` is this chapter's heaviest-weight example: two levels of `<datasource masterfields="sno">` nested — `sh` (header) / `sn` (detail) — maintaining both the header and the line-by-line detail on the same screen at once.

**Generating a date-based serial number** (`onnewrecord`):

```xml
<onevent type="onnewrecord">
  <dbquery id="ab"><![CDATA[select * from num where date='$DOCDATE']]></dbquery>
  <if cnd="ab.count=0">
    <dbquery><![CDATA[insert into num values ('$DOCDATE',0,0)]]></dbquery>
  </if>
  <dbquery><![CDATA[update num set sno=sno+1 where date='$DOCDATE']]></dbquery>
  <dbquery id="maxno"><![CDATA[select sno from num where date='$DOCDATE']]></dbquery>
  <setvar name="shsno" value="DOCDATE+FORMAT('%4.4d',maxno.sno)"/>
  ...
</onevent>
```

The `num` table is keyed by the ROC-calendar date (`DOCDATE`), re-accumulating the sequence from 0 each day; when inserting a new header, it first ensures that day's counter row exists (inserting it if not), then takes the number with `UPDATE ... SET sno=sno+1`, and finally assembles "date + 4-digit sequence" into the document number — for example, the 3rd document on the day `1150817` becomes `1150817` + `0003`. **Doing `UPDATE` to accumulate first, then `SELECT` to read the value, is a common number-taking pattern in single-machine/small multi-user environments** — there's still a risk of collision when multiple people insert simultaneously; a genuinely high-concurrency production scenario would usually need database-level locking or a sequence mechanism to reinforce it, but at the shipment frequency of a retail-store-scale operation, this simplified approach has run stably for over twenty years.

**Detail changes write the total amount back live**:

```xml
<function id="UpdateTotal">
  <exit cnd="DeletingItems"/>
  <invoke instance="sn" method="GetBookmark" result="BookMark"/>
  <invoke instance="sn" method="DisableControls"/>
  <invoke instance="sn" method="First"/>
  <setvar name="TempTotal" value="0"/>
  <while cnd="NOT(sn.EOF)">
    <setvar name="TempTotal" value="TempTotal+sn.Total"/>
    <invoke instance="sn" method="Next"/>
  </while>
  <setvar name="shAmount" value="TempTotal"/>
  <invoke instance="sn" method="EnableControls"/>
  <invoke instance="sn" method="GoToBookmark" params="BookMark"/>
  <invoke instance="sn" method="FreeBookmark"/>
</function>
```

The `sn` (detail) dataset's `afterpost` and `afterdelete` events both call `@UpdateTotal`: every time a detail row is inserted/edited/deleted, it re-traverses the entire detail dataset, sums the `Total` field, and writes it back to the header's `shAmount`. This demonstrates the standard usage of the `GetBookmark`/`DisableControls`/`GoToBookmark` trio — while re-scanning the dataset in the background, **first remember the current cursor position and turn off screen redrawing, then once the loop finishes, restore the cursor and turn screen redrawing back on**, avoiding the cursor visibly jumping around for the user, and also avoiding screen flicker during the row-by-row update.

The detail's three events `beforeedit`/`beforeinsert`/`beforedelete` all call `<invoke instance="sh" method="Edit"/>`: this is a chained lock that **forces the header dataset into edit state before any detail change**, ensuring the header and the detail are modified within the same transaction context, avoiding the inconsistent state of "the detail has been saved, but the header's total field still holds the old value."

### 14.5 Dynamic Linking: Barcode Scanning and Customer History Price Auto-Fill

The detail row's "Item No." field (`sn.pno`) demonstrates a two-stage chained `onchange` logic:

```xml
<field fieldname="PNo" displaylabel="Item No.">
  <onevent type="onchange">
    <if cnd="BARCODEGUARD=0">
      <dbquery id="bc"><![CDATA[select pno from pa where barcode='$snpno']]></dbquery>
      <if cnd="bc.count&gt;0">
        <setvar name="BARCODEGUARD" value="1"/>
        <setvar name="snpno" value="bc.pno"/>
        <setvar name="BARCODEGUARD" value="0"/>
      </if>
    </if>
    <dbquery id="vp"><![CDATA[select nn.price from sh hh, sn nn
      where (hh.sno=nn.sno) and (hh.cno='$sh.cno') and (nn.pno='$sn.pno')
      order by nn.pno, hh.sdate desc]]></dbquery>
    <setvar name="snPrice" value="vp.Price" cnd="vp.COUNT&gt;0"/>
    <setvar name="snPrice" value="sn.price1" cnd="vp.COUNT=0"/>
  </onevent>
</field>
```

Stage 1: the user can scan a barcode directly into the item-no. field with a barcode reader; the system first checks whether it hits `pa.barcode`, and if so, **rewrites the field value to the actual item number** — but rewriting the field value itself triggers the same `onchange` event again, and without a guard this would recurse infinitely. `BARCODEGUARD` is set to 1 before the rewrite and immediately reset to zero after, so the recursive re-entry skips the barcode-matching logic because the `BARCODEGUARD=0` check fails — this is the same "event re-entrancy guard" technique as `QUERYGUARD` in Section 14.3, just applied to a different scenario.

Stage 2: once the item number is settled, the system looks back for "the most recent transaction price this customer paid for this product" (the `vp` query, `ORDER BY sdate DESC` takes only the latest row); if there's a historical price, it's used; if not, it falls back to the product master's suggested selling price, `price1`. This is quite practical business logic: a regular customer's established price carries forward automatically, while a new customer gets the list price — the salesperson doesn't need to look up prices manually every time.

### 14.6 Popup Data Selection: Four Kinds of Lookup Dialog Cards

Beyond the built-in `lookup="table;key;display_field"` syntax on input boxes, this system also makes heavy use of **independent sub cards as popup selection windows**, where `accept`/`prev` decides between "confirm and bring back" or "cancel":

| Card | Purpose | Return Method |
|---|---|---|
| `#PC` (`app006.wml`) | Customer-list selection window, expanded from `cu1` (a customer subset filtered by `cno<'D'`) | `<prev><setvar name="shcno" value="cu1.cno"/></prev>` |
| `#PRICE` (`app006.wml`) | Shows the historical selling-price list for the same customer and same product, for manual comparison before filling in the price by hand | Read-only display, `<prev/>` closes it directly |
| `#mysub` / `#mygrp` (`app002.wml`) | Two-level product category/subcategory selection; `invoke ... method="locate"` first positions to the current value before displaying the list | `<prev><setvar name="SUBCAT_ID" value="su.id"/></prev>` |

Taking `#mygrp` as an example:

```xml
<card id="mygrp" title="">
  <dbquery id="gr">
    <![CDATA[select id,title from web where sub='$pa.sid' order by id]]>
  </dbquery>
  <invoke instance="gr" method="locate" arg1="'id'" arg2="[pa.gid]" arg3="[loCaseInsensitive,loPartialKey]"/>
  <datasource dataset="gr">
    ...
  </datasource>
  <do type="accept" label="OK">
    <prev><setvar name="GROUPCAT_ID" value="gr.id"/></prev>
  </do>
  <do type="accept" label="Cancel"><prev/></do>
</card>
```

`invoke ... method="locate"` positions the cursor to "the row corresponding to the current field value" the moment the popup opens, so the user sees at a glance which item is currently selected, instead of always having to search from the top of the list — a small usability detail, but one that makes a big difference on a data-entry screen that gets used frequently.

### 14.7 Continuous Two-Part Reports: Printing Shipment/Receiving Notes

`app006.wml`'s two print cards, `P1` (shipment note) and `P2` (receiving note), demonstrate the most classic "fixed-row-count page break" pattern for traditional dot-matrix continuous reports. Taking `P1` as an example, five `<function>` elements divide the work:

| Function | Responsibility |
|---|---|
| `header` | The page header on every page: company letterhead, customer info, table column names |
| `normal` | A regular detail row |
| `space` | Filler blank rows to reach the fixed row count (keeps the continuous form aligned) |
| `footer` | The footer when breaking pages (not yet finished printing — closes out the table, breaks the page) |
| `summary` | The footer on the final page (includes the amount total, tax, and grand total) |

The main flow manually controls page breaks:

```xml
<invoke instance="sn" method="First"/>
<go href="@header"/>
<while cnd="NOT(sn.EOF)">
  <setvar name="LINECOUNT" value="LINECOUNT+1"/>
  <if cnd="LINECOUNT>9">
    <go href="@footer"/>
    <newpage/>
    <setvar name="PAGENO" value="PAGENO+1"/>
    <setvar name="LINECOUNT" value="1"/>
    <go href="@header"/>
  </if>
  <go href="@normal"/>
  <invoke instance="sn" method="Next"/>
</while>
<while cnd="LINECOUNT&lt;9">
  <setvar name="LINECOUNT" value="LINECOUNT+1"/>
  <go href="@space"/>
</while>
<go href="@summary"/>
```

A fixed "9 rows per page" corresponds to the actual print grid of the continuous-form paper; before printing row 10, it wraps up (`@footer`), does `<newpage/>` and reprints the page header (`@header`), and the page number `PAGENO` increments. After the last detail row is printed, if fewer than 9 rows were used, `@space` fills the rest with blank rows so the table's bottom line always lands at the same place on the paper, and only then is `@summary` (with the amount total) output to finish. **This way of controlling the row count by hand is the normal approach for a specific continuous-form paper format**; it has the same goal as a modern free-flowing A4 report (such as the dynamic pagination with `<group>` used for the accounts receivable statement in Section 14.8) by different means — fixed-pitch paper needs exact alignment, while a dynamic layout relies on the framework's automatic pagination.

It's worth noting that both `P1`/`P2` make sure the data is already saved before proceeding:

```xml
<if cnd="sn.state&lt;&gt;'BROWSE'"><invoke instance="sn" method="post"/></if>
<if cnd="sh.state&lt;&gt;'BROWSE'"><invoke instance="sh" method="post"/></if>
```

This avoids the user pressing "Print Shipment Note" directly while the detail hasn't been saved yet, printing content that's out of sync with the database.

**📱 Flutter** (`wapform_report.dart`: `WapReport`, `WapPage(paper: "8.5x5.5")`)

Half-height continuous forms (8.5 × 5.5 inches) use a custom paper size; the fixed number of lines per slip is controlled by `wap.wapLpp`, and when it is full the page breaks automatically and the header in `PAGEPREFIX` is reprinted:

```dart
class ShipmentSlip extends WapReport {
  @override
  void initParams() {
    wap.wapLpp = 12;
    wap.wapGroups = 1;
    wap.wapRow[0].tagPrefix = 'G1_PREFIX';
    wap.wapRow[0].tagSuffix = 'G1_SUFFIX';
  }

  @override
  String expression(int idx) => idx == 0 ? expandText(r'$(sn.sno)') : '';

  @override
  Future<bool> fetchFirst() async {
    invoke("sn", "first");
    return !condition("sn.EOF");
  }

  @override
  Future<bool> fetchNext() async {
    invoke("sn", "next");
    return !condition("sn.EOF");
  }

  @override
  Future<void> fetchPrior() async => invoke("sn", "prior");

  @override
  void parseBlock(String id) {
    switch (id) {
      case 'PAGEPREFIX':
        emit(expandText(r'<p>Shipment $(sn.sno)  Customer: $(sn.cname)</p><table class="wap">'));
        break;
      case 'G1_PREFIX':
        setvar("SLIP_SUM", "0");
        break;
      case 'RECORD':
        setvar("SLIP_SUM", "SLIP_SUM+sn.qty*sn.price");
        emitRow(expandText(r"<tr><td>$(sn.pno)</td><td>$(sn.des)</td>"
            r"<td align='right'>$(sn.qty)</td></tr>"));
        break;
      case 'G1_SUFFIX':
        emitRow(expandText(
            r"<tr><td colspan='3' align='right'>Total $(FORMAT('%.0n',SLIP_SUM))</td></tr>"),
            isFooter: true);
        forcePageBreak();                           // each slip starts on a new page
        break;
      case 'PAGESUFFIX':
        emit('</table>');
        break;
    }
  }
}

Widget slipPage() => WapPage(title: "Shipment Slip", report: ShipmentSlip(), paper: "8.5x5.5");
```

### 14.8 Grouped Summary Reports: A/R Statements and Opening-Balance Carry-Forward

`app012.wml` (A/R Statement) is the deepest-logic report in this chapter: three levels of nested `<group>` (customer → date → document number) layered with "opening-balance carry-forward" — a classic financial-statement pattern.

```xml
<report dataset="sh" dialog="cno;sno">
  <group change="sh.cno">
    <setvar name="AMOUNT_SUM" value="0"/>
    <setvar name="TAX_SUM" value="0"/>
    <setvar name="PAID_SUM" value="0"/>
    <page>
      ... Header: customer info ...
      <group change="datetostr(sh.sdate)">
        <group change="datetostr(sh.sdate)+sh.sno">
          <group>
            <tr>... A single detail row ...</tr>
          </group>
          <setvar name="AMOUNT_SUM" value="AMOUNT_SUM+sh.amount"/>
          <setvar name="TAX_SUM" value="TAX_SUM+sh.tax"/>
          <setvar name="PAID_SUM" value="PAID_SUM+sh.paid"/>
        </group>
      </group>
    </page>
    <!-- After each customer group ends, separately query the historical balance "before this period" -->
    <dbquery id="R"><![CDATA[
      select cno, SUM(Amount) as A, SUM(Tax) as B, SUM(Paid) as C
      from sh where sh.sdate < '$(SHIPDATE_FROM)' and cno='$sh.cno' group by cno
    ]]></dbquery>
    <setvar name="BAL_BEGIN" value="R.A+R.B-R.C"/>
    <setvar name="BAL_END" value="BAL_BEGIN+AMOUNT_SUM+TAX_SUM-PAID_SUM"/>
    ... Footer: prior-period unpaid + current-period sales + current-period tax - current-period paid = current-period receivable ...
  </group>
</report>
```

The outer `<group change="sh.cno">` resets the three accumulator variables and starts a new page (`<page>` wraps the whole customer block) every time the customer changes; the middle level groups by date, and the inner level groups by document number — a direct application, in report output, of the "multi-level `group change` accumulation" technique used in Chapter 13's crosstab. **The real key is the standalone `<dbquery id="R">` after the customer group ends**: it separately queries that customer's historical total "before the query period's start date," computing `BAL_BEGIN` (the opening balance), then merges it with the current period's summed `AMOUNT_SUM`/`TAX_SUM`/`PAID_SUM` to compute `BAL_END` (the closing receivable). This is exactly the standard accounting formula for a statement — "prior-period unpaid + current-period sales + current-period tax − current-period paid = current-period receivable" — achieved with a helper query independent of the main query, rather than pulling all historical data into the main query and then filtering it. For a production environment with a larger data volume, this "query-as-needed within the group" approach can significantly reduce the data volume of any single query.

`app007.wml` (Customer Data Sheet) shares the same batch-printing skeleton as `app012.wml`, but with only a single level of grouping; the difference is that `app007` additionally offers two dropdowns for "vertical/horizontal" and "screen preview/direct print," using `device="$(IF(SP='S','PRV','PRN'))"` to dynamically decide the output device — **the same report card can switch between "print preview" and "sent straight to the printer" with just one expression**, with no need to write a separate card for each output type.

**📱 Flutter** (`wapform_report.dart`: `onGroupPrepare()`)

`parseBlock()` is synchronous and cannot wait for a query; each customer's opening balance is queried first in `onGroupPrepare()` (before the group changes, where `await` is allowed):

```dart
class ArStatement extends WapReport {
  final DbQuery db;
  ArStatement(this.db);

  @override
  void initParams() {
    wap.wapLpp = 50;
    wap.wapGroups = 1;
    wap.wapRow[0].tagPrefix = 'G1_PREFIX';
    wap.wapRow[0].tagSuffix = 'G1_SUFFIX';
  }

  @override
  String expression(int idx) => idx == 0 ? expandText(r'$(sh.cno)') : '';

  @override
  Future<void> onGroupPrepare() async {
    await db.query("ob", r"select sum(amount-paid) bal from sh "
        r"where cno=$(AsQuoted(sh.cno)) and sdate<$(AsQuoted(date_from))");
  }

  @override
  Future<bool> fetchFirst() async {
    invoke("sh", "first");
    return !condition("sh.EOF");
  }

  @override
  Future<bool> fetchNext() async {
    invoke("sh", "next");
    return !condition("sh.EOF");
  }

  @override
  Future<void> fetchPrior() async => invoke("sh", "prior");

  @override
  void parseBlock(String id) {
    switch (id) {
      case 'G1_PREFIX':
        setvar("BAL", "VAL(ob.bal)");                 // carry forward the opening balance
        emitRow(expandText(r"<tr><th colspan='3'>$(sh.cname)  Opening $(FORMAT('%.0n',BAL))</th></tr>"),
            isHeader: true);
        break;
      case 'RECORD':
        setvar("BAL", "BAL+sh.amount-sh.paid");
        emitRow(expandText(r"<tr><td>$(sh.sdate)</td><td>$(sh.sno)</td>"
            r"<td align='right'>$(FORMAT('%.0n',BAL))</td></tr>"));
        break;
      case 'G1_SUFFIX':
        emitRow(expandText(r"<tr><td colspan='3' align='right'>Closing $(FORMAT('%.0n',BAL))</td></tr>"),
            isFooter: true);
        break;
    }
  }
}
```

Usage: `WapPage(title: "A/R Statement", report: ArStatement(db))`.

### 14.9 Mail Integration: One-Click Customer Shipment Notification

The "Send Email" button on the shipment-entry page calls the operating system's default mail program directly:

```xml
<do type="accept" label="Send Email">
  <setvar name="SQL_WHERE" value="
'Order ['+sh.sno+'] has been shipped, delivery is expected to take 1-3 business days, %0A'+
...
'%0A'"/>
  <shellexecute operation="open" file="mailto:$(sh.email)?subject=Stationery Retail Shipment Notification&amp;body=$(trim(SQL_WHERE))"/>
</do>
```

`shellexecute` calls the operating-system-level `mailto:` protocol, carrying the recipient (the customer's email), subject, and body, opening the user's locally installed mail software with the content pre-filled, leaving the salesperson to click send — **there's no need for WapForm to handle the SMTP connection itself** (compare this with Chapter 15's Web environment, which uses the `<mail>` tag to send email directly server-side — two equally practical but fundamentally different integration approaches, server-side vs. client-side). The body is manually assembled with a string variable; `%0A` is the line-break encoding used in a mailto URL.

### 14.10 Account and Permission Management: Nested Master-Detail + Auto-Expanding Sub-Tables

`app901.wml` (Account Management) and `app902.wml` (Permission Management) are a complementary pair of management features.

**Auto-expanding full-menu permission records when adding an account** (`app901.wml`):

```xml
<onevent type="beforepost">
  <dbquery id="log"><![CDATA[select * from login where uid='$users.userid']]></dbquery>
  <if cnd="log.count=0">
    <dbquery id="mnu"><![CDATA[select * from mnu]]></dbquery>
    <dbquery id="maxitm"><![CDATA[select max(itm) as itm from login]]></dbquery>
    <setvar name="LOGINITM" value="maxitm.itm+1"/>
    <report dataset="mnu">
      <group>
        <dbquery><![CDATA[insert into login values($mnu.id,$LOGINITM,'$users.userid',1,0)]]></dbquery>
      </group>
    </report>
  </if>
</onevent>
```

When creating a new account, it first confirms this account has no permission records yet, then **sweeps through the whole menu table `mnu` row by row, using a `<report>...<group>` loop to `INSERT` a permission record for every single menu item** (defaulting to read-only). This is the "when adding a master record, automatically expand a whole batch of corresponding detail rows" batch-creation pattern — the same design thinking as Section 6.6's "background batch purchase-order expansion," just applied here to initializing permissions rather than expanding an order.

**Nested master-detail with an embedded sub-grid directly inline** (`app902.wml`):

```xml
<datasource dataset="mnu">
  <p><navigator/></p>
  <dbgrid height="200">
    <item field="id" size="10"/>
    <item field="title" size="30"/>
  </dbgrid>
  <datasource name="ds" dataset="login" mastersource="mnu" masterfields="id">
    <p><navigator/></p>
    <dbgrid name="gd" height="200">
      <item field="itm" title="Seq." size="10"/>
      <item field="uid" size="30" lookup="users;userid"/>
      <item field="w" title="Active" type="checkbox" range="1;0" size="10"/>
    </dbgrid>
  </datasource>
</datasource>
```

The outer `<dbgrid>` is the menu list; the inner `<datasource mastersource="mnu" masterfields="id">` is nested directly inside the outer `<datasource>`, with both `<dbgrid>` elements displayed on screen at the same time — clicking a menu item on the left automatically filters the sub-grid on the right to show only the user-permission list under that menu item, with no need to write a separate `onselect` event to manually re-query; the master-detail relationship is driven entirely by the `masterfields` declaration. Compared with Section 3.2's single-level "master-detail structure" pattern, the difference here is only that the sub-grid is presented directly as a `<dbgrid>`, allowing in-place checking of the `w` (active) column, letting an administrator quickly adjust multiple users' read/write permissions for a single feature on the same screen.

### 14.11 Chapter Summary

| Technique | Corresponding Section | Real-World Purpose |
|---|---|---|
| Three single-table CRUD approaches chosen by data type | 14.2 | Single-record form / list with quick filter / heavyweight dynamic query coexist, without forcing one uniform template |
| `QUERYGUARD` re-entrancy guard | 14.3 | Prevents the dynamic-query function from being triggered repeatedly within an event chain |
| Date-serial table `num` for number generation | 14.4 | `UPDATE...SET sno=sno+1` then `SELECT`, a simplified serial-number generation approach |
| The `GetBookmark`/`DisableControls` trio | 14.4 | Avoids screen flicker and cursor jumping while re-scanning a dataset in the background |
| `BARCODEGUARD` recursion protection | 14.5 | Avoids infinite event recursion when `onchange` rewrites a field's value |
| Customer historical transaction-price fill-back | 14.5 | `ORDER BY sdate DESC` takes the latest row; falls back to the list price if there's no history |
| Popup lookup card + `locate` positioning | 14.6 | The cursor automatically rests on the current value when the selection window opens |
| Fixed-row-count manual page breaks | 14.7 | A five-function header/footer print pattern matching a continuous-form paper specification |
| Query-as-needed opening balance within a group | 14.8 | The statement's standard accounting formula, "opening + current period − collected = receivable," put into practice |
| `shellexecute mailto:` | 14.9 | No SMTP to write — directly invokes the local mail software |
| Batch-expanding detail rows when adding a master record | 14.10 | A new account automatically generates default permission records for the whole menu |
| Nested `datasource` with an embedded sub-grid inline | 14.10 | The master-detail relationship is entirely declarative, no `onselect` to write |

Together, these twelve files sketch out the skeleton of a typical manufacturing/retail sales system: from basic master-data entry, through the master-detail structure and serial-number generation of business documents, to print output and permission governance — every piece of code was written to solve a real business problem, and as a result it retains the kind of detail that "never shows up in a textbook example, but a production system can't do without" — barcode scanning, historical price comparison, mailto notifications.

---

---

## Chapter 15　Building a Dynamic Web Trading Platform (WapForm for Web)

This chapter doesn't use a fictional example — it directly breaks down a **real site currently running in production**: the WapForm official website's own "shop + manual" site. This site serves double duty — externally, it's an online shop with category browsing, search, and a shopping cart; internally, it's simultaneously the manual system this book's reader is reading right now — it's a real-world case of WapForm building itself (dogfooding), with 11 `.wml` files working together.

### 15.1 System Overview

Unlike a typical e-commerce tutorial example, this site **has no separate "product table" or "manual index table"**: categories, products, manual topics, and shopping notices are all mixed together in the same `pa` table, distinguished from one another via three fields — `mnu`, `typ`, `gid`:

| Field | Role |
|---|---|
| `mnu='m'` | Marks that this row should also appear in the site-wide menu tree |
| `typ` | Determines which kind of page this menu item leads to when clicked: `b`=manual (book), `n`=notice (note), `p`=static page (page), `s`=shop, other=category grid navigation (grid) |
| `gid` | The parent category code, used to build the menu's parent-child hierarchy |

The benefit of this design is: adding a product category also automatically adds a menu node, with no separate menu table to maintain; the cost is that the query logic has to filter very carefully by `mnu`/`typ`/`gid`, or manual topics will get mixed into the shop listing.

The site is made up of five page types plus three shared components:

```
┌───────────────────────────────────────────────────────────┐
│  header.wml / footer.wml / asider.wml   ← Site-wide shared components │
│  ├── index.wml (= shop.wml)   Shop homepage/listing/search/pagination │
│  ├── grid.wml                 Category grid navigation                 │
│  ├── book.wml + book-js.wml   Manual (AJAX partial loading)            │
│  ├── note.wml + note-js.wml   Shopping notices (AJAX partial loading)  │
│  └── page.wml                 Pure static content page                │
└───────────────────────────────────────────────────────────┘
```

Complete file dependency table:

| File | Role | Included Components | Main Tables |
|---|---|---|---|
| `header.wml` | Site-wide menu construction + shopping-cart summary | None (included by every page) | `pa` (`mnu='m'`), `rn`, `cu` |
| `footer.wml` | Footer bestseller shortcuts | None (included by every page) | `pa` (`mnu='m'`, `qty>8600`) |
| `asider.wml` | Side floating menu (reuses the arrays header already built) | No `dbquery` of its own | None |
| `index.wml` (= shop.wml) | Shop homepage/listing/search | header, footer, asider | `sys`, `counter`, `pa`, `web`, `sn` |
| `grid.wml` | Category grid navigation | header, footer, asider | `sys`, `pa` |
| `book.wml` | Manual menu page | header, footer, asider; AJAX → `book-js.wml` | `sys`, `pa` |
| `book-js.wml` | Manual body content (AJAX partial loading) | Called by `book.wml` (`loadDoc`) | `pa` (single-row `topic`) |
| `note.wml` | Shopping-notices menu page | header, footer, asider; AJAX → `note-js.wml` | `sys`, `pa` |
| `note-js.wml` | Notice body content (AJAX partial loading) | Called by `note.wml` (`loadDoc`) | `pa` (single-row `topic`) |
| `page.wml` | Static content page | header, footer (**does not include asider**) | `sys`, `pa` |

`page.wml` is the only page that doesn't include `asider` — it's a pure content page that doesn't need the side floating menu competing for layout space; this is a deliberate design choice, not an oversight.

### 15.2 A Menu Tree Queried Once and Shared Site-Wide

All five pages need to display the same category menu; if each queried it separately, the same data would be queried five times. `header.wml`'s approach is: **query once, only inside the `header` sub card, flatten the result into arrays and store it**; the other components (`asider.wml`, `index.wml`'s sidebar) read the arrays directly, never touching the database again.

```xml
<card id="menu" device="sub">
  <setvar name="mnu_id" value="[0..1023]" />
  <setvar name="mnu_typ" value="[0..1023]" />
  <setvar name="mnu_title" value="[0..1023]" />
  <setvar name="mnu_icon" value="[0..1023]" />
  <setvar name="mnu_count" value="[0..1023]" />

  <!-- Level 1: top-level categories (gid='0000') -->
  <dbquery id="mnu">
    <![CDATA[select pno, gid, typ, des, icon from pa
             where mnu='m' and gid='0000' and active>0 order by pno]]>
  </dbquery>
  <while cnd="not(mnu.eof)">
    <setvar name="mnu_id[k]" value="mnu.pno" />
    <setvar name="mnu_typ[k]" value="mnu.typ" />
    <setvar name="mnu_title[k]" value="mnu.des" />
    <setvar name="mnu_icon[k]" value="mnu.icon" />
    <setvar name="p" value="k" />
    <setvar name="k" value="k+1" />

    <!-- Level 2: uses level 1's pno as gid, queries the sub-items -->
    <dbquery id="itm">
      <![CDATA[select pno, gid, typ, des, icon from pa
               where mnu='m' and gid='$mnu.pno' and active>0 order by pno]]>
    </dbquery>
    <setvar name="i" value="0" />
    <while cnd="not(itm.eof)">
      <setvar name="mnu_id[k]" value="itm.pno" />
      <setvar name="mnu_typ[k]" value="itm.typ" />
      <setvar name="mnu_title[k]" value="itm.des" />
      <invoke instance="itm" method="next" />
      <setvar name="i" value="i+1" />
      <setvar name="k" value="k+1" />
    </while>
    <setvar name="mnu_count[p]" value="i" />   <!-- Records how many sub-items this parent node has -->
    <invoke instance="mnu" method="next" />
  </while>
  <setvar name="mnu_count[k]" value="999999" /> <!-- Sentinel value: marks the end of the array -->
```

This is a manually flattened "two-level parent-child `mnu_count[]` index array" pattern: `mnu_id[]`/`mnu_typ[]`/`mnu_title[]` place parent and child nodes **in sequence** consecutively into the same one-dimensional array; `mnu_count[p]` is recorded only at the parent node's index position, recording "how many sub-items immediately follow this parent node." After that, any component that gets hold of this array can rebuild the whole tree with just a `while cnd="not(mnu_count[k]=999999)"` loop, without querying the database again and without recursion — this is a deliberate performance strategy trading "query once, share the array" for "zero queries in every downstream component" (see Chapter 5 on arrays as lookup tables for more detail).

### 15.3 Component Reuse: asider.wml Never Touches the Database

`asider.wml` demonstrates how shared components pass data to each other via arrays, instead of querying repeatedly:

```xml
<card id="asider" device="sub">
  <setvar name="i" value="0"/>
  <setvar name="k" value="0"/>
  <block name="asider.aa"/>
  <while cnd="not(mnu_count[k]=999999)">
    <!-- Reads header.wml's already-built mnu_id[]/mnu_typ[]/mnu_count[] directly, no dbquery of its own -->
    <setvar name="p" value="mnu_count[k]"/>
    ...
    <block name="asider-list.aa"/>
    <setvar name="k" value="k+1"/>
    <while cnd="i&lt;p">
      <block name="asider-item"/>
      <setvar name="i" value="i+1"/>
      <setvar name="k" value="k+1"/>
    </while>
    <block name="asider-list.zz"/>
  </while>
  <block name="asider.zz"/>
</card>
```

The precondition is that `<include name="header"/>` must come before `<include name="asider"/>`, so the `mnu_id[]` and other arrays are already built — this is a concrete instance of "include order is the data-dependency order," and also the reason behind the "no `dbquery` of its own" row for `asider.wml` in this section's dependency table.

### 15.4 Deciding the Link Target Dynamically by Content Type

Which page a menu item leads to when clicked is not hard-coded; it is decided dynamically by `pa.typ`. The four files `header.wml`, `asider.wml`, `grid.wml` and `index.wml` each contain an almost identical `switch`:

```xml
<switch exp="mnu_typ[k]">
  <case value="b"><setvar name="app" value="'book'" /></case>
  <case value="n"><setvar name="app" value="'note'" /></case>
  <case value="p"><setvar name="app" value="'page'" /></case>
  <case value="s"><setvar name="app" value="'shop'" /></case>
  <default>       <setvar name="app" value="'grid'" /></default>
</switch>
```

Once `app` is computed, the link in the template is written as `href="$(app).wml?gp=$(mnu_id[k])"`. This `switch` recurs more than six times across the four files — a trade-off commonly seen in real production code: the linking rule is simple and stable, so repeating it inline is more intuitive and lower-risk to modify than extracting it into a shared `block`; but if a sixth content type needs adding down the line (say, a video page `typ='v'`), you have to remember to update all six spots in sync. **This is a real flaw deliberately left in this chapter, not a teaching demonstration**: if you see the same `switch` appearing more than three times in your own project, that's usually a sign it should be extracted into a shared `block`.

### 15.5 AJAX Partial Loading: The Two-File Design for Manuals and Notices

`book.wml`/`note.wml` are only responsible for drawing the menu framework; the actual body content is loaded partially via AJAX by `book-js.wml`/`note-js.wml`, with both structured completely symmetrically. Taking the manual as an example:

```xml
<!-- book.wml: the content sub card only emits a container + a JS call -->
<card id="content" device="sub">
  <![CDATA[
    <div id="xyz"></div>
    <script>loadDoc('book-js.wml?pg=$id');</script>
  ]]>
</card>
```

```xml
<!-- book-js.wml: a standalone wml file, device="wapform-js.html" -->
<card id="P" title="Stationery Retail" device="wapform-js.html">
  <setvar name="pg" value="'500120001'" />
  <setvar name="pg" value="request.pg" cnd="DEFINE(request.pg)" />
  <dbquery id="pa">select pno, des, topic from pa where pno='$pg'</dbquery>
  <wap>
    <![CDATA[
      $pa.topic
      <div>$pa.pno</div>
      <div>$pa.des</div>
    ]]>
  </wap>
</card>
```

`loadDoc()` is defined in the shared `wapform.html` template, a standard `XMLHttpRequest`:

```javascript
function loadDoc(url) {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (xhttp.readyState == 4 && xhttp.status == 200) {
      document.getElementById('xyz').innerHTML = xhttp.responseText;
    }
  }
  xhttp.open("GET", url, true);
  xhttp.send();
}
```

Every menu item in `book.wml`'s sidebar is `<a href="javascript:loadDoc('book-js.wml?pg=$itm.pno')">`; clicking it only re-requests `book-js.wml` (a single `topic` field), **without a full page reload, and without re-running the menu-construction logic**. This is the core value of splitting the "menu framework page" and the "content page" into two separate `.wml` files: the content page can be cached independently, tested independently, and even reimplemented in a different language in the future without affecting the outer framework. `device="wapform-js.html"` is a lightweight template prepared specifically for this kind of partial fragment — it has no `<head>`, menu, or footer, and outputs only the content itself.

### 15.6 The Shop Homepage: Three Operating Modes and Safe Dynamic Query Assembly

`index.wml` uses the `op` parameter to switch between three semantically distinct modes within the same file:

| `op` Value | Meaning | Corresponding `content` Card Query |
|---|---|---|
| `s` | Search | Dynamically assembles a `WHERE` clause based on keywords |
| `g` | Current on-sale products | The `web` table JOINed with `pa` |
| `i` | Category listing | `pa.gid = a specified category` |

Of these, `op='s'` search is the most worth breaking down, because it demonstrates **manually parsing multiple keywords with string functions and assembling a safe SQL condition using a fixed quote-escaping approach**:

```xml
<setvar name="i" value="1" />
<setvar name="j" value="1" />
<setvar name="s" value="''" />
<while cnd="j&lt;len(gp)">
  <if cnd="(mid(gp,j,1)='+') or (mid(gp,j,1)=' ')">
    <setvar name="s"
      value="s+' and (p.pno like ''%$(mid(gp,i,j-i))%'' or p.des like ''%$(mid(gp,i,j-i))%'')'" />
    <setvar name="i" value="j+1" />
  </if>
  <setvar name="j" value="j+1" />
</while>
<setvar name="s"
  value="s+' and (p.pno like ''%$(mid(gp,i,j-i+1))%'' or p.des like ''%$(mid(gp,i,j-i+1))%'')'" />
```

Multi-keyword input like `gp='cat food can'`, separated by spaces or `+`, is scanned character by character and split into segments; each segment is assembled into a `pno LIKE '%...%' OR des LIKE '%...%'` clause, finally concatenated into the complete `WHERE` clause fragment `s`, which is handed to the `dbquery` below. **Note that two consecutive single quotes `''` in a SQL string are what an escaped single quote looks like after escaping** — this is the easiest place to get wrong when manually assembling a concatenated query string, and the place that most needs attention to injection risk; a production environment is recommended to pair this with a field whitelist or parameterized queries to further reduce the risk.

The `az` parameter determines the sort strategy: `az`/`za` sort ascending/descending by `pno`; `aa` sorts by historical sales volume (`LEFT JOIN sn`, summing `qty`, then `ORDER BY amount DESC`) from best-selling to least; `zz` is a data-inspection mode restricted to administrators (`session.usr='admin'`), used to check anomalous products with `active>1`. The benefit of this "using the same query entry point, switching between completely different sort/filter logic via a single mode parameter" approach is that pagination, the search box, and the sort buttons all share the same `content` card, without needing a separate page written for each sort order.

### 15.7 The Pagination-Row Generator: the `navigator` Sub Card

The pagination buttons are also an independent sub card, relying only on `PG` (the current page number) and `PAGES` (the total page count, `CEIL(total rows/20)`), dynamically computing a window showing "5 pages before and after the current page":

```xml
<setvar name="R" value="nav.count" />
<setvar name="PAGES" value="CEIL(R/20)" />
<setvar name="P" value="0" />
<setvar name="P" value="PG-6" cnd="(PG-6)&gt;0" />
<setvar name="P" value="PAGES-5" cnd="(PG+5)&gt;PAGES" />
...
<while cnd="K&lt;PAGES">
  <setvar name="K" value="K+1" />
  <if cnd="(K&gt;=P+1) and (K&lt;=P+5)">
    <if cnd="K=PG">
      <![CDATA[<li class="page-item active"><a class="page-link" href="#">$K</a></li>]]>
      <else />
      <![CDATA[<li class="page-item"><a class="page-link" href="shop.wml?op=$op&gp=$gp&pg=$K&az=$az">$K</a></li>]]>
    </if>
  </if>
</while>
```

`navigator` completely re-runs the exact same query-condition assembly logic as the `content` card (it just doesn't pull the fields, only `count`) — this is the real cost of "the query-condition logic has to be maintained separately in two cards": the row count and the content listing belong to two independent queries, and if the search-condition logic ever changes, both places have to be updated in sync — which is also why the "duplicated logic" judgment criterion mentioned in Section 15.4 applies here too.

### 15.8 Shopping-Cart Summary: The Built-In Cash-Flow Calculation in `header.wml`

Interestingly, the shopping-cart subtotal isn't a separate page — it's built directly into **`header.wml`, which every page includes**, so any page's header shopping-cart icon can show the item count and amount live:

```xml
<if cnd="DEFINE(session.ord)">
  <dbquery id="od"><![CDATA[
    SELECT ss.sno, ss.itm, ss.cno, cu.cname, ss.pno, pa.des, pa.unit, ss.qty, ss.price
    FROM rn ss, cu, pa
    WHERE (ss.sno = '$session.ord') AND (cu.cno = ss.cno) AND (pa.pno = ss.pno)
    ORDER BY ss.sno, ss.itm
  ]]></dbquery>
  <block name="line.aa" />
  <while cnd="not(od.eof)">
    <block name="line-item" />
    <setvar name="QtyTotal" value="QtyTotal+1" />
    <setvar name="TempTotal" value="TempTotal+od.qty*od.price" />
    <invoke instance="od" method="next" />
  </while>
  <if cnd="TempTotal&gt;0">
    <setvar name="TempTotal" value="TempTotal+90" cnd="TempTotal&lt;1000" />
    <setvar name="Tax" value="TempTotal*5/100" />
    <setvar name="TotalTax" value="TempTotal+Tax" />
  </if>
  <block name="line.zz" />
</if>
```

Whether the shopping cart has any content is determined entirely by `session.ord` (whether an order serial number has already been created); a NT$90 shipping surcharge for orders under NT$1000, and a flat 5% tax rate — these two business rules are written directly into `header.wml`, meaning any page can reflect "whether the total has crossed the free-shipping threshold after adding to the cart" — this is exactly the real-site landing of the "Web Member Login and Session Management" pattern from Section 3.8.

### 15.9 Session Lifetime: Three Layers and Per-Variable Expiry

A shopping site has two kinds of state that must survive across pages: the login identity (`session.usr`) and the shopping-cart serial number (`session.ord`). How long each should live has different answers — identity is a matter of security, and keeping it too long is a risk; keeping the cart serial number too long holds on to unpaid scratch data. This section explains how far this can be controlled.

**First, recognize that the lifetime of state is layered**

| Layer | Controlled by | Current behavior |
|---|---|---|
| Session variable | `<session expire="minutes"/>` | Not set = never expires by itself |
| Browser cookie | Server setting | 1 day after it is issued |
| Server session | Server setting | Reclaimed after 7 days idle since the last request |
| Server process | None | Everything disappears on restart |

**The layer that expires first decides**. Today the cookie's 1 day is the shortest, so in practice "the login is remembered for at most 1 day" — even writing `expire` as 7 days does not help: when the user comes back on day 2, the browser no longer has the session ID and the server cannot find the session.

When designing, work backwards from the shortest layer; do not assume the number you wrote is the final behavior.

**Per-variable expiry**

Variables in the same session can have their own lifetimes:

```xml
<!-- login identity for 8 hours -->
<session name="usr" value="A" expire="480"/>

<!-- the shopping-cart serial number only 2 hours, released automatically on time-out -->
<session name="ord" value="S" expire="120"/>
```

Before parsing the card on every request the engine removes expired variables, so the reading side need not check for a time-out itself:

```xml
<!-- once session.usr has expired, this guard naturally sends the user to the login page -->
<if cnd="NOT(DEFINE(session.usr))">
  <redirect href="login.wml"/>
  <exit/>
</if>
```

To renew, write the same variable again; the expiry is recalculated from now:

```xml
<session name="usr" value="session.usr" expire="480"/>
```

**When `expire` is not set**

Omitting `expire` does not mean "not stored" but "no expiry of its own" — the variable exists until the whole session disappears. Existing WML needs no changes at all.

**Do not keep important state only in the session**

The last row of the table above deserves attention: session data lives in server memory and disappears completely when the process restarts, which WML cannot control. Unpaid cart contents should therefore be written to the database (this site writes them to the `rn` table; `session.ord` only keeps the serial number), with the session holding only "the key that points to the data", not the data itself. Then even if the session disappears, the order is still there after the user signs in again.

**By the way: do not store passwords in the session**

After a successful sign-in, this site's `login.wml` writes two variables:

```xml
<session name="usr" value="A"/>
<session name="pwd" value="B"/>
```

`pwd` holds the plain-text password, yet no page on the site ever reads `session.pwd`; sign-in is verified by comparing `MD5(B)`. Such a sensitive value that is written but never read should simply be removed — it serves no purpose other than keeping one more copy of the password in memory.

### 15.10 Chapter Summary

| Technique | Corresponding Section | Real-World Purpose |
|---|---|---|
| Query once, build arrays, share across components | 15.2 / 15.3 | The menu tree is only queried once from the database; `asider.wml` does zero queries |
| Routing driven by the `typ` field | 15.4 | One table doubles as categories, products, manuals, and notices, routed by a type field |
| Framework-page/content-page two-file AJAX | 15.5 | Manual and notice body content can be updated independently, without triggering a full-page redraw |
| Manual string parsing to build a dynamic WHERE | 15.6 | Multi-keyword search, with attention needed to single-quote escaping and injection risk |
| An independent pagination sub card | 15.7 | Pagination logic is decoupled from the content query, but the query condition needs syncing in two places |
| Session-driven header shopping-cart summary | 15.8 | A site-wide shared component with business rules built in (shipping threshold, tax rate) |
| Session's three lifetimes and per-variable expiry | 15.9 | Separate lifetimes for the login identity and the shopping-cart serial number |

None of these techniques are "textbook patterns" — they all come from the same set of files currently serving real traffic, duplication, trade-offs, and known maintenance costs included. The source files broken down section by section in this chapter are `header.wml`, `footer.wml`, `asider.wml`, `index.wml`, `grid.wml`, `book.wml`, `book-js.wml`, `note.wml`, `note-js.wml`, `page.wml`, and `wapform.html` — eleven files in total, which readers can cross-reference for the full context.

---

---

## Chapter 16　Deploying the Same Definition to Flutter (WapForm for Flutter)

*(Using the 12 `.wml` files `app001`–`app902` of Chapter 14's stationery-store sales management system to explain how the same definition is deployed to Flutter)*

The 12 `.wml` files of Chapter 14 are not limited to becoming a Windows desktop program. WapForm for Flutter lets **the same WML definition**, without changing a line, be expanded by the WapForm Toolkit generator into a complete set of Flutter pages; the Dart code it produces calls the `wapform_flutter` modules introduced in the 📱 Flutter sections throughout this book.

### 16.1 Why Another Runtime Is Needed

What makes multi-platform development truly expensive has never been "what the components look like", but **having to redevelop the application logic for every new platform**. What WapForm solves is not porting components but porting **the way an application is defined**: data sources, fields, lookups, events, forms and reports are all described in WML, tied to no platform's syntax.

> **Define once, deploy many times.**

`wapform_flutter` is the runtime WML needs to land on Flutter; it is also an ordinary Dart package that can be written by hand and used directly, without the generator.

### 16.2 Package Architecture: WapForm Modules

| Module | Role | Corresponding WML |
|---|---|---|
| `wapform_expression.dart` | Expression engine `WapEvaluator`: nearly 600 built-in functions, custom functions can be registered; no database dependency | Chapter 6, Appendix B, Appendix C |
| `wapform_lazarus.dart` | Tag engine: `useEngine()`, `setvar()`, `expression()`, `condition()`, `expand*()`, `invoke()`, `varChangeHooks`; dataset registry `DataSetRegistry`; queries `DbQuery` | `<setvar>`, `<if>`, `<while>`, `<invoke>`, `<dbquery>`, `$(...)` |
| `wapform_lookup_box.dart` | Lookup drop-down `WapLookupBox` | `<input lookup>`, `<item lookup>` |
| `wapform_filter.dart` | Filter bar `WapFilter`/`FilterItem` | `<dbfilter>` |
| `wapform_report.dart` | Grouped report engine `WapReport`, report preview page `WapPage`, paper and orientation helpers | `<report>`, `<group>`, `<page>`, `<newpage>`, `device="PRV"` |
| `wapform_report_style.dart` | Report CSS: `reportCssScreen`, `reportCssPrint`, `reportCssSrc` | Report styles such as `class="wap"` |
| `report_web.dart` | Printing implementation chosen per platform (Web: print from a new tab) | Printing on the Web |
| `wapform_colors.dart` | `WapColors`: reads shared colors from `assets/wapform.htm` | Alternating row colors `class="row1"`/`"row2"` |

### 16.3 How WML Tags Map One-to-One to Dart Classes

| WML | Dart |
|---|---|
| `<dbquery id="em">` | `await db.query("em", sql)` |
| `<setvar name= value=>` | `setvar(name, value)` |
| `<if cnd=>`/`<while cnd=>` | `if (condition(...))`/`while (condition(...))` |
| `<invoke instance= method=>` | `invoke(instance, method)` |
| `$(...)` | `expandText()`; `expandSql()` in SQL |
| `<input lookup=>` | `WapLookupBox` |
| `<dbfilter>` | `WapFilter` |
| `<report>`/`<group change=>` | `WapReport` subclass, `expression(idx)` |
| `device="PRV"` | `WapPage` |
| `<platform name="flutter">` | The CDATA content becomes Dart code as is |

For the complete mapping of each tag, see the 📱 Flutter section of each tag in Chapter 4 and the table in Section 4.13. This one-to-one mapping lets the generator's output be fully mechanical.

### 16.4 Mapping Master-Detail Structures: Shipments and Line Items

The declarative master-detail link `masterfields="sno"` expands in Flutter into "the header cursor moves → re-query the detail with the header's number", and new detail rows get the header's number:

```dart
Future<void> onShipmentScroll() =>
    db.query("sn", r"select * from sn where sno=$(AsQuoted(sh.sno)) order by itm");

void onNewItem() => setvar("sn.sno", "sh.sno");
```

This matches the Windows behavior of Section 3.2, "Pattern: Master-Detail Structure"; only the event hook points differ. `<item lookup="pa;pno;des">` is provided by `WapLookupBox(forGrid: true)` as a lookup list inside the grid cell.

### 16.5 Mapping the Report Engine: How Group Subtotals Become `parseBlock`/`emitRow`

The three-part structure of `<group change="sh.cno">` (group start, row-by-row output, group end) expands into `G1_PREFIX`, `RECORD` and `G1_SUFFIX` of `WapReport.parseBlock()`; the expression in `change=` is the return value of `expression(0)` (full code in the 📱 Flutter section of `<group>` in Section 4.7).

`emitRow()` checks the line count every time it outputs a line, and at `wap.wapLpp` lines it outputs `PAGESUFFIX` → `PAGEBREAK` → `PAGEPREFIX` — whether the line comes from a WML `<group>` or is hand-written, the caller never has to track how many lines have been printed. Lines output by sub-reports (`device="sub"`) count in the same page flow, so even multiple nested levels do not break the layout.

`WapPage` parameters:

| Parameter | Description |
|---|---|
| `title` | Title |
| `report` | A `WapReport` object (either this or `src`) |
| `src` | HTML given directly, passed through `expandText()` first (either this or `report`) |
| `paper` | `A4` (default), `A3`, `A5`, `B5`, `letter`, `legal`, or custom inches such as `"8.5x5.5"` |
| `orient` | `P` (default); `L`, `landscape`, `1`, `橫` and `水平` mean landscape |
| `showPrint` | Whether to show the Print button |
| `fontAsset` | The CJK font used when producing a PDF (default `assets/fonts/NotoSansTC-Regular.ttf`) |
| `padding`, `htmlStyle` | Layout margins and custom HTML styles |

Paper helper functions: `isLandscape(orient)`, `normalizePaper(paper)`, `customPaperSizeInches(paper)` (`"8.5x5.5"` → `(8.5, 5.5)`), `pageSizeOf(paper, orient)` (the value for CSS `@page size`).

### 16.6 File Architecture: One File, One Independent Unit

`wapform_flutter.dart` is a barrel file: `import 'package:wapform_flutter/wapform_flutter.dart'` pulls in every file at once; each file can also be imported on its own, for example `package:wapform_flutter/wapform_expression.dart` when you only need the expression engine. The files sit flat under `lib/` rather than hidden in `lib/src/` precisely to keep individual imports possible.

| File | Depends on |
|---|---|
| `wapform_expression.dart` | Only `crypto`; usable on its own |
| `wapform_lazarus.dart` | The expression engine + the package's datasets |
| `wapform_lookup_box.dart`, `wapform_filter.dart` | Flutter |
| `wapform_report.dart` | The tag engine + `wapform_report_style.dart` + `report_web.dart` |
| `wapform_colors.dart` | Flutter (reads an asset) |

### 16.7 Real-World Validation: `app001` Through `app902` Translated All at Once

The 12 `.dart` files under `example/lib/pages/` are generated automatically by the WapForm Toolkit from Chapter 14's `app001.wml`–`app902.wml`:

| Flutter Page | Corresponds to Chapter 14 | Tables |
|---|---|---|
| `app001.dart` | 14.2 System parameter entry | `sys` |
| `app002.dart` | 14.2/14.6 Product master entry (with `<platform>` image upload) | `pa` (`web`/`ve` are lookup source tables) |
| `app003.dart` | 14.2 Brand data entry | `ve` |
| `app004.dart` | 14.2 Customer data entry | `cu` |
| `app005.dart` | 14.2 Employee data entry | `em` |
| `app006.dart` | 14.4–14.7, 14.9 Shipment entry | `sh`/`sn`/`cu`/`em` |
| `app007.dart` | 14.8 Customer data sheet printing | `cu` |
| `app012.dart` | 14.8 A/R statement (grouped report) | `sh` (`sys` supplies letterhead settings) |
| `app023.dart` | 14.3 Receipt inquiry | `sh`/`cu`/`fm` |
| `app037.dart` | 14.2 Freight carrier data entry | `fm` |
| `app901.dart` | 14.10 Account management | `users` |
| `app902.dart` | 14.10 Password (permission) data entry | `mnu`/`login`/`users` |

`example/` also includes the corresponding `*.wml` files, so you can compare what each tag produced, one by one.

### 16.8 Current Platform Status and Known Limitations

- **Supported platforms**: Web and Android.
- **The database is always reached through an HTTP gateway**: a browser cannot open a database connection directly; the package's `example/server/` includes a Node.js gateway.
- **Printing**: on the Web it goes to the browser's print; on Android the system WebView lays out the page and a vector PDF is produced.
- **WML features without a corresponding module**: crosstabs, charts, Web templates and Session, `<open>`/`<webcopy>`, mail and so on; when needed, embed Dart code with `<platform name="flutter">` (Section 4.5).
- **Expression engine differences**: see Appendix C.

### 16.9 Installation and Licensing

```yaml
dependencies:
  wapform_flutter: ^1.6.7
```

```dart
import 'package:wapform_flutter/wapform_flutter.dart';
```

The license is **LGPL-2.1 with a static linking exception** ("Modified LGPL"): you can use this package in a closed-source app; only when you redistribute a modified version of *the package's own source files* must those modifications be published under the same license. This is separate from the commercial license of the WapForm Toolkit (the generator).

### 16.10 Chapter Summary

| Technique | Section | Purpose |
|---|---|---|
| WapForm module architecture | 16.2, 16.6 | Expressions, tag engine, lookup, filter bar and reports are independent and can be imported separately |
| One-to-one mapping of WML tags to Dart | 16.3 | Makes the generator's output fully mechanical |
| `masterfields` → re-query the detail when the header moves | 16.4 | Declarative master-detail link expanded into parent-level event linkage |
| `<group change>` → `parseBlock`/`emitRow` | 16.5 | One grouped-report engine design spanning the Windows and Flutter runtimes |
| `<platform>` | 4.5 | Fills in features that have no Flutter tag yet with Dart code |
| The same 12 `.wml` files produce 12 `.dart` files | 16.7 | The sales-management system's concrete side-by-side comparison across the Windows and Flutter platforms |

Taken together, Chapter 14 and this chapter demonstrate the same sentence twice: **WapForm is the application's source of truth; the runtime is only the landing layer**.

---

## Appendix A　Quick Reference Card

### Card `device` Values

| `device` | Windows | Web | Window / rendering type |
|---|---|---|---|
| *(omitted)* / `wap` | ✅ | ❌ | Input form |
| `MDI` | ✅ | ❌ | MDI parent window |
| `prv` | ✅ | ❌ | Print preview |
| `prn` | ✅ | ❌ | Direct print |
| `SUB` / `sub` | ✅ | ✅ | Background run — no UI |
| `XYZ` | ✅ | ❌ | Background run with the side-effect model |
| `wapform.html` | ❌ | ✅ | Web main page card, applies the HTML template |
| `wapform-js.html` | ❌ | ✅ | Web main page card, applies the template with JS |

### Navigation

| Element | Win | Web | Action |
|---|---|---|---|
| `&lt;go href="#id"/&gt;` | ✅ | ✅ | Jumps to a card |
| `&lt;go href="@id"/&gt;` | ✅ | ✅ | Calls a function |
| `&lt;prev/&gt;` | ✅ | ❌ | Returns to the previous card |
| `&lt;exit/&gt;` | ✅ | ✅ | Leaves the current SUB or flow |
| `&lt;redirect href="url"/&gt;` | ❌ | ✅ | HTTP redirect |

### Web-Only Objects

| Expression | Description |
|---|---|
| `request.param` | An HTTP GET/POST parameter value |
| `session.var` | A server-side session variable |
| `DEFINE(request.foo)` | Checks whether a request parameter exists |
| `DEFINE(session.foo)` | Checks whether a session variable exists |

### Session Writes and Lifetime

| Form | Effect |
|---|---|
| `&lt;session name="usr" value="A"/&gt;` | Writes; follows the lifetime of the whole session |
| `&lt;session name="usr" value="A" expire="480"/&gt;` | Writes; expires automatically after 480 minutes (requires an engine version from 2026-09 or later) |
| `&lt;session name="usr" value="''"/&gt;` | Deletes (together with the expiry stamp) |
| `&lt;session name="usr" value="A" expire="0"/&gt;` | Keeps the value, clears the expiry |
| `&lt;session name="k" value="'1'" cnd="expression"/&gt;` | Writes only when the condition holds |

Common `expire` conversions: `60` = 1 hour, `480` = 8 hours, `1440` = 1 day, `10080` = 7 days, `43200` = 30 days.

| Lifetime layer | Controlled by | Default |
|---|---|---|
| Session variable | `expire` attribute | No expiry |
| Browser cookie | Server setting | Expires when the browser closes |
| Server session | Server setting | 7 days idle |

Session data lives in server memory and is lost entirely on restart. See Sections 4.11, 7.4 and 15.9.

### Dataset Methods

| `&lt;call name="ds" method="..."/&gt;` | Win | Web | Action |
|---|---|---|---|
| `first` / `last` / `next` / `prior` | ✅ | ✅ | Cursor movement |
| `locate` params=`"'field';value"` | ✅ | ✅ | Finds by key value |
| `post` / `cancel` | ✅ | ⚠️ | Save / discard |
| `refresh` | ✅ | ⚠️ | Reload from the database |
| `edit` / `insert` / `delete` | ✅ | ❌ | State switching |
| `DisableControls` / `EnableControls` | ✅ | ❌ | Freeze the UI during iteration |
| `GetBookmark` / `GoToBookmark` / `FreeBookmark` | ✅ | ❌ | Bookmark operations |

### Dataset Properties in Expressions

| Expression | Value |
|---|---|
| `ds.field_name` | The current row's field value |
| `ds.COUNT` | Total row count |
| `ds.EOF` / `ds.BOF` | Cursor-position flags |
| `ds.state` | `'BROWSE'` / `'EDIT'` / `'INSERT'` (Win) |

### Event Quick Reference (Windows-Only)

| Event | Declared On | Fires When |
|---|---|---|
| `onnewrecord` | `&lt;dbquery&gt;` / `&lt;dbtable&gt;` | A record is added |
| `beforedelete` | `&lt;dbquery&gt;` / `&lt;dbtable&gt;` | Before deletion |
| `afterpost` | `&lt;dbquery&gt;` / `&lt;dbtable&gt;` | After saving |
| `afterscroll` | `&lt;dbquery&gt;` / `&lt;dbtable&gt;` | After the cursor moves |
| `onchange` | `&lt;input&gt;` | The value changes |
| `oncloseup` | `&lt;input&gt;` with a lookup | After a lookup selection |
| `onexit` | `&lt;input&gt;` | On losing focus |
| `ondblclick` | `&lt;dbgrid&gt;` | On a row double-click |
| `oncalccellcolors` | `&lt;dbgrid&gt;` | When cells are drawn |

### Function Quick Reference

```
-- Strings (Win + Web)
STR(n)       LEN(s)       LENB(s)      MID(s,i,n)   MIDB(s,i,n)
TRIM(s)      UPPER(s)     LOWER(s)     REPLACE(s,o,n)
FIND(sub,s)  FINDB(sub,s) FORMAT(fmt,v) MD5(s)

-- Numbers (Win + Web)
ABS(n)  CEIL(n)  FLOOR(n)  ROUND(n,d)  TRUNC(n)
MAX(a,b) MIN(a,b) SQRT(n)  MOD

-- Dates (Win + Web)
DATE  NOW  YEAR(d)  MONTH(d)  DAY(d)
DATE2STR(d)  STR2DATE(s)  FormatDateTime(fmt,d)
MYDATE(d)  [Web only]

-- Logic (Win + Web)
IF(c,t,f)  ISNULL(v)  ISNUMBER(s)  NOT(b)
DEFINE(var)  [Web only]

-- Arrays (Web only)
low(arr)  high(arr)  COUNT(arr)

-- Charts (Web only)
RandomRange(min,max)
```

**📱 Flutter quick reference**

| Need | Dart |
|---|---|
| Set the engine of the current card | `useEngine(_ev, _reg)` |
| Open a query (`<dbquery id>`) | `await db.query("x", r"select ... where a='$v'")` |
| Query with parameters | `await db.query("x", "... where a=:a", params: {"a": v})` |
| SQL that returns no rows | `await db.exec(r"update ...")` |
| Set a variable or field | `setvar("TOTAL", "pa.qty*pa.price")`, `setvar("pa.icon", "'a.jpg'")` |
| Store a Dart value as is | `_ev.setVar("NAME", userInput)` |
| Evaluate / test a condition | `expression("TOTAL*1.05")`, `condition("(qty>0) AND (price<100)")` |
| Text / SQL interpolation | `expandText(r"$(pa.des)")`, `expandSql(r"where $S")`, `expandSqlAuto(r"where a=$v")` |
| Dataset methods | `invoke("pa", "first")` |
| Lookup | `WapLookupBox(dataSet:, keyField:, displayFields:, value:, onPicked:)` |
| Filter bar | `WapFilter(items: [FilterItem(...)], sqlTemplate: r"... where $R", onQuery:)` |
| Report | `WapReport` subclass + `WapPage(title:, report:, paper:, orient:)` |
| Page break | `forcePageBreak()` |
| Custom function | `_ev.addFunction1Param("TAXED", (v) => (v as num) * 1.05)` |

### Common Patterns at a Glance

```xml
<!-- Dynamic WHERE safety valve -->
<setvar name="S" value="'1=1'"/>
<setvar name="S" value="S+' AND f=`'+V+'`'" cnd="V<>''"/>
<setvar name="S" value="'f=`__NONE__`'" cnd="S='1=1'"/>

<!-- Auto-sequence on new record (Windows) -->
<onevent type="onnewrecord">
  <dbquery id="m">SELECT ISNULL(MAX(seq),0) AS n FROM t WHERE k='$k'</dbquery>
  <setvar name="tseq" value="FORMAT('%3.3d', m.n+1)"/>
</onevent>

<!-- Lookup with auto-fill (Windows) -->
<input field="code" lookup="ref;code;name" size="8">
  <onevent type="oncloseup"><setvar name="dsname" value="lupref.name"/></onevent>
  <onevent type="onexit"><setvar name="dsname" value="''" cnd="ds.code=''"/></onevent>
</input>

<!-- Total accumulator in report (Win + Web) -->
<group>
  <tr><td>$(ds.label)</td><td align="right">$(ds.amount)</td></tr>
  <setvar name="total" value="total+ds.amount"/>
</group>
<if cnd="ds.eof">
  <tr><td>Total:</td><td>$(FORMAT('%.2f',total))</td></tr>
</if>

<!-- Bookmark-safe dataset traversal (Windows) -->
<invoke instance="ds" method="GetBookmark" result="bm"/>
<invoke instance="ds" method="DisableControls"/>
<invoke instance="ds" method="First"/>
<while cnd="NOT(ds.EOF)">
  ...process...
  <invoke instance="ds" method="Next"/>
</while>
<invoke instance="ds" method="EnableControls"/>
<invoke instance="ds" method="GoToBookmark" params="bm"/>
<invoke instance="ds" method="FreeBookmark"/>

<!-- Web: session guard pattern -->
<if cnd="NOT(DEFINE(session.usr))">
  <redirect href="login.wml"/>
  <exit/>
</if>

<!-- Web: read HTTP request parameter with default -->
<setvar name="pg" value="1"/>
<setvar name="pg" value="val(request.pg)" cnd="DEFINE(request.pg)"/>
```

---

---

## Appendix B　Complete Function Reference

> This appendix fully documents the complete standard function library of the WapForm expression core (`TmyParser`), **398 functions** in total,
the most foundational layer of the WapForm language, supported in common across the Windows, Web, Flutter, and COBOL platforms.

> Calling convention: call directly by function name within a WapForm expression, with no prefix needed, e.g. `$(ABS(v1))`, `$(UPPER(name))`.

---

### Table of Contents

1. Math Operations (55)
2. Statistical Aggregation (12)
3. String Processing (86)
4. Value Conversion (55)
5. Date and Time (62)
6. Conditional and Logical (21)
7. Localization (9)
8. Random Numbers (1)
9. Encryption and Security (5)
10. System and Environment (27)
11. Path Handling (6)
12. Dynamic Variables and Arrays (14)
13. Financial Functions (8)
14. Other Built-In Functions (Covered by This Round of New Tests) (34)
15. Other Built-In Functions (Not Suited to Automated Testing) (10)

---

### B.1　Math Operations

| Function | Description | Example |
|---|---|---|
| `ABS(x)` | Absolute value | `ABS(-5)=5` |
| `ACOS(x)` | Arc cosine | `ACOS(0)=1.5708` |
| `ASIN(x)` | Arc sine | `ASIN(1)=1.5708` |
| `ATAN(x)` | Arc tangent | `ATAN(1)=0.7854` |
| `COS(x)` | Cosine | `COS(0)=1` |
| `SIN(x)` | Sine | `SIN(0)=0` |
| `TAN(x)` | Tangent | `TAN(0)=0` |
| `SQRT(x)` | Square root | `SQRT(16)=4.0` |
| `EXP(x)` | e raised to the power | `EXP(1)=2.71828` |
| `LN(x)` | Natural logarithm | `LN(2.71828)=1` |
| `LOG(x)` | Base-10 logarithm | `LOG(100)=2` |
| `POWER(x,n)` | x raised to the power n | `POWER(2,10)=1024` |
| `PI` | The constant pi | `PI=3.14159` |
| `INT(x)` | Takes the integer part (truncated toward zero) | `INT(9.8)=9` |
| `FIX(x)` | Takes the integer (rounded toward negative infinity) | `FIX(-9.8)=-10` |
| `CEIL(x)` | Rounds up | `CEIL(2.1)=3` |
| `TRUNC(x)` | Truncates the decimal portion, rounding toward zero (regardless of sign) | `TRUNC(3.9)=3` |
| `FLOOR(x)` | Rounds down | `FLOOR(2.9)=2` |
| `ROUND(x,d)` | Rounds to d decimal places (standard rounding) | `ROUND(3.456, 2)=3.46` |
| `FRAC(x)` | Takes the decimal portion | `FRAC(3.75)=0.75` |
| `MAX(a,b)` | Returns the larger of the two | `MAX(3,7)=7` |
| `MIN(a,b)` | Returns the smaller of the two | `MIN(3,7)=3` |
| `MOD(a,b)` (operator) | Remainder operator | `MOD(7,3)=1` |
| `GreatestCommonDivisor(a, b)` | Greatest common divisor (Euclidean algorithm) | `GreatestCommonDivisor(12,18)=6` |
| `ClampValue(value, lo, hi)` | Clamps the value to the range [lo, hi] | `ClampValue(15,0,10)=10` |
| `LerpValue(a, b, t)` | Linear interpolation a + (b-a)*t | `LerpValue(0,10,0.5)=5` |
| `IsBetween(value, lo, hi)` | Checks whether the value is within [lo, hi] | `IsBetween(5,1,10)=True` |
| `PercentOf(part, total)` | Percentage calculation; returns 0 when total=0 | `PercentOf(25,200)=12.5` |
| `RoundBankers(value, decimals)` | Banker's rounding (round-half-to-even) | `RoundBankers(2.5,0)=2` |
| `IsPrimeNumber(n)` | Checks whether it's a prime number | `IsPrimeNumber(7)=True` |
| `Fibonacci(n)` | The nth Fibonacci number (0-based: F(0)=0, F(1)=1) | `Fibonacci(10)=55` |
| `Log2Value(x)` | Base-2 logarithm | `Log2Value(8)=3` |
| `LogNValue(base, x)` | Logarithm to the given base | `LogNValue(3,9)=2` |
| `HypotOf(a, b)` | The hypotenuse of a right triangle, sqrt(a²+b²) | `HypotOf(3,4)=5` |
| `DegreeToRad(deg)` | Degrees → radians | `DegreeToRad(180)=3.14159` |
| `RadToDegree(rad)` | Radians → degrees | `RadToDegree(3.14159)=180` |
| `CubeRoot(x)` | Cube root | `CubeRoot(27)=3` |
| `EvenCeil(n)` | The smallest even number not less than n | `EvenCeil(3)=4` |
| `SumOfSquares(values)` | Sum of squares Σ(xᵢ²) | `SumOfSquares([1,2,3])=14` |
| `ProductOf(values)` | Product of all terms Π(xᵢ) | `ProductOf([2,3,4])=24` |
| `HarmMeanValue(values)` | Harmonic mean, n / Σ(1/xᵢ) | `HarmMeanValue([1,2,4])=1.71428571428571` |
| `GeoMeanValue(values)` | Geometric mean, (Πxᵢ)^(1/n) | `GeoMeanValue([1,3,9])=3` |
| `QuartileOf(values, q)` | Quartile; q=1 Q1, q=2 median, q=3 Q3 | `QuartileOf([1,2,3,4,5,6,7,8,2])=4.5` |
| `NetPresentValue(rate, values)` | Net present value (NPV); the first argument is the discount rate, the rest are per-period cash flows | `NetPresentValue([0.1,-1000,400,500,600])=206.953076975616` |
| `InternalRateOfReturn(values, guess)` | Internal rate of return (Newton-Raphson iteration, up to 100 iterations); the last argument is the initial guess | `InternalRateOfReturn([-1000,400,500,600,0.1])=0.216477854184290` |
| `Exp10Value(n)` | 10 raised to the power n | `Exp10Value(2)=100` |
| `Log10Value(n)` | Base-10 logarithm | `Log10Value(100)=2` |
| `RemainderValue(n, d)` | Floating-point remainder; the sign of the result matches the dividend (different semantics from MOD) | `RemainderValue(-7,3)=-1` |
| `ToIntegerValue(n)` | The greatest integer not exceeding the argument (rounds down) | `ToIntegerValue(-3.5)=-4` |
| `IntegerPart(n)` | Truncates the decimal portion (rounds toward zero) | `IntegerPart(-3.5)=-3` |
| `FractionPart(n)` | Returns the argument's decimal portion | `FractionPart(3.75)=0.75` |
| `Factorial(n)` | Factorial n! | `Factorial(5)=120` |
| `EulerNumber` | The natural constant e ≈ 2.71828… (no parameters) | `EulerNumber=2.71828` |
| `SignOf(n)` | Returns -1, 0, or 1, representing the argument's sign or zero | `SignOf(-8)=-1` |
| `Annuity(rate, periods)` | The per-period annuity present-value factor, ANNUITY(rate, periods) | `Annuity(0.05,10)=0.1295` |
| `PresentValue(rate, amounts…)` | Present-value calculation; the first argument is the discount rate, the rest are per-period amounts | `PresentValue([0.1,100,200,300])=481.592787377911` |

---

### B.2　Statistical Aggregation

| Function | Description | Example |
|---|---|---|
| `COUNT(v1, v2, …)` | Count (number of array elements) | `COUNT([1,2,3,4])=4` |
| `MeanValue(v1, v2, …)` | Arithmetic mean | `MeanValue([2,4,6])=4` |
| `MedianValue(v1, v2, …)` | Median | `MedianValue([1,3,2])=2` |
| `MidRangeValue(v1, v2, …)` | (Maximum + Minimum) / 2 | `MidRangeValue([2,10])=6` |
| `RangeValue(v1, v2, …)` | Range (Maximum − Minimum) | `RangeValue([2,10,5])=8` |
| `SumOfValues(v1, v2, …)` | Sum of all arguments | `SumOfValues([1,2,3])=6` |
| `VarianceValue(v1, v2, …)` | Variance | `VarianceValue([2,4,6])=2.6667` |
| `StandardDeviation(v1, v2, …)` | Standard deviation | `StandardDeviation([2,4,6])=1.6330` |
| `OrdMax(v1, v2, …)` | Returns the position of the maximum value in the argument list (1-based) | `OrdMax([3,7,2])=2` |
| `OrdMin(v1, v2, …)` | Returns the position of the minimum value in the argument list (1-based) | `OrdMin([3,7,2])=3` |
| `HighestAlgebraic(n)` | Returns the maximum value representable by the argument's data type (determined by its actual type), independent of the argument's own value | `HighestAlgebraic(123)=2147483647` |
| `LowestAlgebraic(n)` | Returns the minimum value representable by the argument's data type (determined by its actual type), independent of the argument's own value | `LowestAlgebraic(123)=(-2147483647-1)` |

---

### B.3　String Processing

| Function | Description | Example |
|---|---|---|
| `LEN(s)` | String length (character count) | `LEN('Hello')=5` |
| `LENA(s)` | Byte length | `LENA('中文')=6 (3 bytes per character in UTF-8)` |
| `AnsiLength(s)` | ANSI byte length | `AnsiLength('中文')=4 (2 bytes per character in Big5)` |
| `LOWER(s)` | Converts to lowercase | `LOWER('ABC')=abc` |
| `UPPER(s)` | Converts to uppercase | `UPPER('abc')=ABC` |
| `AnsiLowerCase(s)` | ANSI convert to lowercase | `AnsiLowerCase('ABC')=abc` |
| `AnsiUpperCase(s)` | ANSI convert to uppercase | `AnsiUpperCase('abc')=ABC` |
| `TRIM(s)` | Removes leading and trailing whitespace | `TRIM('  Hi  ')=Hi` |
| `LTRIM(s)` | Removes leading whitespace | `LTRIM('  Hi')=Hi` |
| `RTRIM(s)` | Removes trailing whitespace | `RTRIM('Hi  ')=Hi` |
| `MID(s,p,n)` | Extracts a substring (byte count) | `MID('Wapform', 2, 3)='apf'` |
| `MIDA(s,p,n)` | Extracts a substring (ANSI character count) | `MIDA('Hello',2,3)=ell` |
| `AnsiMid(s,p,n)` | Extracts a substring (ANSI count) | `AnsiMid('Hello',2,3)=ell` |
| `POS(sub,s)` | Finds a substring's position (byte count) | `POS('lo','Hello')=4` |
| `FINDA(sub,s)` | Finds a substring's position (ANSI count) | `FINDA('lo','Hello')=4` |
| `AnsiPos(sub,s)` | Finds a substring's position (ANSI count) | `AnsiPos('lo','Hello')=4` |
| `INSTR(s,sub)` | Finds a string's position | `INSTR('Hello','lo')=4` |
| `REPLACE(s,old,new)` | Replaces text within a string | `REPLACE('hello', 'l', 'm')='hemmo'` |
| `REPLACEA(s,old,new)` | Replaces text within a string (ANSI version) | `REPLACEA('Hello','l','L')=HeLLo` |
| `REPLACEAT(s,p,new)` | Replaces at a specified position | `REPLACEAT('Hello',1,'J')=Jello` |
| `INSERT(s,p,n,new)` | Inserts a string (byte) | `INSERT('Hllo',2,0,'e')=Hello` |
| `INSA(s,p,new)` | Inserts a string (ANSI count) | `INSA('Hllo',2,'e')=Hello` |
| `AnsiInsert(s,p,new)` | Inserts a string (ANSI count) | `AnsiInsert('Hllo',2,'e')=Hello` |
| `DELETE(s,p,n)` | Deletes a substring (byte) | `DELETE('Hello',1,1)=ello` |
| `DELA(s,p,n)` | Deletes a substring (ANSI count) | `DELA('Hello',1,1)=ello` |
| `AnsiDelete(s,p,n)` | Deletes a substring (ANSI count) | `AnsiDelete('Hello',1,1)=ello` |
| `CHR(n)` | Code point to character | `CHR(65)=A` |
| `ASC(c)` | Character to code point | `ASC('A')=65` |
| `ORD(c)` | Character's ordinal value (same as ASC) | `ORD('A')=65` |
| `CODE(s)` | Parses the "code" portion of a formatted field | `CODE('001-ABC')=001 (depends on the data format)` |
| `NAME(s)` | Parses the "name" portion of a formatted field | `NAME('001-ABC')=ABC (depends on the data format)` |
| `REPT(s,n)` | Repeats a string n times | `REPT('*', 5)='*****'` |
| `FORMAT(fmt,x)` | Formatted output | `FORMAT('0.00',3.5)=3.50` |
| `FormatDateTime(fmt,d)` | Formats a date/time according to a custom pattern string | `FormatDateTime('yyyy/mm/dd','2026-08-03')=2026/08/03` |
| `FormatFloat(fmt,n)` | Formats a floating-point number according to a custom pattern string | `FormatFloat('#,##0.00',12345.6)=12,345.60` |
| `LIKE(s,pat)` | Wildcard pattern matching | `LIKE('Hello','H*o')=True` |
| `AnsiCompareStr(a,b)` | ANSI case-sensitive comparison | `AnsiCompareStr('abc','abd')=-1` |
| `AnsiCompareText(a,b)` | ANSI case-insensitive comparison | `AnsiCompareText('ABC','abc')=0` |
| `CompareStr(a,b)` | String comparison (case-sensitive) | `CompareStr('abc','abd')=-1` |
| `CompareText(a,b)` | Locale-aware string comparison | `CompareText('ABC','abc')=0` |
| `HEX(n,d)` | Converts an integer to a hex string | `HEX(255,4)=00FF` |
| `ANSI(s)` | UTF-8 to ANSI | `ANSI('中文')=中文 (converted to Big5-encoded bytes)` |
| `UTF8(s)` | ANSI to UTF-8 | `UTF8('中文')=中文 (converted to UTF-8-encoded bytes)` |
| `HTML(s)` | HTML special-character escaping | `HTML('<b>')=&lt;b&gt;` |
| `FillChar(s,c)` | Fills with a character | `FillChar(5,'*')=*****` |
| `LeftPad2(str, len)` | Left-pads with spaces to width len | `LeftPad2('5',3)='  5'` |
| `RightPad2(str, len)` | Right-pads with spaces to width len | `RightPad2('5',3)='5  '` |
| `CenterPad(str, len)` | Center-pads with spaces to width len | `CenterPad('5',5)='  5  '` |
| `LeftPad(str, len, ch)` | Left-pads with a given character to width len | `LeftPad('5',3,'0')='005'` |
| `RightPad(str, len, ch)` | Right-pads with a given character to width len | `RightPad('5',3,'0')='500'` |
| `RepeatStr(str, n)` | Repeats a string n times | `RepeatStr('ab',3)='ababab'` |
| `CountStrOccur(substr, str)` | Counts how many times a substring occurs | `CountStrOccur('a','banana')=3` |
| `StartsWithStr(str, prefix)` | Whether the string starts with prefix | `StartsWithStr('Hello','He')=True` |
| `EndsWithStr(str, suffix)` | Whether the string ends with suffix | `EndsWithStr('Hello','lo')=True` |
| `ContainsStr2(str, substr)` | Whether the string contains a substring | `ContainsStr2('Hello','ell')=True` |
| `WrapStr(str, width)` | Inserts a line break (CRLF) every width characters | `WrapStr('HelloWorld',5)='Hello\nWorld'` |
| `SplitStr(str, delim, n)` | Splits a string by delim, takes the nth token (1-based) | `SplitStr('a,b,c',',',2)='b'` |
| `SplitCount(str, delim)` | Splits a string by delim, counts the tokens | `SplitCount('a,b,c',',')=3` |
| `JoinStr(str, delim)` | Re-joins the multiple whitespace-separated words in str (which may have runs of consecutive spaces) with delim; e.g. `JoinStr('A  B  C', ' ')` → `'A B C'` | `JoinStr('A  B  C',' ')='A B C'` |
| `TokenAt(str, delim, n)` | Takes the nth token (1-based), allows a multi-character delimiter | `TokenAt('a-b-c','-',2)='b'` |
| `EllipsisStr(str, maxLen)` | Truncates and appends '...' when longer than maxLen | `EllipsisStr('HelloWorld',5)='Hello...'` |
| `CapWords(str)` | Capitalizes the first letter of every word (English) | `CapWords('hello world')='Hello World'` |
| `CharAt(str, n)` | Takes the nth character (1-based), returns '' if out of range | `CharAt('Hello',2)='e'` |
| `IndexOfStr(substr, str, start)` | Finds a substring starting from position start (1-based) | `IndexOfStr('l','Hello',1)=3` |
| `LastIndexOfStr(substr, str)` | Finds a substring from the right, returns the last occurrence's position (1-based) | `LastIndexOfStr('l','Hello')=4` |
| `RemoveChars(str, chars)` | Removes every character in the string that also appears in chars | `RemoveChars('Hello123','0123456789')='Hello'` |
| `KeepChars(str, chars)` | Keeps only the characters in the string that also appear in chars | `KeepChars('Hello123','0123456789')='123'` |
| `OnlyDigits(str)` | Removes every non-digit character | `OnlyDigits('A1B2C3')='123'` |
| `OnlyAlpha(str)` | Removes every non-alphabetic character | `OnlyAlpha('A1B2C3')='ABC'` |
| `MaskStr(str, mask, placeholder)` | Applies a mask template character by character; positions in the mask equal to placeholder are filled in order with str's characters, other positions keep the mask's original character (e.g. phone number or ID formatting); placeholder defaults to '#' | `MaskStr('123456','##-##-##','#')='12-34-56'` |
| `UnmaskStr(str, mask, ch)` | Removes the mask, keeping only the characters at '#' positions | `UnmaskStr('12-34-56','##-##-##','#')='123456'` |
| `SlugifyStr(str)` | Converts to a URL slug (lowercase, spaces → hyphens, special characters removed) | `SlugifyStr('Hello World!')='hello-world'` |
| `TruncWords(str, n)` | Truncates to the first n words, appends '...' if truncated | `TruncWords('The quick brown fox',2)='The quick...'` |
| `CrLfToBr(str)` | Converts line breaks (CRLF/LF) to HTML <br/> | `CrLfToBr('A'+CRLF+'B')='A<br/>B'` |
| `BrToCrLf(str)` | Converts HTML <br/> / <br> to CRLF | `BrToCrLf('A<br/>B')='A'+CRLF+'B'` |
| `HtmlEncodeStr(str)` | HTML special-character encoding | `HtmlEncodeStr('<b>')='&lt;b&gt;'` |
| `HtmlDecodeStr(str)` | HTML special-character decoding | `HtmlDecodeStr('&lt;b&gt;')='<b>'` |
| `UrlEncodeStr(str)` | URL percent-encoding (ASCII range) | `UrlEncodeStr('a b')='a%20b'` |
| `ConcatenateStr(v1, v2, …)` | Concatenates multiple strings | `ConcatenateStr(['Hello',' ','World'])='Hello World'` |
| `ByteLength(n)` | The string's byte count | `ByteLength('中文')=6` |
| `StoredCharLength(n)` | The effective length after removing trailing whitespace | `StoredCharLength('Hi   ')=2` |
| `LowerCaseValue(n)` | Converts to lowercase | `LowerCaseValue('ABC')='abc'` |
| `UpperCaseValue(n)` | Converts to uppercase | `UpperCaseValue('abc')='ABC'` |
| `ReverseStr(n)` | Reverses the string | `ReverseStr('Hello')='olleH'` |
| `SubstituteStr(s, from1, to1, …)` | Replaces substrings (case-sensitive); arguments are (string, replaced-value-1, replacement-1, replaced-value-2, replacement-2, …) processed in pairs, in order | `SubstituteStr(['Hello','l','L'])='HeLLo'` |
| `SubstituteCaseStr(s, from1, to1, …)` | Replaces substrings (case-insensitive); argument format same as SUBSTITUTE | `SubstituteCaseStr(['HeLlo','l','L'])='HeLLo'` |

---

### B.4　Value Conversion

| Function | Description | Example |
|---|---|---|
| `VAL(s)` | Converts a string to a number (automatically determines integer or float based on content) | `VAL('3.14')=3.14` |
| `STR(n)` | Converts a number to a string | `STR(3.14)='3.14'` |
| `FloatToStr(n)` | Converts a float to a string | `FloatToStr(3.14)=3.14` |
| `IntToStr(n)` | Converts an integer to a string | `IntToStr(42)=42` |
| `StrToFloat(s)` | Converts a string to a float | `StrToFloat('3.14')=3.14` |
| `StrToInt(s)` | Converts a string to an integer | `StrToInt('42')=42` |
| `FLOAT(x)` | Forces conversion to a float type | `FLOAT(42)=42.0` |
| `IntToHex(n,d)` | Converts an integer to a hex string | `IntToHex(255,4)=00FF` |
| `HexToInt(s)` | Converts a hex string to an integer | `HexToInt('FF')=255` |
| `HexToStr(s)` | Converts hex encoding to a string | `HexToStr('48656C6C6F')=Hello` |
| `StrToHex(s)` | Converts a string to hex encoding | `StrToHex('Hello')=48656C6C6F` |
| `HexToColor(s)` | Converts hex to a color value | `HexToColor('FF0000')=16711680 (red)` |
| `ColorToHex(n)` | Converts a color value to hex | `ColorToHex(16711680)=FF0000` |
| `VarToStr(v)` | Converts a Variant to a string | `VarToStr(123)=123` |
| `VarArrayOf(x)` | Creates a Variant array | `VarArrayOf(1,2,3)=[1,2,3]` |
| `ZeroFill(n, width)` | Zero-pads an integer to width digits | `ZeroFill(7,3)='007'` |
| `NumberFormat(value, decimals)` | Number formatting, thousands separator + decimal places | `NumberFormat(12345.678,2)='12,345.68'` |
| `CommaFormat(value)` | Adds a thousands separator to a number (integer) | `CommaFormat(12345)='12,345'` |
| `AsStringValue(value)` | Converts a Variant to a String, returns '' for Null/Empty | `AsStringValue(123)='123'` |
| `AsInt(value)` | Converts a Variant to an integer (Trunc), returns 0 on failure | `AsInt(3.9)=3` |
| `AsFloat(value)` | Converts a Variant to an Extended, returns 0 on failure | `AsFloat('3.14')=3.14` |
| `AsBool(value)` | Converts a Variant to a boolean; Null/Empty is False, numeric types are judged by whether non-zero, strings accept '1'/'T'/'Y'/'TRUE'/'YES' (case-insensitive) as True, everything else is False | `AsBool('Y')=True` |
| `AsDate(value)` | Converts a Variant to a TDateTime (takes only the date portion, time zeroed) | `AsDate('2026-08-03 14:30:00')=2026-08-03` |
| `AsTimeValue(value)` | Converts a Variant to a TDateTime (takes only the time portion, date zeroed) | `AsTimeValue('2026-08-03 14:30:00')=14:30:00` |
| `AsDateTime(value)` | Converts a Variant to a TDateTime (date + time) | `AsDateTime('2026-08-03 14:30:00')=2026-08-03 14:30:00` |
| `AsFixed(value, decimals)` | A fixed-decimal-place string (no thousands separator) | `AsFixed(3.14159,2)='3.14'` |
| `AsCurr(value, decimals)` | A thousands-separated currency string; decimals defaults to 2 | `AsCurr(12345.6,2)='12,345.60'` |
| `AsPercent(value, decimals)` | A percentage string, e.g. '12.34%' | `AsPercent(0.1234,2)='12.34%'` |
| `AsScientific(value, decimals)` | Scientific notation, e.g. '1.23E+04' | `AsScientific(12345,2)='1.23E+04'` |
| `AsYesNo(value)` | Boolean → 'Y' / 'N' | `AsYesNo(True)='Y'` |
| `AsTrueFalse(value)` | Boolean → 'T' / 'F' | `AsTrueFalse(True)='T'` |
| `AsZeroOne(value)` | Boolean → '1' / '0' | `AsZeroOne(True)='1'` |
| `AsBit(value)` | Integer → a 1-bit boolean string (non-zero→'1', zero→'0') | `AsBit(5)='1'` |
| `AsHex(value, width)` | Integer → hex string (zero-padded to width digits) | `AsHex(255,4)='00FF'` |
| `AsOctal(value)` | Integer → octal string | `AsOctal(8)='10'` |
| `AsISO8601(datetime)` | TDateTime → ISO 8601 string 'YYYY-MM-DDTHH:MM:SS' | `AsISO8601('2026-08-03 14:30:00')='2026-08-03T14:30:00'` |
| `AsRocDate(datetime)` | TDateTime → ROC-calendar date 'YYY/MM/DD' | `AsRocDate('2026-08-03')='115/08/03'` |
| `AsRocDateTime(datetime)` | TDateTime → ROC-calendar date/time 'YYY/MM/DD HH:MM:SS' | `AsRocDateTime('2026-08-03 14:30:00')='115/08/03 14:30:00'` |
| `AsSlug(str)` | String → URL slug (lowercase, spaces→'-', special characters removed) | `AsSlug('Hello World!')='hello-world'` |
| `AsUpper(str)` | String → all uppercase | `AsUpper('abc')='ABC'` |
| `AsLower(str)` | String → all lowercase | `AsLower('ABC')='abc'` |
| `AsTrimmed(str)` | String → leading/trailing whitespace removed | `AsTrimmed('  Hi  ')='Hi'` |
| `AsQuoted(str)` | String → wrapped in single quotes (internal single quotes escaped first) | `AsQuoted("O'Brien")="'O''Brien'"` |
| `AsDQuoted(str)` | String → wrapped in double quotes (internal double quotes escaped with a backslash) | `AsDQuoted('Say "Hi"')='"Say \"Hi\""'` |
| `AsSqlStr(str)` | A SQL-safe string (escapes single quotes, no outer quotes added) | `AsSqlStr("O'Brien")="O''Brien"` |
| `AsNullable(value)` | Returns the string 'NULL' when the value is Null/Empty/blank after trimming, otherwise returns a SQL literal string wrapped in single quotes with internal single quotes escaped | `AsNullable(NULL)='NULL'` |
| `AsDefault(value, default)` | Returns default when Value is Null/Empty/blank | `AsDefault(NULL,'N/A')='N/A'` |
| `AsJson(value)` | Converts to a JSON value based on the Variant's type — booleans become true/false, numbers are output as-is, dates become ISO-format strings, Null/Empty becomes null, everything else becomes a JSON string with backslashes, double quotes, and CR/LF escaped | `AsJson('Hi')='"Hi"'` |
| `AsCsv(value1, value2, …)` | Joins multiple values with commas into one CSV row; fields containing a comma, double quote, or line break are automatically wrapped in double quotes with internal double quotes escaped | `AsCsv(['A','B,C','D'])='A,"B,C",D'` |
| `NumVal(n)` | Converts a string to a number | `NumVal('3.14')=3.14` |
| `NumValC(s, symbol)` | Converts a string containing a currency symbol and thousands-separator commas to a number; the second argument can specify the currency symbol | `NumValC('$1,234.56','$')=1234.56` |
| `NumValF(n)` | Converts a floating-point string in scientific notation (e.g. '1.5E2') to a number | `NumValF('1.5E2')=150` |
| `TestNumVal(n)` | Tests whether a string can be safely converted to a number, returns 0 if it can | `TestNumVal('3.14')=0` |
| `TestNumValC(n)` | Tests whether a string with a currency symbol can be safely converted to a number, returns 0 if it can | `TestNumValC('$1,234.56','$')=0` |
| `TestNumValF(n)` | Tests whether a floating-point string can be safely converted, returns 0 if it can | `TestNumValF('1.5E2')=0` |

---

### B.5　Date and Time

| Function | Description | Example |
|---|---|---|
| `NOW` | The current date and time (in a different format) | `NOW=2026-08-03 14:30:00` |
| `TODAY` | Today's date | `TODAY=2026-08-03` |
| `TIME` | The current time (the time portion of CURRENT_DATE) | `TIME=14:30:00` |
| `TDATE` | An alias for the system date | `TDATE=2026-08-03` |
| `yesterday` | Yesterday's date | `yesterday=2026-08-02` |
| `last-night()` | The time point corresponding to last night | `last-night()=2026-08-02 20:00:00` |
| `last-month()` | The first day of last month | `last-month()=2026-07-01` |
| `last-year()` | The first day of last year | `last-year()=2025-01-01` |
| `YEAR(d)` | Extracts the year | `YEAR('2026-08-03')=2026` |
| `MONTH(d)` | Extracts the month | `MONTH('2026-08-03')=8` |
| `DAY(d)` | Extracts the day | `DAY('2026-08-03')=3` |
| `HOUR(d)` | Extracts the hour | `HOUR('14:30:00')=14` |
| `MINUTE(d)` | Extracts the minute | `MINUTE('14:30:00')=30` |
| `SECOND(d)` | Extracts the second | `SECOND('14:30:00')=0` |
| `WEEK(d)` | Extracts the week number | `WEEK('2026-08-03')=32` |
| `DAYOFWEEK(d)` | Extracts the day of the week (uses DateUtils.DayOfTheWeek underneath, 1=Monday...7=Sunday) | `DAYOFWEEK('2026-08-03')=1 (Monday)` |
| `DAYOFYEAR(d)` | Extracts the day of the year | `DAYOFYEAR('2026-08-03')=215` |
| `DaysInAMonth(y,m)` | Gets the number of days in a given year and month | `DaysInAMonth(2024, 2)=29` |
| `IsLeapYear(y)` | Whether it's a leap year | `IsLeapYear(2024)=True` |
| `StrToDate(s)` | Converts a string to a date | `StrToDate('2026-08-03')=2026-08-03` |
| `StrToDateTime(s)` | Converts a string to a date/time | `StrToDateTime('2026-08-03 14:30:00')=2026-08-03 14:30:00` |
| `StrToTime(s)` | Converts a string to a time | `StrToTime('14:30:00')=14:30:00` |
| `DateToStr(d)` | Converts a date to a string (formatted per the system's regional settings) | `DateToStr('2026-08-03')=2026/8/3` |
| `DateTimeToStr(d)` | Converts a date/time to a string (formatted per the system's regional settings) | `DateTimeToStr('2026-08-03 14:30:00')=2026/8/3 PM 02:30:00` |
| `TimeToStr(t)` | Converts a time to a string | `TimeToStr('14:30:00')=PM 02:30:00` |
| `MyDate(d)` | Custom date formatting (ROC-calendar format) | `MyDate('2026-08-03')=115/08/03` |
| `MyDateTime(d)` | Custom date/time formatting (ROC-calendar format) | `MyDateTime('2026-08-03 14:30:00')=115/08/03 14:30:00` |
| `DateAddValue(date, n, unit)` | Adds to or subtracts from a date; unit='D'/'M'/'Y'/'W' | `DateAddValue('2026-08-03',1,'M')=2026-09-03` |
| `DateDiffValue(date1, date2, unit)` | The difference between two dates; unit='D'/'M'/'Y' | `DateDiffValue('2026-01-01','2026-08-03','D')=214` |
| `DatePeriodStart(date, unit)` | Gets the start of a period; unit='M'=start of month/'Y'=start of year/'W'=Monday | `DatePeriodStart('2026-08-03','M')=2026-08-01` |
| `DatePeriodEnd(date, unit)` | Gets the end of a period; unit='M'=end of month/'Y'=end of year | `DatePeriodEnd('2026-08-03','M')=2026-08-31` |
| `WorkDaysBetween(date1, date2)` | Counts the number of working days (excluding weekends) | `WorkDaysBetween('2026-08-01','2026-08-07')=5` |
| `QuarterOf(date)` | Gets the quarter (1–4) | `QuarterOf('2026-08-03')=3` |
| `RocDateOf(date)` | ROC-calendar date string YYYYY/MM/DD | `RocDateOf('2026-08-03')='115/08/03'` |
| `RocDateTimeOf(date)` | ROC-calendar date/time string YYY/MM/DD HH:MM:SS | `RocDateTimeOf('2026-08-03 14:30:00')='115/08/03 14:30:00'` |
| `IsWeekEnd(date)` | Whether it's a Saturday or Sunday | `IsWeekEnd('2026-08-01')=True` |
| `IsWeekDay(date)` | Whether it's a working day (Monday–Friday) | `IsWeekDay('2026-08-03')=True` |
| `NextWeekDay(date, dow)` | Finds the next occurrence of the given weekday starting from date (dow=1 Mon..7 Sun) | `NextWeekDay('2026-08-03',5)=2026-08-07 (the next Friday)` |
| `PrevWeekDay(date, dow)` | Finds the previous occurrence of the given weekday before date | `PrevWeekDay('2026-08-03',5)=2026-07-31 (the previous Friday)` |
| `EomDate(year, month)` | The last day of the given year and month | `EomDate(2026,2)=2026-02-28` |
| `BomDate(year, month)` | The first day of the given year and month | `BomDate(2026,8)=2026-08-01` |
| `AddWorkDays(date, n)` | Adds n working days (skipping weekends) | `AddWorkDays('2026-08-03',5)=2026-08-10` |
| `YearFraction(date1, date2)` | The fraction of a year between two dates (Actual/365) | `YearFraction('2026-01-01','2026-07-01')=0.4959` |
| `CalcAge(birthdate, asofdate)` | Calculates age in full years from a birth date | `CalcAge('2000-08-03','2026-08-03')=26` |
| `FiscalQuarter(date, fiscalStartMonth)` | The fiscal quarter (with a custom fiscal-year start month) | `FiscalQuarter('2026-08-03',7)=1` |
| `FiscalYear(date, fiscalStartMonth)` | The fiscal year | `FiscalYear('2026-08-03',7)=2026` |
| `DayNameOf(date)` | The Chinese name of the day of the week | `DayNameOf('2026-08-03')='星期一' (Monday)` |
| `MonthNameOf(date)` | The Chinese name of the month | `MonthNameOf('2026-08-03')='八月' (August)` |
| `DateSerialValue(y, m, d)` | Combines year, month, day into a TDateTime | `DateSerialValue(2026,8,3)=2026-08-03` |
| `TimeSerialValue(h, m, s)` | Combines hour, minute, second into a TDateTime | `TimeSerialValue(14,30,0)=14:30:00` |
| `CurrentDateValue` | The current date/time; simplified implementation: returns a human-readable system date/time string (including time-zone offset info, no parameters) | `CurrentDateValue='20260803143000'` |
| `WhenCompiled` | The program's compile time; simplified implementation: returns a time string from the same source as CURRENT_DATE (no parameters — this framework runs interpreted, so there's no real compile timestamp) | `WhenCompiled='20260803143000'` |
| `DateOfInteger(n)` | Converts a COBOL internal date integer to YYYYMMDD (the COBOL internal integer = the Delphi date serial + 109205, verified via testing) | `DateOfInteger(155442)=20260803` |
| `IntegerOfDate(n)` | Converts YYYYMMDD to a COBOL internal date integer (= the Delphi date serial + 109205, verified via testing) | `IntegerOfDate(20260803)=155442` |
| `DayOfInteger(n)` | Converts a COBOL internal date integer to YYYYDDD (Julian-day format, verified via testing) | `DayOfInteger(155442)=2026215` |
| `IntegerOfDay(n)` | Converts YYYYDDD to a COBOL internal date integer (verified via testing) | `IntegerOfDay(2026215)=155442` |
| `SecondsPastMidnight` | The number of seconds since midnight today (no parameters) | `SecondsPastMidnight=52200 (representing 14:30:00)` |
| `CombinedDateTime(date, secs)` | Combines a COBOL internal date integer and a seconds value into total seconds (= date × 86400 + secs, verified via testing; not a fractional date/time value) | `CombinedDateTime(155442,52200)=13430241000` |
| `DateToYyyymmdd(yymmdd [, pivot])` | Converts a six-digit date (YYMMDD) to an eight-digit YYYYMMDD according to a pivot year; the second argument is the pivot, defaulting to 50 if omitted or 0 (YY≤50 is treated as 20YY, otherwise 19YY) | `DateToYyyymmdd(260803,50)=20260803` |
| `YearToYyyy(yy [, pivot])` | Converts a two-digit year to a four-digit year according to a pivot year; the second argument is the pivot, defaulting to 50 if omitted or 0 | `YearToYyyy(26,50)=2026` |
| `TestDateYyyymmdd(n)` | Validates whether YYYYMMDD is a legal date (acceptable to EncodeDate); 0 = valid, 1 = invalid | `TestDateYyyymmdd(20260803)=0` |
| `TestDayYyyyddd(n)` | Validates whether YYYYDDD is a legal year-and-day (year ≥1601 and the day-of-year falls within that year's day count); 0 = valid, 1 = invalid | `TestDayYyyyddd(2026215)=0` |

---

### B.6　Conditional and Logical

| Function | Description | Example |
|---|---|---|
| `IF(cnd,t,f)` | Conditional expression: returns t if cnd is true, otherwise f (i.e. IIF) | `IF(5>3,'Yes','No')=Yes` |
| `TRUE` | The boolean true constant | `TRUE=True` |
| `FALSE` | The boolean false constant | `FALSE=False` |
| `ISNULL(x)` | Whether it's NULL | `ISNULL(NULL())=True` |
| `ISNUMBER(x)` | Whether it's a numeric type | `ISNUMBER('123')=True` |
| `ISTEXT(x)` | Whether it's a string type | `ISTEXT('abc')=True` |
| `ISEVEN(x)` | Whether it's even | `ISEVEN(4)=True` |
| `ISODD(x)` | Whether it's odd | `ISODD(3)=True` |
| `VarIsNull(x)` | Whether the Variant is Null | `VarIsNull(NULL())=True` |
| `Assigned(x)` | Whether the object has been assigned | `Assigned(obj)=True (when obj has been instantiated)` |
| `TYPE(x)` | Returns the type code (varString/varInteger/varDouble/varUString, corrected per test verification) | `TYPE(123)='varInteger'` |
| `DEFINE(name)` | Whether the identifier has been defined | `DEFINE('v1')=True (when v1 has been declared)` |
| `NvlValue(value, default)` | Returns default if value is Null (Oracle NVL) | `NvlValue(NULL,'N/A')='N/A'` |
| `Nvl2Value(value, notNullVal, nullVal)` | Oracle NVL2 | `Nvl2Value(5,'Has Value','No Value')='Has Value'` |
| `CoalesceValue(v1, v2, …)` | Returns the first non-Null value (variadic version) | `CoalesceValue([NULL,NULL,3])=3` |
| `ToIntSafe(value)` | Safely converts to an integer, returns 0 on failure | `ToIntSafe('abc')=0` |
| `ToFloatSafe(value)` | Safely converts to a float, returns 0 on failure | `ToFloatSafe('3.14')=3.14` |
| `ToDateSafe(value)` | Safely converts to a date, returns Null on failure | `ToDateSafe('2026-08-03')=2026-08-03` |
| `TypeNameOf(value)` | Returns the type name as a string | `TypeNameOf(123)='Integer'` |
| `SwitchValue(key, val1, res1, val2, res2, … [, default])` | Compares key against paired (value, result) arguments in order, returning the corresponding result on a match; if no match is found and there's one extra trailing argument, that default is returned, otherwise Null is returned (Oracle DECODE semantics) | `SwitchValue([2,1,'One',2,'Two',3,'Three'])='Two'` |
| `DecodeValue(v1, v2, …)` | Oracle DECODE semantics (equivalent to SwitchValue) | `DecodeValue([2,1,'One',2,'Two','Other'])='Two'` |

---

### B.7　Localization

| Function | Description | Example |
|---|---|---|
| `LEADBYTE(s,p)` | Determines whether it's the lead byte of a double-byte character | `LEADBYTE('中文',1)=True` |
| `LocaleDate(n)` | Simplified implementation: converts a COBOL internal date integer to a system-locale-formatted date string (specifying a locale parameter isn't supported) | `LocaleDate(155442)='2026/8/3' (an illustrative value — the actual format depends on the system's regional settings)` |
| `LocaleTime(secs)` | Simplified implementation: converts a seconds value to a system-locale-formatted time string (specifying a locale parameter isn't supported) | `LocaleTime(52200)='PM 02:30:00'` |
| `LocaleCompare(s1, s2)` | Compares strings per locale rules, returns '<', '=', or '>' (in this implementation it's ordinal comparison, same as STANDARD_COMPARE — locale sort rules are not applied) | `LocaleCompare('abc','abd')='<'` |
| `CurrencySymbol` | The current locale's currency symbol (no parameters) | `CurrencySymbol='NT$'` |
| `MonetaryDecimalPoint` | The currency decimal-point symbol (no parameters) | `MonetaryDecimalPoint='.'` |
| `MonetaryThousandsSeparator` | The currency thousands-separator symbol (no parameters) | `MonetaryThousandsSeparator=','` |
| `NumericDecimalPoint` | The numeric decimal-point symbol (no parameters) | `NumericDecimalPoint='.'` |
| `NumericThousandsSeparator` | The numeric thousands-separator symbol (no parameters) | `NumericThousandsSeparator=','` |

---

### B.8　Random Numbers

| Function | Description | Example |
|---|---|---|
| `RAND(a,b)` | Returns a random integer between a and b | `RAND(1,10)=7 (random each time it runs)` |

---

### B.9　Encryption and Security

| Function | Description | Example |
|---|---|---|
| `ENCRYPT(s,pwd)` | Encrypts a string (XOR, returns a hex string; the same s/pwd pair always produces the same, reproducible result — not randomly salted) | `ENCRYPT('AB','key')='2A27'` |
| `DECRYPT(s,pwd)` | Decrypts a string (reverses ENCRYPT's result) | `DECRYPT('2A27','key')='AB'` |
| `MD5(s)` | Computes the MD5 hash of a string | `MD5('Wapform')='A2269E58A973F7C621427BCC8BD3BBBA'` |
| `HashOf(str)` | A simple djb2 hash (32-bit unsigned integer, returns a hex string, verified via testing) | `HashOf('Wapform')='17333661'` |
| `CheckSumOf(str)` | A simple XOR checksum (returns an integer 0–255) | `CheckSumOf('AB')=3` |

---

### B.10　System and Environment

| Function | Description | Example |
|---|---|---|
| `GetUrlContent(url)` | Fetches the content of a URL | `GetUrlContent('https://example.com')=<html>...</html>` |
| `GetMacPhysicalAddress` | Gets the MAC physical address | `GetMacPhysicalAddress=00-1A-2B-3C-4D-5E` |
| `GetPhysMem` | Gets the physical memory size | `GetPhysMem=16384 (MB, depends on the actual machine)` |
| `GetFreeRes` | Gets the available resources | `GetFreeRes=8192 (depends on the actual machine)` |
| `DBX` | The multi-tier architecture flag | `DBX=True (in multi-tier architecture mode)` |
| `Beep` | System beep | `Beep= (emits a system beep, no return value)` |
| `loCaseInsensitive` | Locate option: case-insensitive | `loCaseInsensitive=1 (a locate-option flag value)` |
| `loPartialKey` | Locate option: partial key | `loPartialKey=2 (a locate-option flag value)` |
| `NBSP` | Non-breaking space | `NBSP=&nbsp;` |
| `NULL` | The Null constant | `NULL=Null` |
| `IMG(name,size)` | Image path handling | `IMG('logo.png',32)=<img src="logo.png" width="32">` |
| `NewGuidStr` | Generates a new GUID string, xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx | `NewGuidStr='550e8400-e29b-41d4-a716-446655440000'` |
| `RandomStrOf(len, chars)` | Randomly takes len characters from the character set chars to form a string; if chars is blank, defaults to uppercase/lowercase letters + digits | `RandomStrOf(6,'')='aZ3kQ9' (random each time it runs)` |
| `ToHexStr(n)` | Converts an integer to a hex string (no padding) | `ToHexStr(255)='FF'` |
| `FromHex(str)` | Converts a hex string to an integer | `FromHex('FF')=255` |
| `ToBinary(n, width)` | Converts an integer to a binary string | `ToBinary(5,8)='00000101'` |
| `FromBinary(str)` | Converts a binary string to an integer | `FromBinary('101')=5` |
| `BitOrValue(a, b)` | Bitwise OR | `BitOrValue(5,3)=7` |
| `BitAndValue(a, b)` | Bitwise AND | `BitAndValue(5,3)=1` |
| `BitXorValue(a, b)` | Bitwise XOR | `BitXorValue(5,3)=6` |
| `BitNotValue(a)` | Bitwise NOT (32-bit) | `BitNotValue(0)=-1` |
| `BitShiftLeft(a, n)` | Shifts left by n bits | `BitShiftLeft(1,4)=16` |
| `BitShiftRight(a, n)` | Shifts right by n bits | `BitShiftRight(16,4)=1` |
| `ByteSizeOf(n)` | Returns how many bytes are needed to store n bits | `ByteSizeOf(10)=2` |
| `BooleanOfInteger(n, len)` | Converts an integer to a BOOLEAN bit string; arguments are (integer value, bit width), output '0'/'1' from high bit to low bit | `BooleanOfInteger(5,8)='00000101'` |
| `IntegerOfBoolean(s)` | Converts a BOOLEAN bit string (composed of '0'/'1') to an integer | `IntegerOfBoolean('101')=5` |
| `StandardCompare(s1, s2)` | Standard string comparison (case-sensitive, ordinal comparison), returns '<', '=', or '>' | `StandardCompare('abc','abd')='<'` |

---

### B.11　Path Handling

| Function | Description | Example |
|---|---|---|
| `ExtractFileDir(s)` | Gets the directory path | `ExtractFileDir('C:\App\data.txt')=C:\App` |
| `ExtractFileDrive(s)` | Gets the drive letter | `ExtractFileDrive('C:\App\data.txt')=C:` |
| `ExtractFileExt(s)` | Gets the file extension | `ExtractFileExt('data.txt')=.txt` |
| `ExtractFileName(s)` | Gets the file name (including extension) | `ExtractFileName('C:\App\data.txt')=data.txt` |
| `ExtractFileNameNoExt(s)` | Gets the file name (without extension) | `ExtractFileNameNoExt('C:\App\data.txt')=data` |
| `ExtractFilePath(s)` | Gets the full path | `ExtractFilePath('C:\App\data.txt')=C:\App\` |

---

### B.12　Dynamic Variables and Arrays

| Function | Description | Example |
|---|---|---|
| `var(name,val)` | Dynamically sets a variable | `var('x',10)=10 (sets the variable x=10)` |
| `inc(name,val)` | Increments a variable | `inc('x',1)=11 (x's value after incrementing by 1)` |
| `dec(name,val)` | Decrements a variable | `dec('x',1)=10 (x's value after decrementing by 1)` |
| `ARRAY(s)` | Splits a string on whitespace, composing a display string resembling an array literal (description corrected to match the actual source behavior, verified via testing) | `ARRAY('a b c')='[''a'',''b'',''c'']'` |
| `HIGH(x)` | The array's upper bound | `HIGH(arr)=9 (if the array size is 10, the upper index is 9)` |
| `LOW(x)` | The array's lower bound | `LOW(arr)=0 (the array's lower index, usually 0)` |
| `ArrayJoin(values, delim)` | Joins multiple values into a string with delim; the last argument is delim | `ArrayJoin([1,2,3,','])='1,2,3'` |
| `ArrayMax(values)` | The maximum among multiple values (variadic) | `ArrayMax([3,7,2])=7` |
| `ArrayMin(values)` | The minimum among multiple values (variadic) | `ArrayMin([3,7,2])=2` |
| `ArraySum(values)` | The sum of multiple values (variadic) | `ArraySum([1,2,3])=6` |
| `ArrayAverage(values)` | The average of multiple values (variadic) | `ArrayAverage([1,2,3])=2` |
| `ArrayContains(values, target)` | Checks whether target is in values; the last argument is target | `ArrayContains([1,2,3,2])=True` |
| `ArrayUnique(values)` | Removes duplicate values, keeping the first occurrence; returns them joined with commas | `ArrayUnique([1,2,2,3])='1,2,3'` |
| `ChooseValue(index, values)` | Picks a value from a list by index (1-based); index is the first argument | `ChooseValue([2,'A','B','C'])='B'` |

---

---

---

### B.13　Financial Functions

| Function | Description | Example |
|---|---|---|
| `PaymentValue(rate, nper, pv)` | The equal payment amount per period (a loan) | `PaymentValue(0.005,360,-300000)=1798.65157545826` |
| `PresentValueOf(rate, nper, pmt)` | Present value (deriving the present value from a known equal annuity) | `PresentValueOf(0.005,360,-1798.65157545826)=300000` |
| `FutureValue(rate, nper, pmt, pv)` | Future value | `FutureValue(0.005,12,-100,0)=1233.55623728999` |
| `NumOfPeriods(rate, pmt, pv)` | The number of periods needed to pay off a loan | `NumOfPeriods(0.005,-1798.65,300000)=360` |
| `RateOf(nper, pmt, pv)` | The per-period interest rate (Newton-Raphson, up to 100 iterations) | `RateOf(360,-1798.65,300000)=0.005` |
| `InterestPmt(rate, per, nper, pv)` | The interest portion of period per | `InterestPmt(0.005,1,360,-300000)=1500` |
| `PrincipalPmt(rate, per, nper, pv)` | The principal portion of period per | `PrincipalPmt(0.005,1,360,-300000)=298.651575458257` |
| `CumInterestPmt(rate, nper, pv, startPeriod [, endPeriod])` | Computes the cumulative interest between startPeriod and endPeriod; defaults to computing through nper if the 5th argument (endPeriod) isn't supplied | `CumInterestPmt([0.005,360,-300000,1,12])=17899.78376866893` |

---

### B.14　Other Built-In Functions (Covered by This Round of New Tests)

> The functions in this section weren't previously included in Chapter 6's/the original appendix's complete examples;
they've been added here after reviewing the source code one by one and adding tests. Reviewing some of them
turned up actual bugs in the source implementation, which have been fixed as well
(see the ⚠️ notes in each row's "Description" column for details); those fixes have also been synced into `myexp.pas`.

| Function | Description | Example |
|---|---|---|
| `CHAR(n)` | Converts an integer to a character | `CHAR(65)='A'` |
| `COLOR2HEX(color)` | Converts a color value to a hex color-code string (same as ColorToHex; internally, Delphi's TColor stores as BGR) | `COLOR2HEX(255)='FF0000'` |
| `DAYOFMONTH(d)` | Extracts the "day" of a date (same as DAY) | `DAYOFMONTH('2026-08-03')=3` |
| `DEL(s,index,count)` | Deletes a substring at a given position and length | `DEL('Hello',2,3)='Ho'` |
| `DELB(s,index,count)` | Same as DEL (Byte version) | `DELB('Hello',2,3)='Ho'` |
| `FIND(substr,s)` | Finds a substring's position (1-based), returns 0 if not found | `FIND('ll','Hello')=3` |
| `FINDB(substr,s)` | Same as FIND (Byte version) | `FINDB('ll','Hello')=3` |
| `FLOAT2STR(v)` | Converts a float to a string | `FLOAT2STR(3.14)='3.14'` |
| `HEX2COLOR(hex)` | Converts a hex color-code string to a color value (same as HexToColor; internally, Delphi's TColor stores as BGR) | `HEX2COLOR('0000FF')=16711680` |
| `HEX2INT(hex)` | Converts a hex string to an integer. ⚠️ The original loop started at index 0 (not a valid character); corrected to start at 1 | `HEX2INT('FF')=255` |
| `HEX2STR(hex)` | Converts a hex string to a plain string | `HEX2STR('48656C6C6F')='Hello'` |
| `IIF(cond,t,f)` | Conditional expression (same as IF) | `IIF(1=1,'Yes','No')='Yes'` |
| `INS(substr,s,index)` | Inserts a substring at a given position in a string | `INS('XY','Hello',2)='HXYello'` |
| `INSB(substr,s,index)` | Same as INS (Byte version) | `INSB('XY','Hello',2)='HXYello'` |
| `INT2HEX(n,digits)` | Converts an integer to a hex string | `INT2HEX(255,4)='00FF'` |
| `INT2STR(n)` | Converts an integer to a string | `INT2STR(123)='123'` |
| `LENB(s)` | String length (Byte version) | `LENB('Hello')=5` |
| `LENGTH(s)` | String length | `LENGTH('Hello')=5` |
| `MIDB(s,index,count)` | Extracts a substring (Byte version, byte-counted, 1-based) | `MIDB('Hello',2,3)='ell'` |
| `NTIER` | Same as DBX (whether it's a multi-tier connection mode) | `NTIER=False` |
| `Odd(n)` | Whether it's odd | `Odd(3)=True` |
| `Ord(x)` | The ordinal value of a character or integer | `Ord(65)=65` |
| `REPLACEB(s,old,new)` | Replaces every occurrence of a substring (Byte version) | `REPLACEB('hello','l','L')='heLLo'` |
| `ROUNDTO(x,digits)` | Rounds to digits decimal places | `ROUNDTO(3.14159,2)=3.14` |
| `SQR(x)` | Square | `SQR(7)=49` |
| `STR2DATE(s)` | Converts a string to a date | `STR2DATE('2026-08-03')=46237` |
| `STR2DATETIME(s)` | Converts a string to a date/time | `STR2DATETIME('2026-08-03 14:30:00')=46237.6041666667` |
| `STR2FLOAT(s)` | Converts a string to a float | `STR2FLOAT('3.14')=3.14` |
| `STR2HEX(s)` | Converts a plain string to a hex string | `STR2HEX('Hello')='48656C6C6F'` |
| `STR2INT(s)` | Converts a string to an integer | `STR2INT('123')=123` |
| `STR2TIME(s)` | Converts a string to a time | `STR2TIME('14:30:00')=0.604166666666667` |
| `UPPERA(s)` | Converts to uppercase (Ansi version) | `UPPERA('abc')='ABC'` |
| `VALUE(s)` | Same as VAL | `VALUE('3.14')=3.14` |
| `VARTYPE(v)` | Returns the type name as a string (same as TYPE) | `VARTYPE(123)='varInteger'` |

---

### B.15　Other Built-In Functions (Not Suitable for Automated Tests)

> The following functions exist in `myexp.pas` and can be called normally, but for the reasons listed
(random, dependent on system/network state, dependent on the current time, locale-dependent formats, unclear semantics, etc.)
they are not suitable for automated tests with fixed expected values, and are therefore not included in `function.wml`.

| Function | Description | Why it is not tested |
|---|---|---|
| `CPU` | (no matching registration/use found in the source) | The function produces no meaningful return value (system sound / internal utility), not suitable for an equality test |
| `DATE` | Current date (no parameters, changes with the run date) | The result depends on the system date/time at run time, not a fixed value, so no expected value can be written |
| `DATE2STR(d)` | Date to string | The output format depends on the system locale and is not guaranteed to be the same in different environments, so it is not included in exact-match tests |
| `DATETIME2STR(d)` | Date-time to string | The output format depends on the system locale and is not guaranteed to be the same in different environments, so it is not included in exact-match tests |
| `RANDOM(lo,hi)` | Random integer in [lo,hi) | Random function; no fixed expected value to compare |
| `RANDOMRANGE(lo,hi)` | Random integer in [lo,hi) | Random function; no fixed expected value to compare |
| `RANDRANGE(lo,hi)` | Random integer in [lo,hi) | Random function; no fixed expected value to compare |
| `TIME2STR(t)` | Time to string | The output format depends on the system locale and is not guaranteed to be the same in different environments, so it is not included in exact-match tests |
| `getpropstr(a,b)` | (unigui-related internal function, semantics not public) | Internal function of the unigui platform whose semantics are not public; not tested for now |
| `setpropstr(a,b,c)` | (unigui-related internal function, semantics not public) | Internal function of the unigui platform whose semantics are not public; not tested for now |

---

## Appendix C　Flutter Expression Engine Differences

In WapForm for Flutter, expressions are evaluated by `wapform_expression.dart` (`WapEvaluator`). Function names are the same as in Appendix B, with the differences below; every result in this appendix was produced by actually running the Dart engine.

### C.1　Syntax and Types

| Item | Windows/Web | Flutter |
|---|---|---|
| Comparisons on both sides of `AND`/`OR` | Parentheses optional | **Parentheses required**: `(qty>0) AND (price<100)`; without them `Invalid end token` is reported |
| Numeric arithmetic | Variant | `+`, `-`, `*` between two integers give an integer; everything else (including `/`) gives a floating-point number |
| Array index | As declared | Always from 0; `[1..n]` creates n+1 elements and `LOW()` is 0 |
| Writing past an array's upper bound | Error | Extends automatically (padded with `null`) |
| `$` in strings | — | In Dart code write raw strings `r"..."`, otherwise Dart interpolates `$` first |
| `$(PAGE)` | Set automatically by the report engine | Set it yourself in `PAGEPREFIX` (Section 7.6) |
| `request.*`/`session.*` | Web environment objects | Do not exist; when needed, put them in yourself with `_ev.setVar("request.xxx", value)` |

### C.2　Functions That Return a Date Serial Number

In Flutter the following functions return "the number of days since 1899-12-30" (the fractional part is the time). The value can be compared or subtracted, but currently cannot be turned back into text with `DateToStr()` or `FORMATDATETIME()`. When you need date text, use functions that return dates, such as `DATEADD`, `DATESTART`, `DATEEND`, `DATESERIAL` and `TODAY`.

| Function | Example | Flutter result |
|---|---|---|
| `StrToDate(s)` | `StrToDate('2026-08-03')` | `46237.0` |
| `StrToDateTime(s)` | `StrToDateTime('2026-08-03 14:30:00')` | `46237.604166666664` |
| `StrToTime(s)` | `StrToTime('14:30:00')` | `0.6041666666666666` |
| `DateAddValue(date, n, unit)` | `DateAddValue('2026-08-03',1,'M')` | `46268.0` |
| `DatePeriodStart(date, unit)` | `DatePeriodStart('2026-08-03','M')` | `46235.0` |
| `DatePeriodEnd(date, unit)` | `DatePeriodEnd('2026-08-03','M')` | `46265.0` |
| `NextWeekDay(date, dow)` | `NextWeekDay('2026-08-03',5)` | `46241.0` |
| `PrevWeekDay(date, dow)` | `PrevWeekDay('2026-08-03',5)` | `46234.0` |
| `EomDate(year, month)` | `EomDate(2026,2)` | `46081.0` |
| `BomDate(year, month)` | `BomDate(2026,8)` | `46235.0` |
| `AddWorkDays(date, n)` | `AddWorkDays('2026-08-03',5)` | `46244.0` |
| `DateSerialValue(y, m, d)` | `DateSerialValue(2026,8,3)` | `46237.0` |
| `TimeSerialValue(h, m, s)` | `TimeSerialValue(14,30,0)` | `0.6041666666666666` |

### C.3　Functions Whose Results Differ from the Windows Version

The following functions can be called, but their results differ from the Windows version in Appendix B; test before using them:

| Function | Appendix B example (Windows) | Flutter result |
|---|---|---|
| `LENA(s)` | `LENA('中文')=6 (3 bytes per character in UTF-8)` | `2` |
| `AnsiLength(s)` | `AnsiLength('中文')=4 (2 bytes per character in Big5)` | `2` |
| `REPLACEAT(s,p,new)` | `REPLACEAT('Hello',1,'J')=Jello` | `Hello` |
| `INSERT(s,p,n,new)` | `INSERT('Hllo',2,0,'e')=Hello` | `ERROR` |
| `INSA(s,p,new)` | `INSA('Hllo',2,'e')=Hello` | `Hllo2` |
| `AnsiInsert(s,p,new)` | `AnsiInsert('Hllo',2,'e')=Hello` | `Hllo2` |
| `CODE(s)` | `CODE('001-ABC')=001 (depends on the data format)` | `(empty string)` |
| `NAME(s)` | `NAME('001-ABC')=ABC (depends on the data format)` | `(empty string)` |
| `FORMAT(fmt,x)` | `FORMAT('0.00',3.5)=3.50` | `0.00` |
| `LIKE(s,pat)` | `LIKE('Hello','H*o')=True` | `H` |
| `ANSI(s)` | `ANSI('中文')=中文 (converted to Big5-encoded bytes)` | `中文` |
| `UTF8(s)` | `UTF8('中文')=中文 (converted to UTF-8-encoded bytes)` | `中文` |
| `HTML(s)` | `HTML('<b>')=&lt;b&gt;` | `<b><br/>` |
| `EllipsisStr(str, maxLen)` | `EllipsisStr('HelloWorld',5)='Hello...'` | `He...` |
| `HexToColor(s)` | `HexToColor('FF0000')=16711680 (red)` | `255` |
| `ColorToHex(n)` | `ColorToHex(16711680)=FF0000` | `0000FF` |
| `HOUR(d)` | `HOUR('14:30:00')=14` | `0` |
| `MINUTE(d)` | `MINUTE('14:30:00')=30` | `0` |
| `TimeToStr(t)` | `TimeToStr('14:30:00')=下午 02:30:00 (2:30:00 PM in the Chinese locale)` | `(empty string)` |
| `MyDate(d)` | `MyDate('2026-08-03')=115/08/03` | `2026-08-03` |
| `MyDateTime(d)` | `MyDateTime('2026-08-03 14:30:00')=115/08/03 14:30:00` | `2026-08-03 14:30:00` |
| `ISNULL(x)` | `ISNULL(NULL())=True` | `ERROR` |
| `VarIsNull(x)` | `VarIsNull(NULL())=True` | `ERROR` |
| `LEADBYTE(s,p)` | `LEADBYTE('中文',1)=True` | `false` |
| `IMG(name,size)` | `IMG('logo.png',32)=<img src="logo.png" width="32">` | `ERROR` |

### C.4　Functions Not Supported in Flutter

In Flutter the following functions only return a notice string:

- `GetUrlContent(url)`
- `GetMacPhysicalAddress`
- `GetPhysMem`
- `GetFreeRes`

To fetch web content, use Dart's `http` package; for local hardware information, use the Flutter package for that platform.

### C.5　Additional Functions Provided by Flutter

The following functions are registered only in the Dart engine and can be called in `eval()`, `setvar()` and `$(...)`. The "Params" column is the number of parameters.

| Function | Params | Description |
|---|---|---|
| `AGE` | 2 | Full years of age from a birth date to a given date |
| `ArcCos` | 1 | Arc cosine (same as ACOS) |
| `ArcSin` | 1 | Arc sine (same as ASIN) |
| `ArcTan` | 1 | Arc tangent (same as ATAN) |
| `ARRAVG` | variadic | Average of several values |
| `ARRCONTAINS` | variadic | Whether the last argument appears among the preceding values |
| `ARRJOIN` | variadic | Joins the preceding values using the last argument as separator |
| `ARRMAX` | variadic | Maximum of several values |
| `ARRMIN` | variadic | Minimum of several values |
| `ARRSUM` | variadic | Sum of several values |
| `ARRUNIQ` | variadic | Removes duplicates and returns the values joined with commas |
| `As10` | 1 | Boolean → '1'/'0' |
| `AsISO` | 1 | ISO 8601 date string |
| `AsOct` | 1 | Integer → octal string |
| `AsPct` | 2 | Percentage string (d decimal places) |
| `AsRDate` | 1 | ROC (Minguo) calendar date string |
| `AsRDateTime` | 1 | ROC (Minguo) calendar date-time string |
| `AsSci` | 2 | Scientific notation string (e.g. 1.23E+04) |
| `AsString` | 1 | Any value → string |
| `AsTF` | 1 | Boolean → 'T'/'F' |
| `AsTime` | 1 | Any value → time |
| `AsYN` | 1 | Boolean → 'Y'/'N' |
| `BDATE` | 1 | Date conversion (for compatibility) |
| `BETWEEN` | 3 | Whether a value lies within [lo, hi] |
| `BITAND` | 2 | Bitwise AND |
| `BITNOT` | 1 | Bitwise NOT |
| `BITOR` | 2 | Bitwise OR |
| `BITSHL` | 2 | Shift left n bits |
| `BITSHR` | 2 | Shift right n bits |
| `BITXOR` | 2 | Bitwise XOR |
| `BOOLEAN_OF_INTEGER` | 2 | Integer → bit string |
| `BR2CRLF` | 1 | <br/> → line break |
| `BYTESIZE` | 1 | Number of bytes needed to hold n bits |
| `BYTE_LENGTH` | 1 | Byte length of a string |
| `CBRT` | 1 | Cube root |
| `CELL` | 2 | Crosstab cell value (for compatibility) |
| `CHECKSUM` | 1 | XOR checksum |
| `CHOOSE` | variadic | Picks a value from a list by index (1-based) |
| `CLAMP` | 3 | Limits a value to [lo, hi] |
| `COALESCE` | variadic | Returns the first non-Null value |
| `COMBINED_DATETIME` | 2 | Combines a date integer and seconds into a date-time |
| `COMMAFMT` | 1 | Adds thousands separators to an integer |
| `CONCATENATE` | variadic | Concatenates all arguments |
| `CONTAINS` | 2 | Whether a string contains a substring |
| `COPY` | 3 | Substring (same as Pascal Copy) |
| `COPYB` | 3 | Substring by bytes |
| `COUNTSTR` | 2 | Number of occurrences of a substring |
| `CRLF2BR` | 1 | Line break → <br/> |
| `CUMIPMT` | variadic | Cumulative interest (periods start–end) |
| `CURRENCY_SYMBOL` | 0 | Currency symbol |
| `CURRENT_DATE` | 0 | Current timestamp string yyyyMMddHHmmsscc+HHmm |
| `DATEADD` | 3 | Adds to a date (unit: 'D'/'M'/'Y'/'W') |
| `DATEDIFF` | 3 | Difference between two dates (by unit) |
| `DATEEND` | 2 | End of period (unit: 'M' end of month/'Y' end of year) |
| `DATESERIAL` | 3 | Builds a date from year, month, day |
| `DATESTART` | 2 | Start of period (unit: 'M' start of month/'Y' start of year/'W' Monday) |
| `DATE_OF_INTEGER` | 1 | Date integer → YYYYMMDD |
| `DATE_TO_YYYYMMDD` | 2 | YYMMDD → YYYYMMDD using a pivot year |
| `DAYNAME` | 1 | Weekday name (Chinese) |
| `DAY_OF_INTEGER` | 1 | Date integer → YYYYDDD |
| `DECODE` | variadic | Like Oracle DECODE: returns the result matched by value; the last one is the default |
| `DEG2RAD` | 1 | Degrees → radians |
| `E` | 0 | The constant e |
| `ELLIPSIS` | 2 | Truncates and appends '...' |
| `ENDSWITH` | 2 | Whether a string ends with a given suffix |
| `EVEN` | 1 | Smallest even number greater than or equal to n |
| `EXP10` | 1 | 10 to the power x |
| `FIB` | 1 | The nth Fibonacci number (from 0) |
| `FRACTION_PART` | 1 | Fractional part |
| `FROMBIN` | 1 | Binary string → integer |
| `FV` | 4 | Future value |
| `GCD` | 2 | Greatest common divisor |
| `GEOMEAN` | variadic | Geometric mean |
| `GUID` | 0 | Creates a new GUID string |
| `HARMEAN` | variadic | Harmonic mean |
| `HASH` | 1 | Simple djb2 hash (32-bit, hex string) |
| `HIGHEST_ALGEBRAIC` | 1 | Maximum value of the type |
| `HTMLDECODE` | 1 | Decodes HTML special characters |
| `HTMLENCODE` | 1 | Encodes HTML special characters |
| `HYPOT` | 2 | Hypotenuse sqrt(a²+b²) |
| `INDEXOF` | 3 | Position of a substring, searching from start (1-based) |
| `INTEGER` | 1 | Rounds down (floor) |
| `INTEGER_OF_BOOLEAN` | 1 | Bit string → integer |
| `INTEGER_OF_DATE` | 1 | YYYYMMDD → date integer |
| `INTEGER_OF_DAY` | 1 | YYYYDDD → date integer |
| `INTEGER_PART` | 1 | Truncates toward zero |
| `IPMT` | 4 | Interest part of the nth payment |
| `IRR` | variadic | Internal rate of return (Newton's method) |
| `ISPRIME` | 1 | Whether a number is prime |
| `JOIN` | 2 | Joins with a separator after removing extra spaces |
| `last-month` | 0 | The same day last month |
| `last-night` | 0 | Yesterday |
| `last-week` | 0 | The same day last week |
| `last-year` | 0 | The same day last year |
| `LASTINDEXOF` | 2 | Position of a substring searching from the right (1-based) |
| `LCM` | 2 | Least common multiple |
| `LEADBYTEB` | 2 | Whether a byte is the lead byte of a double-byte character |
| `LERP` | 3 | Linear interpolation a + (b-a)*t |
| `LOCALE_COMPARE` | 2 | Locale-aware comparison, returns '<', '=', '>' |
| `LOCALE_DATE` | 1 | Formats a date by locale |
| `LOCALE_TIME` | 1 | Formats a time by locale |
| `LOCATE` | 2 | Position of a substring |
| `LOG10` | 1 | Base-10 logarithm |
| `LOG2` | 1 | Base-2 logarithm |
| `LOGN` | 2 | Logarithm to a given base |
| `LOWERA` | 1 | Converts to lowercase |
| `LOWER_CASE` | 1 | Converts to lowercase |
| `LOWEST_ALGEBRAIC` | 1 | Minimum value of the type |
| `LPAD` | 3 | Left-pads to width len with a given character |
| `MASK` | 3 | Formats by a mask (placeholder character defaults to '#') |
| `MEAN` | variadic | Mean |
| `MEDIAN` | variadic | Median |
| `MIDRANGE` | variadic | Average of the maximum and minimum |
| `MOD` | 2 | Remainder (sign follows the divisor) |
| `MONETARY_DECIMAL_POINT` | 0 | Monetary decimal point symbol |
| `MONETARY_THOUSANDS_SEPARATOR` | 0 | Monetary thousands separator |
| `MONTHNAME` | 1 | Month name (Chinese) |
| `NEXTWDAY` | 2 | Next given weekday after a date (1 = Monday … 7 = Sunday) |
| `NPER` | 3 | Number of payment periods |
| `NPV` | variadic | Net present value |
| `NUMERIC_DECIMAL_POINT` | 0 | Numeric decimal point symbol |
| `NUMERIC_THOUSANDS_SEPARATOR` | 0 | Numeric thousands separator |
| `NUMFMT` | 2 | Number formatting: thousands separators plus decimal places |
| `NUMVAL_C` | 2 | String with a currency symbol → number |
| `NUMVAL_F` | 1 | Floating-point string → number |
| `NVL` | 2 | Returns a default when the value is Null |
| `NVL2` | 3 | Like Oracle NVL2: different values for non-Null and Null |
| `ORD_MAX` | variadic | Position of the maximum (1-based) |
| `ORD_MIN` | variadic | Position of the minimum (1-based) |
| `PADC` | 2 | Centers with spaces to width len |
| `PADL` | 2 | Left-pads with spaces to width len |
| `PADR` | 2 | Right-pads with spaces to width len |
| `PERCENT` | 2 | Percentage calculation |
| `PMT` | 3 | Equal payment per period |
| `PPMT` | 4 | Principal part of the nth payment |
| `PRESENT_VALUE` | variadic | Present value of amounts per period |
| `PREVWDAY` | 2 | Previous given weekday before a date |
| `PRODUCT` | variadic | Product of all values |
| `PV` | 3 | Present value |
| `QUARTER` | 1 | Quarter (1–4) |
| `QUARTILE` | variadic | Quartile (q = 1, 2, 3) |
| `RAD2DEG` | 1 | Radians → degrees |
| `RANDOMSTR` | 2 | Random string of a given length |
| `RANGE` | variadic | Difference between the maximum and minimum |
| `RATE` | 3 | Interest rate per period (Newton approximation) |
| `RDATE` | 1 | ROC calendar date string YYY/MM/DD |
| `RDATETIME` | 1 | ROC calendar date-time string YYY/MM/DD HH:MM:SS |
| `REM` | 2 | Remainder (sign follows the dividend) |
| `REPEAT` | 2 | Repeats a string n times |
| `REVERSE` | 1 | Reverses a string |
| `ROUNDBANK` | 2 | Banker's rounding (round half to even) |
| `RPAD` | 3 | Right-pads to width len with a given character |
| `SECONDS_PAST_MIDNIGHT` | 0 | Seconds elapsed today |
| `SIGN` | 1 | Sign (-1, 0, 1) |
| `SLUGIFY` | 1 | Converts to a URL slug |
| `SPLIT` | 3 | Splits by a separator and takes the nth part (1-based) |
| `STANDARD_COMPARE` | 2 | Standard comparison, returns '<', '=', '>' |
| `STANDARD_DEVIATION` | variadic | Standard deviation |
| `STARTSWITH` | 2 | Whether a string starts with a given prefix |
| `STORED_CHAR_LENGTH` | 1 | Length after removing trailing spaces |
| `SUBSTITUTE` | variadic | Replaces strings by argument pairs, in order |
| `SUBSTITUTE_CASE` | variadic | Replaces by argument pairs (case-insensitive) |
| `SUM` | variadic | Sum |
| `SUMSQ` | variadic | Sum of squares |
| `SWITCH` | variadic | Returns the result matched by value; the last one is the default |
| `TEST_DATE_YYYYMMDD` | 1 | Checks whether YYYYMMDD is valid (0 = valid) |
| `TEST_DAY_YYYYDDD` | 1 | Checks whether YYYYDDD is valid (0 = valid) |
| `TEST_NUMVAL` | 1 | Checks whether a string converts to a number (0 = yes) |
| `TEST_NUMVAL_C` | 2 | Checks whether a string with a currency symbol converts to a number |
| `TEST_NUMVAL_F` | 1 | Checks whether a floating-point string converts to a number |
| `TIMESERIAL` | 3 | Builds a time from hours, minutes, seconds |
| `TOBIN` | 2 | Integer → binary string (width bits) |
| `TODATE` | 1 | Safe conversion to a date |
| `TOFLOAT` | 1 | Safe conversion to a float |
| `TOHEX` | 1 | Integer → hex string |
| `TOINT` | 1 | Safe conversion to an integer |
| `TrimLeft` | 1 | Removes leading spaces |
| `TrimRight` | 1 | Removes trailing spaces |
| `TYPENAME` | 1 | Type name of a value |
| `UNMASK` | 3 | Removes a mask, keeping only characters at placeholder positions |
| `UPPER_CASE` | 1 | Converts to uppercase |
| `URLENCODE` | 1 | URL percent-encoding |
| `VARIANCE` | variadic | Variance |
| `WHEN_COMPILED` | 0 | Same as CURRENT_DATE |
| `WORKDAYS` | 2 | Working days between two dates (excluding Saturday and Sunday) |
| `WRAP` | 2 | Inserts a line break every width characters |
| `YEARFRAC` | 2 | Fraction of a year between two dates (Actual/365) |
| `YEAR_TO_YYYY` | 2 | Two-digit year → four digits using a pivot year |
| `ZFILL` | 2 | Left-pads an integer with zeros to width digits |

## Index

**alert** — 4-1, 6-2
**block** — 4-11 (Web), 7-2, 7-3
**bookmark pattern** — 4-14, A
**card** — 1-1, 2-1, 4-2
**CDATA** — 4-5
**chart** — 4-12 (Web)
**datasource** — 1-2, 3-1, 4-4
**dbgrid** — 4-6
**dbquery** — 4-3
**dbtable** — 4-4
**DEFINE function** — 1-4, 5-9 (Web)
**device attribute** — 2-1, 4-2, A
**dynamic WHERE** — 3-3, 3-7, A
**expression system** — 1-4, 5-1
**for loop** — 4-12 (Web)
**function** — 4-12, 6-2
**go** — 4-12
**group / group change** — 4-16, 5-3
**if / elseif / else** — 4-13
**include** — 4-11 (Web), 7-2
**input** — 4-9
**invoke** — 4-14
**lookup attribute** — 3-4, 4-10
**mail** — 4-12 (Web), 7-5
**navigator** — 4-5
**nowap / wap** — 4-12 (Web)
**oncalccellcolors** — 4-7, 6-4
**ondblclick** — 4-8, 6-4
**onevent** — 1-5, 4-8
**onnewrecord** — 4-8, A
**operator** — 4-10 (Web), 7-4
**page** — 4-16
**pagecontrol** — 4-11
**platform** — 4.5, 12.3, 16
**redirect** — 4-11 (Web), 3-8, 7-3
**report** — 4-16
**request.*** — 1-4, 5-4 (Web)
**section** — 4-11 (Web)
**select** — 4-11
**session** — 4-11 (Web), 3-8, 7-3
**setprop** — 4-13, 6-3
**setvar** — 4-13
**SUB card** — 3-6, 4-2
**switch** — 4-13
**tabsheet** — 4-11
**timer** — 4-12 (Web)
**varblock** — 4-11 (Web)
**while** — 4-14
**wml** — 2-1, 4-2

---

WapForm Complete Technical Manual  
by Neil Tsai  
Copyright © 2026 Minhong Information Co., Ltd. All rights reserved.
