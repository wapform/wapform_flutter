# WapForm 完全技術マニュアル

---

WapForm はエンタープライズアプリケーションのための宣言型 XML フレームワークです。1 つの `.wml` ファイルがデータベースを駆動し、画面を描画し、レポートを出力します。実行時に Windows デスクトップアプリ、Web ページ、Flutter App を直接生成し、COBOL プログラムとしてエクスポートすることもでき、その適用範囲は IC 電子設計自動化（EDA）とローカル AI エージェント Cherith にまで広がります。ボイラープレートコードはなく、フレームワークの入れ替えもなく、プラットフォームを変えても書き直しは不要——この設計パターンは製造業 ERP、金融システム、EC プラットフォームの本番環境で 20 年以上の実績があります。

**WapForm の主張はただ一つ：「どうやるか」ではなく「何であるか」を記述する。** 開発者は XML でデータセットを宣言し、フィールドをバインドし、イベントと出力形式を定義します。データベースの駆動、画面の描画、改ページと集計はフレームワークが担当します。同じ `.wml` ファイルが入力フォームであると同時に改ページ付きレポートにもなり、言語を切り替える必要も、UI フレームワークとデータ層の間に橋を架ける必要もありません。宣言型の力は、業務ルールが変わったときに記述だけを直せば、残りはフレームワークが導き出すところにあります。

### 4 つのコアな強み

**速く、さらに速く** — 公式事例では、多階層にネストした生産レポート（多次元グループ化、自動改ページ付き）が、従来の命令型コードでは数か月の開発と見積もられていたところ、WapForm では数日で構築・稼働し、コードは数千行・複数ファイルにまたがるロジックから数百行の WML 宣言 1 本に収束しました。問題が少ないのではなく、修正が速いのでテストが怖くなくなるのです。

**素早くプラットフォームを越え、素早く領域を越える** — 宣言型の文法を一度身につければ、同じ考え方で Windows デスクトップ、Web サーバーサイド、Flutter モバイル、さらには IC 電子設計自動化（EDA）や COBOL メインフレームまでカバーできます。WapForm は特定プラットフォームのツールではなく、あらゆる領域を越えられる**開発設計パターン（Design Pattern）**です。

**革新的なテンプレート機構** — トリガー式テンプレートシステムを内蔵し、HTML テンプレートがレイアウトを主導し、プログラムはコンテンツブロックを宣言するだけ。レポート適用ロジックはメインプログラムから完全に分離され、直感的でスムーズな開発体験をもたらします。

**盤石の堅牢さ** — モジュール化されたアーキテクチャと厳密なデータロジック検証により、エンタープライズアプリケーションの安定性と拡張性を確保します。実際の製造業 ERP、EC プラットフォーム、金融システムで 20 年にわたり検証されてきました。

### WapForm の本当の姿：一度定義し、何度でも展開する

データソース、フィールド、ルックアップ、イベント、フォーム、レポートはすべて WML で記述され、Dart や Flutter その他の特定言語に直接縛られることはありません。したがって：

> **WapForm はアプリケーションの Source of Truth です。**

ジェネレーターはこの定義をターゲットプラットフォームのコードへ展開し、Runtime とコンポーネントライブラリはプログラムが実際に動く「着地層」を提供します。

### AI の価値は、自由にコードを生成することではない

既存のデスクトップ用データベースコンポーネントライブラリのソースを LLM に渡し、ファイルごとに Dart への翻訳を頼むだけでは、大量のコードは生成できても、大規模システムの移植を確実にやり遂げられるわけではありません。

本当に難しいのは、動作の一貫性、API の対応付け、データモデル、イベントモデル、そして長期的な保守です。

WapForm が採るのは別のアプローチです：

**WML Definition → Generator → Stable Runtime/API → Target Code**

AI に求めるのは自由に「App を 1 本書く」ことではなく、明確に定義された WML と安定したターゲット API の上で、大量・機械的・再現可能なコード展開を行うことです。

今回の WapForm for Flutter の移植は、約 2 か月の AI 支援開発で完了しました。同規模の手作業による移植で当初見積もられていた 6～12 か月と比べ、本当の差は AI がコードを速く書くことだけではなく、次の点にあります：

> **まず定義を作り、その定義に従って AI に生成させる。**

つまり Flutter の 2 か月は単なる AI 開発スピードのデモではなく、「定義 → 生成 → Runtime → 実行」というエンジニアリング手法の実地検証なのです。

### Flutter の場合：コンポーネントの移植ではなく、アプリケーション定義の最初の検証

クロスプラットフォームが最大のコストだったことはありません。本当に高くつくのは、プラットフォームを変えるたびに作り直さなければならないことです。

デスクトップのデータ認識コンポーネントを Flutter に完全移植し、おなじみのデータセット、グリッド、ナビゲーターバー、フィールド、イベントモデルを手に入れたとしても、開発者は依然として Dart で画面を作り、データをバインドし、イベントとビジネスロジックを書かなければなりません。本質的には、別のプラットフォームでプログラムを丸ごと書き直していることに変わりありません。

WapForm が解決するのはコンポーネントではなく、アプリケーションの定義方法です。

WML はプレーンテキストの宣言型アプリケーション定義言語です。データソース、フィールド、ルックアップ、イベント、フォーム、レポートはすべて「記述」として定義され、Dart や Flutter、あるいは特定のプラットフォームに縛られません。そのため、実際の開発フローは次のようになります：

> **一度定義し、何度でも展開する。**

WML は唯一のアプリケーション定義であり、Generator がそれをターゲットプラットフォームのコードへ展開し、Runtime がプログラムの実行に必要なコンポーネントと動作モデルを提供します。Flutter を例に取ると、`wapform_flutter` リポジトリが Flutter の Runtime です——それは別の Flutter UI フレームワークではなく、WapForm のデータセット・式・レポートモデルを Flutter 上で実装したものです。WapForm ジェネレーターが生成する Dart の 1 行 1 行はこの API を対象としているため、もともと Windows で動いていた同じ WML を、定義を変えずにそのまま Flutter へ展開できます。「WML を 10 行書けば、動く Flutter 画面が手に入る」理由もここにあります。本当に再利用されているのはコードではなく、アプリケーションそのものの定義だからです（詳しくは第 16 章）。

### Web の場合：トリガー式テンプレートで、レイアウトとロジックを完全に分離

従来の PHP／ASP は条件判断を HTML の中に直接書くため、プログラムがレイアウトの細部を知りすぎています。ブロックを 1 つ変えるにもプログラムに手を入れる必要があり、デザイナーは単独でレイアウトを変えられず、システムが大きくなるほど保守コストが爆発します。

WapForm for Web の中核は**トリガー式テンプレート**です。プログラムは HTML を書かず、「どの条件で、どのレイアウトブロックをトリガーするか」だけを宣言します。HTML はすべてテンプレートファイルに置き、`<!-- 名前.aa -->`／`<!-- 名前.zz -->` で名前付きブロックを区切ります。

```xml
<card id="main" device="wapform.html">          <!-- device でテンプレートファイルを指定 -->
  <setvar name="op" value="request.op"/>
  <block name="wapform.aa"/>                     <!-- トリガー：外枠の先頭を出力 -->
  <include name="header"/>                       <!-- 共通ヘッダー、サイト全体で 1 つ -->
  <block name="onpage" cnd="op='page'"/>         <!-- 条件に応じて別のレイアウトをトリガー -->
  <block name="onblog" cnd="op='blog'"/>
  <include name="footer"/>
  <block name="wapform.zz"/>                     <!-- トリガー：外枠の末尾を出力 -->
</card>
```

```html
<!-- onpage.aa -->
#(breadcrumb)                                     <!-- breadcrumb サブカードをその場で実行 -->
<div class="content">#(content)</div>             <!-- content サブカードをその場で実行 -->
<!-- onpage.zz -->
```

トリガー式テンプレートの要点：

- **条件でレイアウトをトリガー**：`cnd` が成立したブロックだけが出力され、レイアウトは自動で切り替わるので if／else は不要です。1 組の条件で複数の出力ブロックを駆動できます。
- **`aa`／`zz` のペアでコンテナを開閉**：外枠とコンポーネントを再利用可能な積み木に分け、入れ子で適用します。保守はテンプレートを直すだけで、メインプログラムには触れません。
- **`#(card)` でサブカードを注入**：フローが `#(content)` に達すると、`content` サブカードが完全なモジュールとして実行され、その位置に結果が埋め込まれます——独自のクエリ、1 件ずつの出力、グループ化もすべて通常どおり行われます。外殻はそのまま中身だけ差し替えられ、同じ外殻を使うすべてのページが一緒に更新されます。
- **ブロックはパラメーターと状態を持てる**：`<block name="row.aa" alg="'align-items-center'"/>` は値をテンプレートの `$alg` に渡します。`var()`／`inc()` によりブロックをまたいだ連番や交互配色が予測可能になります。
- **CDATA で直書きする場合との違い**：CDATA でその場に HTML をハードコードすると「外殻＋中身」を自分で組み立てることになり、分割・レイアウト変更・テンプレート再利用は自動では付いてきません。ページやレイアウトが増えると保守コストが急上昇します。

結果として、**デザイナーはロジックに触れずにテンプレートを直し、エンジニアはレイアウトに触れずに WML を直せます**。ヘッダー・フッター・メニューは `<include>` で一度定義すればサイト全体が同時に更新され、出力は標準 HTML なので Bootstrap、Tailwind、独自 CSS をそのまま適用できます。同じ仕組みでテンプレートファイルを差し替えれば、Web ページが API に変わります——`device="api.htm"` は `.wml` 自身が生成した内容だけを出力し、LINE Bot のような Webhook への JSON 応答に使えます。詳しくは第 9 章「Web テンプレートシステム」と第 15 章を参照してください。

### COBOL の場合：言語変換器ではなく、ゼロから始める必要もない

現在、多くの AI ツールが COBOL を Java、C# その他の現代的な言語に変換できると謳っています。しかし：

> **コードの変換に成功しても、システムの移植が完了したことにはならない。**

COBOL の業務システムで本当に複雑なのは、長年蓄積されたデータ構造、取引フロー、フィールドの意味、バッチ処理、レポート、例外処理、そして元の Runtime が形作ってきた動作であることが多いのです。そのため、単純な **COBOL → Java** はたちまち **COBOL → AI → Java → Compile → Debug → Test → 再修正** になりがちで、最終的にコンパイルが通っても、変換後のシステムが本当に元のシステムと同じ動作をするかを確かめるには、異種プラットフォーム間の大量のデバッグと検証が必要になることがあります。

WapForm の方向性は異なります。「ソースコード」を唯一の真実とみなすのではなく、アプリケーションを WML というプラットフォーム非依存の定義層へ引き上げるのです。将来の **WapForm for COBOL** は単に「COBOL を生成する」だけのものではありません——既存 COBOL システムのアプリケーションロジック、データ、フィールド、フロー、イベント、レポートを WML *へ* 変換することもでき（**既存 COBOL → WapForm for COBOL → WML**）、しかもこの入口は一方通行ではなく、同じ WML を COBOL 自体へ戻して展開することもできます（**COBOL → WapForm for COBOL → WML → COBOL**）。これにより WapForm for COBOL は「旧システムの退出口」であるだけでなく、「旧システムそのものの再生成・検証ツール」にもなり得ます——変換後の動作が元と一致することを確かめたり、現行の Runtime に合わせたよりクリーンな版を生成し直したりできます。いったん WML に入れば、アプリケーションはもはや COBOL そのものに縛られず、同じ定義を既に構築済みの Flutter Generator と Runtime を通して展開できます：**既存 COBOL → WML → Flutter**。毎回 **COBOL → Flutter** を一からたどる必要はありません。WML が元のアプリケーションを完全に記述していれば、WML から Flutter を生成する際に、原則として COBOL を理解し直す必要も、大規模な言語間翻訳をやり直す必要もなく、少数のプラットフォーム差異に必要な調整を加えるだけで済みます——これこそが中間定義層としての WML が本当に重要な理由です。

**WapForm for COBOL はまだ存在しません**——しかし Flutter によって **Definition → Generator → Runtime → Target Code** という完全なエンジニアリングチェーンの最初の検証が完了しているため、将来 COBOL に必要な Runtime、コンポーネントモデル、Generator を作る際に WapForm 全体を作り直す必要はありません。条件が許せば、後続のプラットフォームは Flutter と同じか、さらに短い期間で完成する可能性さえあります。最も重要な方法論、アーキテクチャ、生成フローがすでに存在するからです：

> **最初のプラットフォームが最も困難なエンジニアリング手法を確立・検証した。後続のプラットフォームはその土台の上で展開を続けられる。**

したがって、将来は次のような形が考えられます：

**COBOL → WML → COBOL**

**COBOL → WML → Flutter**

さらに：

**WML → 他のプラットフォーム：MicroPython、Node.js**

**WML → 他の領域：AI、EDA**

プラットフォームや領域ごとに、同じアプリケーションをそれぞれ定義し直す必要はもうありません。

### WapForm が本当に築こうとしているものは何か

つまり、WapForm の核心は次のものではありません：

**WapForm for Flutter**

また次のものでもありません：

**WapForm for COBOL**

そうではなく、より高いレベルのアーキテクチャです：

> **アプリケーションをまず定義し、それを各プラットフォームが実現する。**

WML が中心。AI は加速器。Runtime は着地層。プラットフォームは最終的な実現形態にすぎません。

これが WapForm と一般的な AI コード変換ツールとの最大の違いでもあります：

**AI Code Conversion**

`Source Code → AI → Another Source Code`

**WapForm**

`Application Definition → Target Runtime → Target Code`

前者は異なる言語の間でコードを移し替えるもの。後者はアプリケーション定義そのものをプラットフォームから切り離すものです。

WapForm for Flutter は単なる Flutter への移植ではありません——WapForm のクロスプラットフォームアーキテクチャを初めて完全に実証したものです。

そして WapForm for COBOL も、単なる次の「言語変換器」ではありません。既存の COBOL システムが WML に入り、さらに Flutter や他のプラットフォームへ展開されるための架け橋になり得るのです。

**One Definition. Any Platform. Every Domain.**

### 本書の範囲

WapForm には現在 2 つの正式な実行環境があり、本書が主に扱うのもこの 2 つです：

**WapForm for Windows** — 従来型のデスクトップ MDI アプリケーション。データベースに直接接続し、豊富な UI コントロール（グリッド、タブ、印刷プレビュー）を備えます。

**WapForm for Web** — サーバーサイドの動的 Web ページエンジンで、`.wml` を解析して HTML を出力します。Card の `device` 属性は HTML テンプレートファイル（例 `"wapform.html"`）を指します。`request.*` で HTTP パラメーターを受け取り、`session.*` でユーザーの状態を保持し、出力は Bootstrap などのフロントエンドフレームワークにそのまま埋め込めます。

第 16 章では **WapForm for Flutter** も扱います。同じ WML 定義がオープンソースの Runtime を通じて Flutter App として展開される様子を、「一度定義し、何度でも展開する」を 3 つ目のプラットフォームで具体的に示す例として紹介します。

本書は簡潔で例題中心のリファレンスマニュアルです。読者は SQL、XML、イベント駆動アプリケーションの概念に慣れていることを前提としますが、WapForm の使用経験は必要ありません。

### 本書の表記規則

`<element/>` は WML の空要素（void element）、`<element>` はコンテナ要素を表します。属性名は `等幅フォント` で示します。必須属性は **(必須)**、任意属性は **(任意)** と表記します。式の文法は WapForm の `$()` 補間の規則に従います。

---

### WapForm プラットフォーム・エコシステム

WapForm は進化を続けるクロスプラットフォーム・エコシステムです：

| プラットフォーム | 説明 | 状態 |
|---|---|---|
| **WapForm Windows** | デスクトップ MDI アプリケーションフレームワーク。グリッド、改ページ、印刷プレビューを備える | 正式版 |
| **WapForm Web** | サーバーサイドの動的 Web ページエンジン（IIS ISAPI）。レイアウトとロジックを分離 | 正式版 |
| **WapForm Flutter** | 同じ WML からクロスプラットフォームの Flutter App を直接エクスポート。中心は Web で、モバイル対応を順次追加中 | 正式版 |
| **WapForm COBOL** | COBOL インポート → WapForm で開発 → COBOL エクスポート。書き直し不要のメインフレーム現代化 | 開発中 |
| **WapForm EDA** | スクリプトに散らばった IC 設計フローを、読みやすく追跡可能な WML パイプラインに集約 | 開発中 |
| **WapForm AI（Cherith）** | 事前学習なしで直接推論するローカル AI エージェント | 開発中 |

---

### WapForm for AI：Cherith

Cherith は WapForm が AI 時代に踏み出すための中核プロジェクトです。20 年にわたるクロスプラットフォームの実戦経験の上に築かれ、LLM とはまったく異なる道を歩みます。

LLM は膨大なコーパスの統計的関連から出力を予測するもので、本質的には言語の模倣者です。Cherith の主張は **「言語こそプログラム」「世界こそオブジェクト指向」** ——自然言語の一文一文を推論可能な論理構造へ分解し、名詞はオブジェクトに、動作はメソッドに、条件はプロパティ操作に対応づけ、意味的な場面全体をプログラム可能なオブジェクト指向の世界モデルにします。

ここからいくつかの決定的な違いが生まれます。事前学習に依存しない、エッジデバイスで動作する（消費電力は GPU の数分の一）、推論過程が説明可能かつ検証可能、ハルシネーションを起こさない。数千万文規模の対応ロジックを構築しなければならないこのシステムを可能にしているのが、WapForm の 10 倍速の開発力です。

> *LLM は模倣、Cherith は理解。LLM は文字の出力、Cherith は認知の構築。*

---

本書は WapForm for Windows、WapForm for Web、WapForm for Flutter の 3 つの完全な環境を扱い、実際のプロジェクトのソースコードをもとに、思考モデル、言語リファレンスから本番レベルの実践まで、完全な技術文書を提供します。

---

## 目次

- [プラットフォーム対応表記の説明](#プラットフォーム対応表記の説明)
- [第 1 章　WapForm の思考モデル](#第-1-章-wapform-の思考モデル)
  - [1.1 すべては Card](#11-すべては-card)
  - [1.2 データセットのバインドモデル](#12-データセットのバインドモデル)
  - [1.3 フローモード vs. 出力モード](#13-フローモード-vs-出力モード)
  - [1.4 式システム](#14-式システム)
  - [1.5 イベントモデル](#15-イベントモデル)
- [第 2 章　ドキュメント構造](#第-2-章-ドキュメント構造)
  - [2.1 WML ドキュメント](#21-wml-ドキュメント)
  - [2.2 Card のライフサイクル](#22-card-のライフサイクル)
  - [2.3 データセットフィールドの変数命名規則](#23-データセットフィールドの変数命名規則)
- [第 3 章　コアパターン](#第-3-章-コアパターン)
  - [3.1 パターン：単一テーブルの CRUD フォーム](#31-パターン単一テーブルの-crud-フォーム)
  - [3.2 パターン：マスター・ディテール構造](#32-パターンマスターディテール構造)
  - [3.3 パターン：検索条件入力 → レポート出力](#33-パターン検索条件入力--レポート出力)
  - [3.4 パターン：自動補完付き Lookup](#34-パターン自動補完付き-lookup)
  - [3.5 パターン：複数タブに分けたフォーム](#35-パターン複数タブに分けたフォーム)
  - [3.6 パターン：バックグラウンドのコピー処理](#36-パターンバックグラウンドのコピー処理)
  - [3.7 パターン：動的 WHERE + 複数モード検索](#37-パターン動的-where--複数モード検索)
  - [3.8 パターン：Web 会員ログインと Session 管理](#38-パターンweb-会員ログインと-session-管理)
- [第 4 章　タグ完全リファレンス](#第-4-章-タグ完全リファレンス)
  - [4.1 ドキュメントとレイアウトのタグ](#41-ドキュメントとレイアウトのタグ)
  - [4.2 データアクセスのタグ](#42-データアクセスのタグ)
  - [4.3 データバインドとリストのタグ](#43-データバインドとリストのタグ)
  - [4.4 フォーム入力と対話のタグ](#44-フォーム入力と対話のタグ)
  - [4.5 フロー制御のタグ](#45-フロー制御のタグ)
  - [4.6 変数とデータセット操作のタグ](#46-変数とデータセット操作のタグ)
  - [4.7 レポート出力のタグ](#47-レポート出力のタグ)
  - [4.8 クロス集計とチャートのタグ](#48-クロス集計とチャートのタグ)
  - [4.9 ナビゲーションとメニューのタグ](#49-ナビゲーションとメニューのタグ)
  - [4.10 システム連携のタグ](#410-システム連携のタグ)
  - [4.11 Web 専用タグ](#411-web-専用タグ)
  - [4.12 HTML テキストとレイアウトのタグ](#412-html-テキストとレイアウトのタグ)
  - [4.13 タグ早見表](#413-タグ早見表)
- [第 5 章　配列](#第-5-章-配列)
  - [5.1 宣言](#51-宣言)
  - [5.2 アクセス](#52-アクセス)
  - [5.3 配列関数](#53-配列関数)
  - [5.4 name() / value() 関数](#54-name--value-関数)
  - [5.5 カウンターとしての配列（レポートの累計）](#55-カウンターとしての配列レポートの累計)
  - [5.6 ルックアップ表としての配列](#56-ルックアップ表としての配列)
  - [5.7 色の対応表としての配列](#57-色の対応表としての配列)
  - [5.8 データセットの配列式アクセス](#58-データセットの配列式アクセス)
  - [5.9 制限と注意事項](#59-制限と注意事項)
- [第 6 章　式と関数ライブラリ](#第-6-章-式と関数ライブラリ)
  - [6.1 補間の文法](#61-補間の文法)
  - [6.2 演算子](#62-演算子)
- [第 7 章　データセットオブジェクト・リファレンス](#第-7-章-データセットオブジェクトリファレンス)
  - [7.1 フィールド値へのアクセス](#71-フィールド値へのアクセス)
  - [7.2 データセットの状態プロパティ](#72-データセットの状態プロパティ)
  - [7.3 Lookup プレフィックス](#73-lookup-プレフィックスlupdataset)
  - [7.5 Web 環境オブジェクト](#75-web-環境オブジェクト)
  - [7.6 レポート環境の特殊変数](#76-レポート環境の特殊変数)
  - [7.7 データセットのメソッド早見表](#77-データセットのメソッド早見表)
- [第 8 章　Windows 版のシステムログインと権限制御](#第-8-章-windows-版のシステムログインと権限制御)
  - [8.1 3 層の協調アーキテクチャ](#81-3-層の協調アーキテクチャ)
  - [8.2 ログインダイアログ](#82-ログインダイアログ)
  - [8.3 本人認証](#83-本人認証)
  - [8.4 メニューの構築と LoginLevel の設定](#84-メニューの構築と-loginlevel-の設定)
  - [8.5 フィールドブロックの権限：author タグ](#85-フィールドブロックの権限author-タグ)
  - [8.6 実践例：注文承認ブロック](#86-実践例注文承認ブロック)
  - [8.7 データフロー全体](#87-データフロー全体)
  - [8.8 データベース設計の参考](#88-データベース設計の参考)
  - [8.9 設計の要点まとめ](#89-設計の要点まとめ)
- [第 9 章　Web テンプレートシステム](#第-9-章-web-テンプレートシステム)
  - [9.1 コンセプト：WML が HTML テンプレートを駆動する](#91-コンセプトwml-が-html-テンプレートを駆動する)
  - [9.2 トリガーブロック（Triggered Block）](#92-トリガーブロックtriggered-blockテンプレート機構の大きな特長)
  - [9.3 HTML テンプレートの構造：ブロックマーカー](#93-html-テンプレートの構造ブロックマーカー)
  - [9.4 レイアウトパターン](#94-レイアウトパターンblock-nameon-の選択)
  - [9.5 notebar 目次ツリー：side サブカードの詳細](#95-notebar-目次ツリーside-サブカードの詳細)
  - [9.6 AJAX のオンデマンド読み込みと wap タグ](#96-ajax-のオンデマンド読み込みと-wap-タグ)
  - [9.7 3 種類のコンテンツ注入メカニズム](#97-3-種類のコンテンツ注入メカニズム)
  - [9.8 2 種類の HTML テンプレート](#98-2-種類の-html-テンプレート)
  - [9.9 block 呼び出し時のパラメーター受け渡し](#99-block-呼び出し時のパラメーター受け渡し)
  - [9.10 テンプレート内の式と状態関数](#910-テンプレート内の式と状態関数)
  - [9.11 完全な対応関係](#911-完全な対応関係notewml--wapformhtml)
  - [9.12 テンプレート機構のまとめ](#912-テンプレート機構のまとめ)
- [第 10 章　チャート](#第-10-章-チャート)
  - [10.1 概観](#101-概観)
  - [10.2 基本構造](#102-基本構造)
  - [10.3 chart — チャートコンテナの属性](#103-chart--チャートコンテナの属性)
  - [10.4 serie — 系列の属性](#104-serie--系列の属性)
  - [10.5 point — データポイント](#105-point--データポイント)
  - [10.6 チャート種類の完全一覧](#106-チャート種類の完全一覧)
  - [10.7 チャート種類早見表](#107-チャート種類早見表)
  - [10.8 データソース：2 つのモード](#108-データソース2-つのモード)
  - [10.9 色配列のテクニック](#109-色配列のテクニック)
  - [10.10 複数チャートの並列表示](#1010-複数チャートの並列表示table-レイアウト)
  - [10.11 プラットフォームの違い](#1011-プラットフォームの違い)
  - [10.12 よく使うパターン早見](#1012-よく使うパターン早見)
- [第 11 章　Web ファイルアップロード実践：upload と multiupload](#第-11-章-web-ファイルアップロード実践upload-と-multiupload)
  - [11.1 multiupload：複数ファイルの multipart アップロード](#111-multiupload複数ファイルの-multipart-アップロード)
  - [11.2 upload：生の PUT による単一ファイルアップロード](#112-upload生の-put-による単一ファイルアップロード)
  - [11.3 セキュリティ機構のまとめ](#113-セキュリティ機構のまとめ)
  - [11.4 本章のまとめ](#114-本章のまとめ)
- [第 12 章　Windows ファイル転送実践：open と webcopy](#第-12-章-windows-ファイル転送実践open-と-webcopy)
  - [12.1 open：システムのファイル選択ダイアログ](#121-openシステムのファイル選択ダイアログ)
  - [12.2 webcopy：5 種類のプロトコルによるファイル転送](#122-webcopy5-種類のプロトコルによるファイル転送)
  - [12.3 実践での組み合わせ：open + webcopy httpupload による画像アップロードとプレビュー](#123-実践での組み合わせopen--webcopy-httpupload-による画像アップロードとプレビュー)
  - [12.4 本章のまとめ](#124-本章のまとめ)
- [第 13 章　クロス集計実践](#第-13-章-クロス集計実践)
  - [13.1 WapForm クロス集計の本質](#131-wapform-クロス集計の本質)
  - [13.2 システム概観](#132-システム概観)
  - [13.3 データ検索：明細からピボット軸へ](#133-データ検索sql-側で先に集計する)
  - [13.4 crosstab ルート要素の属性](#134-crosstab-ルート要素の属性)
  - [13.5 状態変数の初期化](#135-状態変数の初期化)
  - [13.6 表コンテナと改ページの設定](#136-表コンテナと改ページの設定)
  - [13.7 列軸の定義：col change](#137-行軸の定義row-change)
  - [13.8 行軸とセルの描画](#138-セルの描画rowcol-ではなく-cellrowcellcolcell)
  - [13.9 列末の小計列（TOTAL 列）](#139-列末の小計列total-列)
  - [13.10 行末の AMOUNT 列（横方向の総合計）](#1310-行末の-amount-列横方向の総合計)
  - [13.11 グループ末の小計行（TOTAL 行）](#1311-グループ末の小計行total-行)
  - [13.12 最終の総計行（AMOUNT 総計）](#1312-最終の総計行grand-total)
  - [13.13 WML ソースコード全体](#1313-wml-ソースコード全体)
  - [13.14 レポート設計パターンのまとめ](#1314-設計パターンのまとめ)
- [第 14 章　販売管理システムの構築](#第-14-章-販売管理システムの構築)
  - [14.1 システム概観](#141-システム概観)
  - [14.2 単一テーブル CRUD の 3 つの書き方](#142-単一テーブル-crud-の-3-つの書き方)
  - [14.3 動的検索の三銃士：`xyz` / `clr` / `set`](#143-動的検索の三銃士xyz--clr--set)
  - [14.4 出荷伝票のマスター・ディテール構造：連番と明細合計の連動](#144-出荷伝票のマスターディテール構造連番と明細合計の連動)
  - [14.5 動的な連動：バーコードスキャンと顧客別販売履歴価格の自動入力](#145-動的な連動バーコードスキャンと顧客別販売履歴価格の自動入力)
  - [14.6 ポップアップ式のデータ選択：4 種類の lookup ダイアログカード](#146-ポップアップ式のデータ選択4-種類の-lookup-ダイアログカード)
  - [14.7 2 枚複写の連続帳票：出荷伝票／入荷伝票の印刷](#147-2-枚複写の連続帳票出荷伝票入荷伝票の印刷)
  - [14.8 グループ集計レポート：売掛金明細書と期首残高の繰越](#148-グループ集計レポート売掛金明細書と期首残高の繰越)
  - [14.9 メール連携：ワンクリックで顧客に出荷を通知](#149-メール連携ワンクリックで顧客に出荷を通知)
  - [14.10 アカウントと権限の管理：ネストしたマスター・ディテール＋子テーブルの自動展開](#1410-アカウントと権限の管理ネストしたマスターディテール子テーブルの自動展開)
  - [14.11 本章のまとめ](#1411-本章のまとめ)
- [第 15 章　動的な Web 取引プラットフォームの構築（WapForm for Web）](#第-15-章-動的な-web-取引プラットフォームの構築wapform-for-web)
  - [15.1 システム概観](#151-システム概観)
  - [15.2 1 回のクエリでサイト全体が共有するメニューツリー](#152-1-回のクエリでサイト全体が共有するメニューツリー)
  - [15.3 コンポーネントの再利用：asider.wml はデータベースに一切アクセスしない](#153-コンポーネントの再利用asiderwml-はデータベースに一切アクセスしない)
  - [15.4 コンテンツの種類に応じてリンク先を動的に決める](#154-コンテンツの種類に応じてリンク先を動的に決める)
  - [15.5 AJAX による部分読み込み：マニュアルと案内の 2 ファイル構成](#155-ajax-による部分読み込みマニュアルと案内の-2-ファイル構成)
  - [15.6 ショップのトップページ：3 つの操作モードと安全な動的クエリの組み立て](#156-ショップのトップページ3-つの操作モードと安全な動的クエリの組み立て)
  - [15.7 ページ送りバーの生成：`navigator` サブカード](#157-ページ送りバーの生成navigator-サブカード)
  - [15.8 ショッピングカートの集計：`header.wml` に組み込まれた決済試算](#158-ショッピングカートの集計headerwml-に組み込まれた決済試算)
  - [15.9 Session の有効期間：3 層の寿命と変数ごとの期限](#159-session-の有効期間3-層の寿命と変数ごとの期限)
  - [15.10 本章のまとめ](#1510-本章のまとめ)
- [第 16 章　同じ定義を Flutter へ展開する（WapForm for Flutter）](#第-16-章-同じ定義を-flutter-へ展開するwapform-for-flutter)
  - [16.1 なぜ別の Runtime が必要なのか](#161-なぜ別の-runtime-が必要なのか)
  - [16.2 パッケージ構成：WapForm モジュール](#162-パッケージ構成wapform-モジュール)
  - [16.3 WML タグを Dart クラスへ 1 対 1 で対応づける方法](#163-wml-タグを-dart-クラスへ-1-対-1-で対応づける方法)
  - [16.4 マスター・ディテール構造の対応：出荷伝票と明細](#164-マスターディテール構造の対応出荷伝票と明細)
  - [16.5 レポートエンジンの対応：グループ小計が `parseBlock`/`emitRow` になるまで](#165-レポートエンジンの対応グループ小計が-parseblockemitrow-になるまで)
  - [16.6 ファイル構成：1 ファイル 1 独立ユニット](#166-ファイル構成1-ファイル-1-独立ユニット)
  - [16.7 実例による検証：`app001`～`app902` を一括変換](#167-実例による検証app001app902-を一括変換)
  - [16.8 プラットフォームの現状と既知の制限](#168-プラットフォームの現状と既知の制限)
  - [16.9 インストールとライセンス](#169-インストールとライセンス)
  - [16.10 本章のまとめ](#1610-本章のまとめ)
- [付録 A　クイックリファレンスカード](#付録-a-クイックリファレンスカード)
- [付録 B　関数完全リファレンス](#付録-b-関数完全リファレンス)
- [付録 C　Flutter 式エンジンの違い](#付録-c-flutter-式エンジンの違い)
- [索引](#索引)

---

## プラットフォーム対応表記の説明

第 1～15 章の機能項目では、次の 2 種類の表記で Windows／Web 各プラットフォームでの対応状況を示します。第 16 章 WapForm for Flutter は独立した章のため、この表記体系は使いません：

| 表記 | 説明 |
|---|---|
| 🖥️ **Win** | WapForm for Windows（デスクトップアプリケーション） |
| 🌐 **Web** | WapForm for Web（動的 Web ページのサーバーサイド） |
| ✅ | 対応 |
| ⚠️ | 一部対応、動作に違いがある、または本書で未確認 |
| ❌ | 非対応 |

第 4 章「タグ完全リファレンス」では、3 つ目のプラットフォーム表記を追加しています：

| 表記 | 説明 |
|---|---|
| 📱 **Flutter** | WapForm for Flutter（1 つの WML から実行可能な Flutter App をエクスポート） |

WapForm for Flutter のエクスポート機構は、**Windows のコンポーネントモデル**（データセット、グリッド、ナビゲーターバー、フィールド、イベント）を同等の Dart クラスへ 1 つずつ対応づけるもので、Web 版の HTML テンプレート／Session／サーバーサイドの仕組みを別途対応づけるものではありません。したがって：

- 🖥️ **Win** が ❌ のタグ（Windows 版自体に存在しない）は、エクスポートすべき Windows 側の対応物がないため、📱 **Flutter** も一律に ❌ とします。
- **クロス集計**（`<crosstab>` とその子タグ）と**チャート**（`<chart>` とその子タグ）の 2 種類は、公式サイトのエディション機能比較表で「全エディション非対応」と明記されています。理由はモバイルデバイス自体の表示上の制約で、有償エディションとは無関係です。そのため一律に 📱 **Flutter** ❌ とします。
- その他のタグは、公式サイトのエディション機能比較表で分類された機能項目（CRUD フォーム、マスター・ディテール構造、Lookup の自動入力、計算フィールド、データナビゲーターバー、イベントフック、動的クエリ、レポートのグループ化と改ページ、複数タブ、印刷プレビューなど）と 1 つずつ照合しました。対応する機能項目が見つからず、既存の資料からも本書で確認できなかったタグは一律に ⚠️ とし、裏付けのない断定はしていません。

以上は WapForm 公式サイト `flutter.html` の「エディション機能比較」ページの公開情報に基づいて整理したものです。今後エディションの機能が変わった場合は、その時点の公式サイトの告知に従ってください。

**📱 Flutter セクション**

第 1～15 章では、`wapform_flutter` に対応するモジュールがあるタグや節の後に **📱 Flutter** セクションを設け、Dart でどのモジュール・どの API を使えば同じことができるかを例とともに説明します。対応するモジュールがない機能（クロス集計、チャート、Web テンプレート、Session、`<navigator/>`、`<dbgrid>` など）には Flutter セクションを付けていません。使用するモジュールはすべてパッケージのルートにあります：

| モジュール | 主な API |
|---|---|
| `wapform_expression.dart` | `WapEvaluator`：`eval()`、`cond()`、`setVar()`、`getVar()`、`setRow()`、`addFunction*()` |
| `wapform_lazarus.dart` | `useEngine()`、`setvar()`、`expression()`、`condition()`、`expandText()`／`expandSql()`／`expandSqlAuto()`／`expandSqlQuoted()`、`invoke()`、`varChangeHooks`、`DataSetRegistry`、`DbQuery` |
| `wapform_lookup_box.dart` | `WapLookupBox` |
| `wapform_filter.dart` | `WapFilter`、`FilterItem` |
| `wapform_report.dart` | `WapReport`、`WapPage`、`isLandscape()`、`normalizePaper()`、`customPaperSizeInches()`、`pageSizeOf()` |
| `wapform_report_style.dart` | `reportCssScreen`、`reportCssPrint`、`reportCssSrc` |
| `report_web.dart` | `openHtmlForPrint()`、`buildHtmlIframe()` |
| `wapform_colors.dart` | `WapColors` |

各例は 3 つのオブジェクトを共有します：`_ev`（このカードの `WapEvaluator`）、`_reg`（このカードの `DataSetRegistry`）、`db`（`DbQuery(registry: _reg, connection: 接続)`。接続オブジェクトの作り方はパッケージの README を参照）。また、画面の初期化時に `useEngine(_ev, _reg)` を呼び出し済みとします。インストールと構成は第 16 章を参照してください。

---

## 本書の読み方

第 1～3 章で概念モデルを築きます。第 4 章はタグの完全リファレンス、第 5 章は配列、第 6 章は式システム（補間の文法と演算子）、第 7 章はデータセットオブジェクトのリファレンス、第 8 章は Windows のログインと権限、第 9 章は Web テンプレートシステム、第 10 章はチャート、第 11 章は Web ファイルアップロードの実践（`<upload>` と `<multiupload>`）、第 12 章は Windows ファイル転送の実践（`<open>` と `<webcopy>`）、第 13 章はクロス集計の実践、第 14 章は販売管理システムの実践（WapForm for Windows）、第 15 章は動的 Web 取引プラットフォームの実践（WapForm for Web）、第 16 章は同じ定義を Flutter へ展開する実践（WapForm for Flutter）です。付録 A はクイックリファレンスカード、付録 B は全 398 関数（文字列、数学、日付と時刻、条件、エンコードと変換、その他）を収録した関数完全リファレンス、付録 C は Flutter 式エンジンの違いです。各章で対応モジュールがあるタグや節の後には **📱 Flutter** セクションがあります。

---

## 第 1 章　WapForm の思考モデル

### 1.1 すべては Card

🖥️ **Win** ✅ | 🌐 **Web** ✅

WapForm の基本的な実行単位は **card**——一意の `id` を持つ `<card>` 要素です。WapForm のプログラムは、1 枚以上の card を含む `<wml>` ドキュメントです。

**Windows 環境：** Card は Delphi のフォームや Windows のダイアログに近く、実行環境はそれらを 1 つの MDI アプリケーションウィンドウ内にホストします。

**Web 環境：** Card の `device` 属性は HTML テンプレート（例 `"wapform.html"`）を指し、フレームワークは WML フローの出力をテンプレートの指定ブロックに埋め込みます。補助的な card は `device="sub"` を使って呼び出し可能なサブルーチンとなり、JavaScript の `loadDoc()` やフレームワークのルーティング機構で非同期に読み込まれます。

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
  <card id="P" device="wapform.html">   ← メインページ、出力は HTML テンプレートに埋め込まれる
  <card id="slider"    device="sub">    ← スライダー部分（非同期読み込み）
  <card id="breadcrumb" device="sub">   ← パンくずリスト（非同期読み込み）
  <card id="content"   device="sub">    ← メインコンテンツ（非同期読み込み）
</wml>
```

Card 間の移動は `<go href="#id">` で先へ進み、`<prev/>` で前の card に戻ります。Web 環境では `<redirect href="page.wml"/>` で HTTP リダイレクトすることもできます。

### 1.2 データセットのバインドモデル

🖥️ **Win** ✅ | 🌐 **Web** ✅

WapForm のデータ層は **dataset**（データセット）を中心に構成されます——名前を持ち、カーソルで位置づけられるレコードセットで、その寿命は card と同じです。各 dataset は `<dbquery>`（SQL クエリ型）または `<dbtable>`（テーブル型）で宣言します。宣言後、`<datasource dataset="name">` 要素が UI コントロールを包み、現在のレコードにバインドします。

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

Web 環境でもデータセットは同様に使えますが、UI バインド（`<datasource>`、`<navigator/>`、`<dbgrid>`）は通常、HTML の直接出力に置き換えられます。

**📱 Flutter**（`wapform_lazarus.dart`：`DbQuery`、`DataSetRegistry`）

`<dbquery id="em">` は `db.query("em", sql)` に対応します。クエリが開かれると `em` として `DataSetRegistry` に登録され、式から `em.フィールド` で現在のレコードを読めます（id は大文字・小文字を区別しません）。

```dart
Future<void> openEmployees() async {
  await db.query("em", "select * from employees order by emp_no");
  debugPrint("${expression("em.emp_name")} / ${expression("em.COUNT")}");
}
```

### 1.3 フローモード vs. 出力モード

🖥️ **Win** ✅ | 🌐 **Web** ✅

Card には 2 つの実行モードがあります：

**フローモード** — card の本体が上から下へプログラムとして実行されます：`<setvar>`、`<if>`、`<dbquery>`、`<alert>`、`<go>`。ログイン認証、レコードのコピー、バックグラウンドのバッチ処理はこのモードで動きます。

**出力モード** — card の本体が HTML 風のマークアップを生成し、ホスト側のレンダラーがそれを消費します。Windows のレポート（`device="prv"`）はこのモードで動き、Web 環境のページ出力もすべてこのモードです。

同じ card の中でフローと出力を混在させることができます——実行環境が両者を自動的に分離します。

**📱 Flutter**（`wapform_lazarus.dart`；`wapform_report.dart`：`WapReport`）

フローモードのタグは順に `setvar()`、`condition()`、`await db.query(...)` と書きます。出力モードは `WapReport` サブクラスの `parseBlock()` に書き、`emitRow(expandText(r"..."))` で HTML を出力して `WapPage` に渡し、プレビューと印刷を行います（4.7 節）。

```dart
Future<bool> checkStock() async {
  await db.query("st", r"select * from stock where pno=$(AsQuoted(pa.pno))");
  if (condition("st.COUNT=0")) return false;     // <if cnd="st.COUNT=0"> ... <exit/>
  setvar("ONHAND", "st.qty");
  return true;
}
```

### 1.4 式システム

🖥️ **Win** ✅ | 🌐 **Web** ✅

WapForm は `$variable` で単純な置換を、`$(expression)` で任意の文字列属性の値の計算を行います：

```xml
<setvar name="label" value="sz.color_name+'('+sz.color_no+')'"/>
<td>$(IF(total_qty>0, STR(total_qty), '—'))</td>
<alert message="$('Balance: '+STR(sa.c))" cnd="sa.c>0"/>
```

Web 環境では `DEFINE(var)` 関数が追加され、request や session の変数が存在するかを確認できます：

```xml
<setvar name="pg" value="1"/>
<setvar name="pg" value="val(request.pg)" cnd="DEFINE(request.pg)"/>
```

式は SQL 風の演算子優先順位に従い、完全な関数ライブラリ（第 5 章）をサポートします。

**📱 Flutter**（`wapform_expression.dart`：`WapEvaluator`；`wapform_lazarus.dart`：`setvar()`、`expression()`、`condition()`、`expandText()`）

```dart
void expressionDemo() {
  setvar("label", "sz.color_name+'('+sz.color_no+')'");                  // <setvar>
  final td = expandText(r"<td>$(IF(total_qty>0, STR(total_qty), '—'))</td>"); // $(...)
  if (condition("sa.c>0")) {                                               // cnd=
    debugPrint(expandText(r"$('Balance: '+STR(sa.c))"));
  }
  _ev.setVar("request.pg", "3");             // Flutter には request.* がない：自分でエンジンに入れる
  setvar("pg", "1");
  if (condition("DEFINE(request.pg)")) setvar("pg", "VAL(request.pg)");
  debugPrint(td);
}
```

- `setvar()` の値は常に式として評価されるため、文字列リテラルには単一引用符が必要です：`setvar("pa.icon", "'a.jpg'")`。Dart の値（ユーザー入力、`List`）をそのまま格納するには `_ev.setVar()` を使います。
- `$` を含む文字列は Dart の raw string（`r"..."`）で書いてください。そうしないと `$` が先に Dart 自身によって補間されます。

### 1.5 イベントモデル

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（フローイベントのみ有効、UI イベントは対象外）

データセットと UI コントロールは、ライフサイクルの重要な時点でイベントを発生させます。イベントは任意の WapForm フローを含む `<onevent type="...">` ブロックで処理します：

| 発生タイミング | イベント | Win | Web |
|---|---|---|---|
| レコード追加時 | `onnewrecord` | ✅ | ⚠️ |
| 保存前 / 後 | `beforepost` / `afterpost` | ✅ | ⚠️ |
| 削除前 / 後 | `beforedelete` / `afterdelete` | ✅ | ⚠️ |
| レコードカーソル移動後 | `afterscroll` | ✅ | ❌ |
| フィールド値の変更時 | `onchange` | ✅ | ❌ |
| Lookup の選択を閉じた後 | `oncloseup` | ✅ | ❌ |
| フィールドがフォーカスを失ったとき | `onexit` | ✅ | ❌ |
| グリッド行のダブルクリック時 | `ondblclick` | ✅ | ❌ |
| グリッドセルの色の計算時 | `oncalccellcolors` | ✅ | ❌ |
| グリッドのフッター更新が必要なとき | `onupdatefooter` | ✅ | ❌ |

**📱 Flutter**

モジュールが直接対応するイベント：

| イベント | Flutter |
|---|---|
| Lookup の選択を閉じた後 `oncloseup` | `WapLookupBox(onPicked: (key) { ... })`（4.4 節） |
| フィルターバー `onfilter` | `WapFilter(onQuery: (sql) async { ... })`（4.2 節） |
| フィールド値の変更後、画面の変数を同期 | `varChangeHooks`（7.7 節） |

イベント内のフローも、これまでどおり `setvar()`、`condition()`、`invoke()` で書きます。

---

## 第 2 章　ドキュメント構造

### 2.1 WML ドキュメント

🖥️ **Win** ✅ | 🌐 **Web** ✅

WapForm のプログラムはすべて、拡張子 `.wml` の整形式 XML ファイルです：

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

**Web 環境の典型的な構造：**

```xml
<?xml version="1.0"?>
<wml>
  <card id="P" device="wapform.html">
    <!-- フローロジック：request パラメーターを読み、データベースを検索 -->
    <setvar name="gp" value="request.gp" cnd="DEFINE(request.gp)"/>
    <dbquery id="sys">select * from sys</dbquery>
    <!-- HTML テンプレートのブロックを呼び出す -->
    <block name="wapform.aa"/>
    <include name="header"/>
    <block name="onreport"/>
    <include name="footer"/>
    <block name="wapform.zz"/>
  </card>

  <!-- サブ card：JS から非同期に読み込まれるか、ルーティングで呼ばれる -->
  <card id="content" device="sub">
    <dbquery id="items"><![CDATA[SELECT ... ]]></dbquery>
    <report dataset="items">
      <group>
        <!-- HTML の断片を出力 -->
      </group>
    </report>
  </card>
</wml>
```

**スコープ規則：**
- card の最上位で宣言した `<dbquery>` と `<dbtable>` は、その card と配下の datasource 内で参照できます。
- 最上位で宣言した `<function>` 要素は、同じファイル内の任意の card から `<go href="@id">` で呼び出せます。
- `<setvar>` で設定した変数は card セッション内でグローバルです。

### 2.2 Card のライフサイクル

🖥️ **Win** ✅ | 🌐 **Web** ✅（フローの手順は同じだが、UI の描画は HTML 出力に置き換わる）

card が開かれると：
1. 最上位のフローが順に実行されます：`<setvar>`、`<dbquery>`、`<if>`、`<alert>`。
2. `<datasource>` 要素が初期化され、`onnewrecord` が発生するか、クエリからデータが読み込まれます。（Win）
   Web 環境では `<report>` でデータセットを反復して HTML を直接出力します。
3. 描画された UI がユーザーに表示されます。
4. ユーザーの操作でイベントが発生し、イベントが後続のフローを実行します。（Win）
   Web 環境では、次の HTTP リクエストが新しい card の実行サイクルを起動します。
5. `<prev/>` または `<go href="#other">` で card を離れます。（Win）
   Web 環境では `<redirect href="page.wml"/>` または `<go href="#card_id">` で移動します。

**📱 Flutter**（`wapform_lazarus.dart`：`useEngine()`、`DataSetRegistry.releaseAll()`）

1 枚の card は 1 つの画面に対応し、それぞれが独自の `WapEvaluator` と `DataSetRegistry` を持ちます：

```dart
final WapEvaluator _ev = WapEvaluator();         // この card の変数
final DataSetRegistry _reg = DataSetRegistry();   // この card のデータセット

Future<void> onOpen() async {                     // 1. 最上位のフロー（initState から呼ぶ）
  useEngine(_ev, _reg);                           //    setvar()/expression()/condition() はこの card を使う
  await db.query("em", "select * from employees");
}

void onClose() => _reg.releaseAll();              // 5. card を離れる：すべてのデータセットを閉じて解放
```

複数の card を同時に開いているときは、`useEngine()` によって `setvar()`、`expression()`、`condition()` がどの card に作用するかが決まります。別の card から戻ったら、もう一度呼び出してください。子 card で親の変数とデータセットを共有するには、同じ `_ev`、`_reg` を渡します。

### 2.3 データセットフィールドの変数命名規則

🖥️ **Win** ✅ | 🌐 **Web** ✅

WapForm はデータセットの `id` とフィールド名を連結して複合変数名を作ります。例：

```xml
<dbquery id="orderhdr" ...>
  <field fieldname="work_order_no" displaylabel="Work Order No."/>
```

変数 `orderhdrwork_order_no` には現在のフィールド値が入り、`<setvar>` で読み書きできます：

```xml
<setvar name="orderhdrwork_order_no" value="'WO-2024-001'"/>
```

**📱 Flutter**（`wapform_lazarus.dart`：`setvar()`）

Flutter では `orderhdrwork_order_no` のような連結名は使わず、常に `データセットid.フィールド` と書きます：

```dart
void namingDemo() {
  setvar("orderhdr.work_order_no", "'WO-2024-001'"); // 現在のレコードに書き込む（閲覧中なら自動で編集状態に入る）
  debugPrint("${expression("orderhdr.work_order_no")}");
}
```

`setvar()` は `id.フィールド` を受け取り、`id` が登録済みで開いているデータセットならフィールドに書き込みます。そうでなければ通常の変数名として扱います。

---

## 第 3 章　コアパターン

### 3.1 パターン：単一テーブルの CRUD フォーム

🖥️ **Win** ✅ | 🌐 **Web** ❌（Web では `<operator>` で HTML form を出力）

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

`<navigator/>` は「先頭 / 前へ / 次へ / 最後 / 追加 / 削除 / 保存 / 取消」などのボタンを自動で提供します。

### 3.2 パターン：マスター・ディテール構造

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（複数の `<dbquery>` + `<report>` のネスト出力で代替）

**Windows 版——ネストした `<datasource>` でマスター・ディテールを構築：**

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

**📱 Flutter**（`wapform_lazarus.dart`：`DbQuery`、`setvar()`）

`masterfields="shipment_no"` の効果：ヘッダーが移動するとヘッダーの現在の伝票番号で明細を再検索し、明細を追加するときはヘッダーの伝票番号を引き継ぎます。

```dart
// ヘッダーのカーソル移動後に呼ぶ
Future<void> loadDetail() async {
  await db.query("sn",
      r"select * from sn where shipment_no=$(AsQuoted(sh.shipment_no)) order by seq_no");
}

// 明細を追加するときに呼ぶ
void newDetail() => setvar("sn.shipment_no", "sh.shipment_no");
```

`db.query()` は同じ id で再検索すると既存のデータセットを再利用します。`$(AsQuoted(...))` は単一引用符を付け、内容をエスケープします。

### 3.3 パターン：検索条件入力 → レポート出力

🖥️ **Win** ✅ | 🌐 **Web** ✅（Web は HTML を出力、Windows は印刷プレビューを出力）

標準的な WapForm のレポートフローは 2 枚の card の連続です。入力 card がパラメーターを集め、レポート card が出力を描画します。

**ステップ 1 — WHERE 句を動的に組み立てる：**

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

**ステップ 2（Windows）— `<page>` ブロックで描画：**

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

**ステップ 2（Web）— サブ card で HTML を出力：**

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

**📱 Flutter**（`wapform_lazarus.dart`：`setvar()`／`expandSql()`；`wapform_report.dart`：`WapReport`、`WapPage`）

**ステップ 1 — WHERE を動的に組み立てる：**

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

**ステップ 2 — レポート：**`<report dataset="rpt_data">` は `WapReport` サブクラスになり、`change` のない `<group>` は `RECORD` ブロック、`<page>` は `PAGEPREFIX`／`PAGESUFFIX` になります：

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

**ステップ 3 — プレビュー**（`device="PRV"`、`orientation="landscape"`）：

```dart
Future<void> showReport() async {
  await buildQuery();
  if (!mounted) return;
  await Navigator.push(context, MaterialPageRoute(
    builder: (_) => WapPage(title: "Orders", report: OrderListReport(), orient: "L"),
  ));
}
```

Flutter には「プレビューせずに直接印刷」はありません。`PRN` も `WapPage` を開き、ユーザーが印刷ボタンを押します（Web はブラウザーの印刷へ、Android は PDF を生成）。

### 3.4 パターン：自動補完付き Lookup

🖥️ **Win** ✅ | 🌐 **Web** ❌（Web は HTML select や AJAX で代替）

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

lookup 属性の形式は `"dataset_id ; キーフィールド ; 表示フィールド"` です。プレフィックス `lup` + dataset id で、選択された行のフィールドにアクセスできます。

SQL ベースの動的 lookup：

```xml
<input field="color_no"
       lookup="sql;yy;SELECT color_no, color_name FROM color_master ORDER BY color_no"
       size="10">
  <onevent type="oncloseup">
    <setvar name="sncolor_name" value="lupyy.color_name"/>
  </onevent>
</input>
```

**📱 Flutter**（`wapform_lookup_box.dart`：`WapLookupBox`）

`lookup="pm;material_code;material_name"` ＋ `oncloseup` での自動入力：

```dart
Widget materialLookup() => WapLookupBox(
      dataSet: _reg.findQuery("pm"),                  // lookup の取得元データセット
      keyField: "material_code",
      displayFields: const ["material_code", "material_name"],
      colWidths: const [100, 220],
      value: "${expression("sn.material_code") ?? ''}",
      onPicked: (key) {                               // oncloseup
        _ev.setVar("PICKED", key);
        setvar("sn.material_code", "PICKED");
        invoke("pm", "first");                        // 選ばれた行を探す（luppm に相当）
        while (!condition("pm.EOF") && !condition("pm.material_code=PICKED")) {
          invoke("pm", "next");
        }
        setvar("sn.material_name", "pm.material_name");
      },
      onChanged: (key) {                              // onexit：コードを消したら名称も消す
        if (key.isEmpty) setvar("sn.material_name", "''");
      },
    );
```

- SQL 型 lookup（`lookup="sql;yy;SELECT ..."`）：まず `await db.query("yy", "SELECT color_no, color_name FROM color_master ORDER BY color_no")` を実行し、`_reg.findQuery("yy")` を `dataSet:` に渡します。
- 固定の選択肢ならデータセットは不要です：`lookupItems: {'A': '現金', 'B': '振込'}`（1 列）、または `lookupColumns: {'P01': ['ボールペン', '本']}` ＋ `colWidths`（複数列）。

### 3.5 パターン：複数タブに分けたフォーム

🖥️ **Win** ✅ | 🌐 **Web** ❌（Web は Bootstrap tabs + 複数のサブ card で代替）

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

### 3.6 パターン：バックグラウンドのコピー処理

🖥️ **Win** ✅ | 🌐 **Web** ✅（Web は `device="sub"` + `<redirect>` で代替）

`device="SUB"` の card はウィンドウを開かずにワークフローを実行します。レコードのコピー、一括更新、自動採番に適しています。

**Windows 版：**

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

**Web 版：**

```xml
<card id="content" device="sub">
  <if cnd="DEFINE(request.del)">
    <dbquery><![CDATA[DELETE FROM rn WHERE sno='$session.ord']]></dbquery>
    <session name="ord" value="''"/>
    <redirect href="cart.wml"/>
  </if>
  <!-- 残りのロジック -->
</card>
```

**📱 Flutter**（`wapform_lazarus.dart`：`DbQuery.query()`／`DbQuery.exec()`）

`device="SUB"` の card は、Flutter では画面を作らない `async` メソッドです：

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

- `db.query(id, sql)`：クエリを開き id で登録します。`db.exec(sql)`：行を返さない SQL を実行し、影響を受けた件数を返します。
- どちらもパラメーターを使えます：`db.query("src", "select * from orders where work_order_no=:no", params: {"no": sourceNo})`。`params` を渡すと `$` は展開されません。

### 3.7 パターン：動的 WHERE + 複数モード検索

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
  <!-- 全表スキャンを防ぐ -->
  <setvar name="S" value="'work_order_no=`__NONE__`'" cnd="S='1=1'"/>
  <dbquery id="result"><![CDATA[
    SELECT * FROM orders WHERE $S ORDER BY order_date DESC
  ]]></dbquery>
</function>
```

**📱 Flutter**（`wapform_lazarus.dart`：`setvar()`、`condition()`、`expandSql()`）

```dart
Future<void> runSearch() async {
  setvar("S", "'1=1'");
  if (condition("(match_mode='A') AND (buyer_filter<>'')")) {
    setvar("S", "S+' AND buyer_name=`'+AsSqlStr(buyer_filter)+'`'");
  }
  if (condition("(match_mode='B') AND (buyer_filter<>'')")) {
    setvar("S", "S+' AND buyer_name LIKE `'+AsSqlStr(buyer_filter)+'%`'");
  }
  if (condition("S='1=1'")) setvar("S", "'work_order_no=`__NONE__`'"); // 全表スキャンを防ぐ
  await db.query("result", r"SELECT * FROM orders WHERE $S ORDER BY order_date DESC");
}
```

バッククォートは展開時に単一引用符に置き換わり、`$S` はそのまま挿入されます。ユーザー入力は必ず先に `AsSqlStr()`（`'` → `''`）を通します。Dart エンジンでは `AND`／`OR` の両側の比較に括弧が必要です。

### 3.8 パターン：Web 会員ログインと Session 管理

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
      <block name="login-alert" message="'ログインする権限がありません。'"/>
    <elseif cnd="MD5(B)<>usr.password"/>
      <block name="login-alert" message="'パスワードが正しくありません。'"/>
    <else/>
      <session name="usr" value="A"/>
      <redirect href="index.wml"/>
    </if>
  </if>
</card>
```

ログイン状態を自動でタイムアウトさせるには、書き込み時に `expire`（単位は分）を付けるだけです：

```xml
<else/>
  <session name="usr" value="A" expire="480"/>   <!-- 8 時間後に自動ログアウト -->
  <redirect href="index.wml"/>
```

`expire` は変数をシステムの既定より早く失効させることしかできず、延長はできません。詳しくは第 15 章 15.9 節を参照してください。

> **注意**：`<block>` のパラメーター値は式なので、文字列リテラルには引用符が必要です。上の `title="'エラー'"` を `title="エラー"` と書くと変数名として扱われて Null になり、テンプレート出力時に `Could not convert variant of type (Null) into type (OleStr)` が発生します。

---

## 第 4 章　タグ完全リファレンス

本章は機能別に、WML で使うすべてのタグを収録します。WapForm 独自のタグと、そのまま出力できる標準 HTML タグを含みます。各タグには 🖥️ Win／🌐 Web の対応状況、完全な属性表（必須 **(必須)** / 任意 **(任意)** を含む）、よく使う子タグを示し、最小限の実行可能な例を添えます。属性名は `等幅フォント` で示し、`<element/>` は空要素（void element）、`<element>` はコンテナ要素を表します。式の文法は `$()` 補間の規則に従います。詳しくは第 6 章を参照してください。

### 4.1 ドキュメントとレイアウトのタグ

#### `<wml>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

各 `.wml` ファイルのルートコンテナで、1 つ以上の `<card>` を含みます。属性はなく、省略できません。

**よく使う子タグ：** `<card>`（1 つ以上）

```xml
<?xml version="1.0"?>
<wml>
  <card id="P" title="サンプル">
    ...
  </card>
</wml>
```

#### `<card>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

WML の基本的な実行単位で、第 1 章で「すべては Card」と呼んだものです。1 つの `.wml` に複数の card を置くことができ、フレームワークは `device` によって描画方法と役割を決めます。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `id` | (必須) | Card の識別子。`<include>`、`loadDoc()`、ルーティング呼び出しから参照される |
| `title` | (任意) | ウィンドウタイトル（Win）または HTML の `<title>`（Web） |
| `device` | (任意) | 描画の役割を決める：`MDI`（Windows のメインウィンドウ）、`SUB`／`sub`（バックグラウンド／サブ card、UI を生成しない）、`PRV`（印刷プレビュー）、`PRN`（直接印刷）、HTML テンプレートのファイル名（Web、例 `"wapform.html"`、`"wapform-js.html"`） |
| `width` / `height` | (任意) | ダイアログのサイズ（Win） |
| `orientation` | (任意) | レポートの向き：`portrait`（既定）／`landscape` |
| `printer` | (任意) | 使用するプリンターを指定。通常は `sys.printer1` などのシステム設定を使う |
| `preview` | (任意) | `Y`／`N`。レポートを先に印刷プレビューで表示するかどうか |
| `zoom` | (任意) | 印刷プレビューの初期倍率 |
| `rowheight` | (任意) | グリッド／レポートの行の高さ（ピクセル） |
| `fontsize` | (任意) | 既定のフォントサイズ（ポイント） |

**よく使う子タグ：** `<dbquery>`、`<datasource>`、`<report>`、`<crosstab>`、`<mainmenu>`、`<fieldset>`、`<do>`、`<function>`、`<onevent>`、各種フロー制御タグ

```xml
<card id="P" title="社員マスター" device="MDI">
  <dbquery id="em">select * from employees</dbquery>
  <datasource dataset="em">
    <navigator/>
    <fieldset>
      社員番号：<input field="emp_no" size="8"/>
    </fieldset>
  </datasource>
</card>
```

Card のライフサイクルは第 2 章 2.2 節を参照してください。

**📱 Flutter**（`wapform_report.dart`：`WapPage`）

レポート用の card（`device="PRV"`／`"PRN"`）は Flutter では `WapPage` になり、`orientation` は `orient` に対応します：

```dart
Widget reportCard(WapReport report) => WapPage(
      title: "社員名簿",           // title=
      report: report,              // card 内の <report>
      orient: "L",                 // orientation="landscape"
      paper: "A4",
    );
```

`orient` は `P`（既定）、`L`、`landscape`、`1`、`橫`、`水平`（中国語で「横向き」）を受け付けます。`paper` は `A4`、`A3`、`A5`、`B5`、`letter`、`legal`、またはインチ単位のカスタムサイズ `"8.5x5.5"` を受け付けます。

#### `<page>`（レイアウト）

🖥️ **Win** ✅ | 🌐 **Web** ✅（印刷出力の場面のみ） | 📱 **Flutter** ✅

1 物理ページ分の内容を包みます。`<report>`／`<crosstab>` では改ページのたびに `<page>` に入り直します。

**よく使う子タグ：** `<table>`、`<group>`、任意の HTML レイアウトタグ

```xml
<page>
  <table class="wap" width="100%" rows="40">
    <group>...</group>
  </table>
</page>
```

**📱 Flutter**（`wapform_report.dart`：`PAGEPREFIX`／`PAGESUFFIX`／`PAGEBREAK` ブロック）

`WapReport` は各ページの開始時に `parseBlock('PAGEPREFIX')`、終了時に `parseBlock('PAGESUFFIX')`、ページの間で `parseBlock('PAGEBREAK')` を呼びます。`<page>` 内で毎ページ再印刷するヘッダーは `PAGEPREFIX` に書き、`rows="40"` は `wap.wapLpp = 40` に対応します：

```dart
// WapReport サブクラスの parseBlock() の一部
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

関連する入力フィールドのまとまりを包み、HTML の `<fieldset>` に対応します。中には `<input>` と説明文を直接置きます。

**よく使う子タグ：** `<input>`、`<p>`、`<br/>`

```xml
<fieldset>
  <p>社員番号：<input field="emp_no" size="8"/></p>
  <p>氏名：<input field="emp_name" size="20"/></p>
</fieldset>
```

---

### 4.2 データアクセスのタグ

#### `<dbquery>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

データセット（dataset）を宣言し、内容は SQL 文です。複数行や特殊文字を含む SQL は `<![CDATA[ ]]>` で包むことを推奨します。`<`、`>`、`&` などの記号が XML の解析と衝突するのを避けるためです。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `id` | (必須) | データセットの識別子。以後 `$id.フィールド` または `id.フィールド` で参照 |
| `name` | (任意) | 一部のバージョンでは `id` の代わりに `name` を使う。効果は同じ |
| `tablename` | (任意) | `<dbtable>` と組み合わせるときに物理テーブル名を指定 |

**よく使う子タグ：** `<field>`（フィールドを明示的に定義する場合）

```xml
<dbquery id="em"><![CDATA[
  SELECT * FROM employees WHERE dept='$dept'
]]></dbquery>
```

単純なクエリなら CDATA は省略できます：`<dbquery id="sys">select * from sys</dbquery>`。

**📱 Flutter**（`wapform_lazarus.dart`：`DbQuery.query()`／`DbQuery.exec()`、`expandSql()`）

| WML | Flutter |
|---|---|
| `<dbquery id="em">select ...</dbquery>` | `await db.query("em", r"select ...")` |
| SQL 中の `$dept`、`$(expr)` | クエリ前に `expandSql()` で自動展開 |
| `id` のない `<dbquery>`（INSERT／UPDATE／DELETE） | `await db.exec(r"...")`。影響を受けた件数を返す |

```dart
Future<void> dbqueryDemo() async {
  await db.query("em", r"SELECT * FROM employees WHERE dept='$dept'");
  await db.query("em2", "select * from employees where dept=:d", params: {"d": "R&D"});
  final n = await db.exec(r"UPDATE employees SET active=1 WHERE dept='$dept'");
  debugPrint("$n rows");
}
```

- 同じ id で再度呼ぶと、新しい SQL で同じデータセットを再検索します。id を空文字列にすると、登録しない使い捨てのクエリになります。
- `params` を渡すと `$` は展開されず、値はパラメーターとして送られます。SQL インジェクションを防ぐ最善の方法です。
- Dart の文字列では `<`、`>`、`&` をそのまま書けます。CDATA は不要です。

#### `<dbtable>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（多くは `<dbquery>` で代替） | 📱 **Flutter** ✅

`<field>` 子タグと組み合わせて、SQL を直接書く代わりにデータセットのフィールドと表示名を明示的に定義します。単純なマスターの CRUD ページでよく使われ、ルックアップキーを持つ補助データセット（lookup dataset）にも使われます。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `tablename` | (必須) | 物理テーブル名 |
| `name` | (任意) | データセットの識別子 |
| `indexfieldnames` | (任意) | インデックスフィールド。並べ替えと `locate` による位置づけに使う |
| `keyfields` | (任意) | 主キーフィールド。検索／更新の基準になる |
| `lookupkeyfields` | (任意) | 他の `<input lookup=...>` から参照されるときのキーフィールド |
| `filter` | (任意) | 初期のフィルター条件文字列 |

**よく使う子タグ：** `<field>`（1 つ以上）

```xml
<dbtable tablename="fm">
  <field fieldname="fno" displaylabel="運送業者コード"/>
  <field fieldname="fname" displaylabel="運送業者名"/>
</dbtable>

<!-- キーを持つルックアップ用の補助データセット -->
<dbtable name="gs" tablename="gszl" keyfields="factory_code" lookupkeyfields="factory_code">
  <field fieldname="factory_code" displaylabel="工場コード"/>
  <field fieldname="factory_name" displaylabel="工場名"/>
</dbtable>
```

**📱 Flutter**（`wapform_lazarus.dart`：`DbQuery.query()`）

Flutter にはクエリ型のデータセットしかないため、`<dbtable tablename="fm" indexfieldnames="fno">` は次のように書きます：

```dart
Future<void> openFm() => db.query("fm", "select * from fm order by fno");
```

`lookupkeyfields` は `WapLookupBox` の `keyField` に対応します（4.4 節 `<input>`）。

#### `<field>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

`<dbquery>` または `<dbtable>` の子タグで、1 つのフィールドの表示名、型、既定値を定義します。空要素です。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `fieldname` | (必須) | データベースの物理フィールド名 |
| `name` | (任意) | 一部のバージョンでは `fieldname` の代わりに `name` を使う |
| `displaylabel` | (任意) | 画面に表示するラベル |
| `type` | (任意) | データ型。`date`、`checkbox` など |
| `value` | (任意) | 既定値（レコード追加時によく使う） |

```xml
<field fieldname="hired" displaylabel="入社日" type="date"/>
```

#### `<dbfilter>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（多くは手書きの動的 WHERE で代替。14.3 節参照） | 📱 **Flutter** ✅

宣言型の簡易フィルターバーです。フレームワークが入力欄を自動生成し、`onfilter` イベントで条件文字列を組み立てます。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `result` | (必須) | フィルター結果の文字列を入れる変数名 |

**よく使う子タグ：** `<item>`（フィルター対象フィールドを定義）、`<onevent type="onfilter">`

```xml
<dbfilter result="R">
  <item field="cno" size="20"/>
  <item field="cname" size="20"/>
  <onevent type="onfilter">
    <dbquery id="cu"><![CDATA[select * from cu where $R order by cno]]></dbquery>
  </onevent>
</dbfilter>
```

**📱 Flutter**（`wapform_filter.dart`：`WapFilter`、`FilterItem`）

| WML | `WapFilter` |
|---|---|
| `<item field="cno" size="20"/>` | `items: [FilterItem(field: "cno", label: "顧客コード", size: 20)]` |
| `result="R"` ＋ SQL 中の `$R` | `sqlTemplate: r"select * from cu where $R order by cno"` |
| `<onevent type="onfilter">` | `onQuery: (sql) async { ... }`。`$R` が置き換え済みの完全な SQL を受け取る |

```dart
Widget customerFilter() => WapFilter(
      items: const [
        FilterItem(field: "cno", label: "顧客コード", size: 20),
        FilterItem(field: "cname", label: "顧客名", size: 20),
      ],
      sqlTemplate: r"select * from cu where $R order by cno",
      onQuery: (sql) async {
        await db.query("cu", sql);           // onfilter 内の <dbquery>
        if (mounted) setState(() {});
      },
    );
```

ユーザーが各欄に入力する条件：

| 入力 | 組み立てられる条件 |
|---|---|
| `A` | `フィールド = 'A'` |
| `A~Z` | `(フィールド >= 'A' and フィールド <= 'Z')` |
| `A~` | `フィールド >= 'A'` |
| `~Z` | `フィールド <= 'Z'` |
| `%` を含む（`A%`、`%A%`） | `フィールド like '...'` |
| すべて空欄 | `1=1` |

複数のフィールドは `and` で連結され、入力中の `'` は自動で `''` にエスケープされます。**Clear** を押すとすべての欄を消去し、`1=1` で `onQuery` を呼びます。`width` を指定しなければ親の幅いっぱいに広がり、`borderColor` で枠線の色を変えられます。

---

### 4.3 データバインドとリストのタグ

#### `<datasource>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（Web 環境では `<report>` の反復出力に置き換える。3.1／3.2 節参照） | 📱 **Flutter** ✅

画面要素（`<input>`、`<dbgrid>`、`<navigator>`）を指定したデータセットにバインドします。ネストしてマスター・ディテール構造を作れます。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `dataset` | (必須) | 対応する `<dbquery>` の `id` |
| `name` | (任意) | 内側の `<datasource>` が `mastersource` で参照するための名前 |
| `mastersource` | (任意) | ネストしたマスター・ディテールで、外側の `<datasource>` の `name` を指す |
| `masterfields` | (任意) | マスター・ディテールの関連フィールド。子はこのフィールドで自動的に絞り込み直す |

**よく使う子タグ：** `<navigator/>`、`<fieldset>`、`<input>`、`<dbgrid>`、内側の `<datasource>`（マスター・ディテールのネスト）

```xml
<datasource dataset="sh">
  <navigator/>
  <fieldset>
    伝票番号：<input field="sno" readonly="true"/>
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

マスター・ディテール構造の詳細は 3.2 節を、本番環境の完全な例は第 14 章 14.4 節を参照してください。

#### `<dbgrid>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（Web は HTML `<table>` のループ出力で代替） | 📱 **Flutter** ✅

表形式のリストで、複数の `<item>` で列を定義します。その場での編集とチェックに対応します。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `name` | (任意) | プログラムから参照するための名前（`lookupResolver` など） |
| `height` / `width` | (任意) | グリッドのサイズ（ピクセル） |
| `color` | (任意) | 背景色 |
| `fontsize` | (任意) | フォントサイズ（ポイント） |
| `multi` | (任意) | `1` で複数選択を許可 |

**よく使う子タグ：** `<item>`（1 つ以上）、`<column>`（スタイル規則）

#### `<item>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ✅

`<dbgrid>` または `<dbfilter>` の下の列定義です。空要素です。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `field` | (必須) | 対応するデータセットのフィールド |
| `size` | (任意) | 列の幅 |
| `title` | (任意) | 列の見出し。既定ではデータセットフィールドの `displaylabel` を使う |
| `type` | (任意) | `checkbox` などの特殊な表示形式 |
| `range` | (任意) | `type="checkbox"` と組み合わせる。形式は `選択時の値;未選択時の値` |
| `lookup` | (任意) | `テーブル;キー列;表示列` 形式。列にルックアップ結果を表示する |

```xml
<dbgrid name="gd" height="200">
  <item field="itm" title="No" size="10"/>
  <item field="uid" size="30" lookup="users;userid"/>
  <item field="w" title="有効" type="checkbox" range="1;0" size="10"/>
</dbgrid>
```

**📱 Flutter**

- `<dbfilter>` 内では：1 つの `FilterItem(field:, label:, size:)`（`<dbfilter>` 参照）。
- `lookup` 付きの場合：ルックアップのリストは `WapLookupBox` が提供します。グリッドのセル内に置くときは `forGrid: true` を設定し、`onTab`／`onTabPrev` で Tab によるセル移動を処理します（パラメーターは 7.3 節参照）。

#### `<navigator/>`

🖥️ **Win** ✅ | 🌐 **Web** ❌（Web はボタンと `request.op` で手作業で実装） | 📱 **Flutter** ✅

「先頭／前へ／次へ／最後／追加／削除／保存／取消」の完全な CRUD ボタンバーを自動生成します。空要素で、属している `<datasource>` のデータセットにバインドされ、属性はありません。

```xml
<p align="center"><navigator/></p>
```

#### `<column/>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

`<dbgrid>` 内で、条件に応じて列全体または行全体のスタイル（背景色、文字色など）を適用するために使います。状態のハイライト表示によく使われます。空要素で、必ず `<dbgrid>` の `<onevent type="oncalccellcolors">` の下に書き、データの各行を描くたびに 1 つずつ判定されます。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `field` | (任意) | 対象フィールド（**省略すると行全体に適用**され、列全体ではありません——よく誤解される点です。`field` は「この列だけに適用」を意味し、指定しないと「この行のすべてに適用」になります） |
| `brush` | (任意) | 背景色（16 進カラーコード、`#` なし） |
| `color` | (任意) | 文字色 |
| `cnd` | (任意) | 条件式。成立したときだけスタイルを適用。省略すると常に成立とみなす（下の応用例参照） |

**基本的な使い方**（行全体に色付け。`cnd` が成立するとその行全体の背景色が変わる）：

```xml
<column brush="EDDA74" color="000000" cnd="od.cancelled='Y'"/>
```

**応用的な使い方**：1 つの `oncalccellcolors` の下に複数の `<column>` 規則を置けます。各行のデータは規則ごとに順に判定され、互いに影響しません（2 つの規則の `field` や行全体の範囲が重ならない限り、後の規則が先に適用されたものを上書きすることはありません）。よくある組み合わせは、1 つの規則で「現在の 1 件」を示し、残りの規則でそれぞれ「特定の列をデータ値に応じて色分け」するものです：

```xml
<onevent type="oncalccellcolors">
  <!-- field なし：行全体に色付けし、「現在の 1 件」を示す（主キーを組み合わせた文字列で比較） -->
  <column brush="#E5F3FF" cnd="sh.sno=(shym+shco+FORMAT('%4.4d',1))"/>

  <!-- field あり：cno 列だけに色付け。色そのものも動的に計算される
       （brush の値は $(...) でデータベースのフィールド sh.color から文字列を組み立てたもので、固定のカラーコードではない） -->
  <column field="cno" _color="#FF0000" brush="$('#'+sh.color)" cnd="sh.color&lt;&gt;''"/>
  <column field="cshort" _color="#FF0000" brush="$('#'+sh.color)" cnd="sh.color&lt;&gt;''"/>

  <!-- cnd がなくても有効：この 2 つは条件なしで「常に適用」となり、特定の列の文字色を固定で示す -->
  <column field="eval" color="#0000FF"/>
  <column field="log" color="#FF0000"/>
</onevent>
```

この例から 3 つの補足ルールがわかります：

1. **`brush`／`color` は動的な値にできます**。固定の 16 進リテラルに限りません——上の例では `$('#'+sh.color)` でデータベースのフィールド `sh.color` の色値から完全なカラーコードを組み立てており、同じ `<dbgrid>` の行ごとに異なる色を適用できます。
2. **`cnd` は省略できます**：`cnd` のない `<column>` 規則は常に成立とみなされ、特定の列のスタイルを固定で示すのによく使われます（上の例の `eval`／`log` の 2 列）。
3. ⚠️ 上の例には、ドキュメントの表に載っている `color`（アンダースコアなし）ではなく `_color="#FF0000"`（アンダースコアで始まり、`#` 付き）が出てきます。本書ではアンダースコア付き属性（`_color`、`_bgcolor` など）の正式な仕様を見つけられておらず、アンダースコアが「無効化中・一時保留」を表すのか、別の独立した構文なのかは不明です。上の例では `<dbgrid>` 要素自体にも `_bgcolor="#EEF3E9"` が付いています。実際の動作は、お使いの環境の `wap.exe`／`flutter.pas` の生成結果で確認することをお勧めします。ここでは誤解を避けるため、観察された書き方をそのまま記録しておきます。

---

### 4.4 フォーム入力と対話のタグ

#### `<input>`

🖥️ **Win** ✅ | 🌐 **Web** ✅（Web では `request.*` の書き戻しを自分で処理する必要がある） | 📱 **Flutter** ✅

1 つのフィールドにバインドする入力要素で、型と属性は `type` によって変わります。空要素です。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `field` | (必須) | 対応するデータセットのフィールド |
| `size` | (任意) | 表示幅 |
| `type` | (任意) | `date`／`checkbox`／`radio` など。既定はテキスト入力 |
| `value` | (任意) | `checkbox`／`radio` の選択肢の値。形式は `選択時の値;未選択時の値` |
| `readonly` | (任意) | `true` で読み取り専用 |
| `lookup` | (任意) | `テーブル;キー列;表示列`。自動入力付き（3.4 節参照） |
| `oncustomdlg` | (任意) | ポップアップ式の選択カード（例 `#PC`）を指し、既定の lookup ダイアログの代わりに使う |
| `color` | (任意) | フィールドの背景色。`cnd` と組み合わせて異常値のハイライトによく使う |
| `title` | (任意) | `type="checkbox"` のとき、選択肢のテキストラベルとして使う |
| `rows` / `cols` | (任意) | 複数行テキスト入力（`textarea` 型）の行数と列数 |
| `onclick` | (任意) | クリック時に発生するイベント処理 |

```xml
<input field="cno" size="14" lookup="cu;cno;cname"/>
<input field="confirmed" type="checkbox" value="Y;N" title="正式注文"/>
<input field="cancel_date" type="date"/>
<input field="remark" type="textarea" rows="4" cols="40"/>
```

**📱 Flutter**（`wapform_lookup_box.dart`：`WapLookupBox`）

`<input lookup="cu;cno;cname">` のルックアップ・ドロップダウン：

```dart
Widget customerLookup(bool editing) => WapLookupBox(
      dataSet: _reg.findQuery("cu"),               // lookup の第 1 項：取得元データセット
      keyField: "cno",                             // 第 2 項：キーフィールド
      displayFields: const ["cno", "cname"],       // 第 3 項：表示フィールド（複数可）
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

入力欄に文字を打つと、コードまたはいずれかの表示列に入力文字を含む項目だけがリストに残り、Enter で確定します。フォーカスを失うと入力内容で自動入力し、`onChanged` を呼び出します。

#### `<do>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（Web は通常の HTML ボタン + `request.op` で代替） | 📱 **Flutter** ✅

画面のボタンを定義します。`type` によって組み込みの動作が決まります。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `type` | (必須) | `accept`（OK。保存または独自イベントを起動）／`prev`（キャンセル。`<prev/>` を起動して 1 つ前に戻る） |
| `label` | (任意) | ボタンの文字 |

**よく使う子タグ：** `<prev>`、`<setvar>`、`<invoke>`、`<dbquery>` など任意のフロータグ

```xml
<do type="accept" label="OK">
  <prev><setvar name="RESULT" value="gr.id"/></prev>
</do>
<do type="prev" label="キャンセル"><prev/></do>
```

#### `<prev>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ✅

現在のポップアップカードを閉じて 1 つ前に戻ります。`<setvar>` を含めると、閉じる前に選択結果を上位の変数に持ち帰れます（14.6 節の 4 種類の lookup ダイアログカード参照）。属性がない場合は空要素 `<prev/>`、子タグがある場合はコンテナ要素です。

**よく使う子タグ：** `<setvar>`

```xml
<prev><setvar name="shcno" value="cu1.cno"/></prev>
```

#### `<alert>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（Web は JavaScript の `alert()` やフロントエンドのメッセージ部品で代替） | 📱 **Flutter** ✅

メッセージボックスを表示します。`cnd` による条件付きの検証によく使われます。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `cnd` | (任意) | 条件が成立したときだけ表示 |
| `message` | (任意) | メッセージ内容。タグの本文に直接書くこともできる |

```xml
<alert cnd="qty<=0">数量は 0 より大きくなければなりません</alert>
```

#### `<prompt>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

入力ダイアログを表示し、ユーザーに 1 つの値を入力させて指定した変数に保存します。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `message` | (任意) | 案内文 |
| `result` | (必須) | 入力結果を保存する変数名 |

---

### 4.5 フロー制御のタグ

#### `<if>` / `<elseif>` / `<else>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

条件分岐です。`<if>` は `cnd` 属性で 1 行の条件にも、`<elseif>`／`<else>` と組み合わせて多分岐にもできます。

| 属性 | 必須／任意 | 説明（`<if>`／`<elseif>` に適用） |
|---|---|---|
| `cnd` | (必須) | 条件式 |

**よく使う子タグ：** 任意のタグ。`<elseif>`／`<else>` は `<if>` の内側にしか置けません

```xml
<if cnd="CUSTNO_TO=''">
  <setvar name="SQL_WHERE" value="SQL_WHERE+' AND cno like '''+CUSTNO_FROM+'%'''"/>
  <elseif cnd="CUSTNO_FROM=''"/>
  <setvar name="SQL_WHERE" value="SQL_WHERE"/>
  <else/>
  <setvar name="SQL_WHERE" value="SQL_WHERE+' AND cno &gt;= '''+CUSTNO_FROM+''''"/>
</if>
```

ほとんどのタグ（`<setvar>`、`<dbquery>`、`<invoke>` など）は `cnd` 属性を直接付けて単一条件で実行でき、外側を `<if>` で包むのと同じ意味になります。

**📱 Flutter**（`wapform_lazarus.dart`：`condition()`）

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

- タグの `cnd` 属性は `if (condition("...")) ...;` と書きます。
- **Dart エンジンでは `AND`／`OR` の両側の比較に括弧が必要です**：`condition("(qty>0) AND (price<100)")`。括弧がないと解析に失敗し `false` を返します。
- `condition()` はエラー時に `false` を返し、コンソールに `[ERROR] 式 # 原因` を出力します。

#### `<switch>` / `<case>` / `<default>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

多分岐の選択構造で、`exp` 式を各 `<case>` の `value` と照合します。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `exp`（`<switch>`） | (必須) | 照合する式 |
| `value`（`<case>`） | (必須) | 照合値 |

**よく使う子タグ：** 1 つ以上の `<case>`。最後に `<default>` を 1 つ置ける

```xml
<switch exp="mnu_typ[k]">
  <case value="b"><setvar name="app" value="'book'"/></case>
  <case value="n"><setvar name="app" value="'note'"/></case>
  <case value="p"><setvar name="app" value="'page'"/></case>
  <default><setvar name="app" value="'grid'"/></default>
</switch>
```

**📱 Flutter**（`wapform_lazarus.dart`：`expression()`；`wapform_expression.dart`：`SWITCH()`、`DECODE()`）

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

値を別の値に変換するだけなら、1 行の式で足ります：`setvar("app", "SWITCH(mnu_typ[k],'b','book','n','note','p','page','grid')")`（`DECODE()` も同じ使い方）。

#### `<while>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

条件ループです。`cnd` が真の間、内部のタグを実行し続けます。データセットの `First`／`Next`／`EOF` と組み合わせた手動の反復によく使われます。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `cnd` | (必須) | ループの継続条件 |

```xml
<while cnd="not(mnu.eof)">
  <setvar name="mnu_id[k]" value="mnu.pno"/>
  <invoke instance="mnu" method="next"/>
</while>
```

**📱 Flutter**（`wapform_lazarus.dart`：`condition()`、`invoke()`、`setvar()`）

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

ループ内で移動するデータセットが画面要素にバインドされている場合は、前後に `invoke("mnu", "disablecontrols")`／`invoke("mnu", "enablecontrols")` を入れ、1 件移動するたびに再描画されるのを防ぎます。

#### `<for>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

回数指定のループです。Web 環境では、決まった回数のレイアウトの繰り返し出力（ページ送りボタンの列など）によく使われます。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `var` | (必須) | ループ変数名 |
| `from` / `to` | (必須) | 開始値と終了値 |
| `step` | (任意) | 増分。既定は 1 |

#### `<go/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ✅

名前付きの `<function>`（`@関数名` で参照）または別の card へジャンプして呼び出します。レポートエンジンでは `<go href="@header"/>` でヘッダー関数を呼ぶのがよく見られます。空要素です。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `href` | (必須) | `@関数id` または移動先の card／URL |

```xml
<go href="@header"/>
```

#### `<exit/>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

空要素で、現在の `<function>` またはフローブロックを直ちに終了します。`cnd` を付けて早期リターンに使うことが多いです（14.4 節 `UpdateTotal` 関数の再入防止を参照）。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `cnd` | (任意) | 条件が成立したときだけ終了 |

```xml
<exit cnd="DeletingItems"/>
```

#### `<function>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

`<go href="@id">` やイベントから呼び出せる名前付きのフローブロックを定義します。名前付きサブルーチンに相当します。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `id` | (必須) | 関数名。`@id` で参照される |

**よく使う子タグ：** 任意のフロー制御タグとデータ操作タグ

#### `<block/>`

🖥️ **Win** ⚠️ | 🌐 **Web** ✅ | 📱 **Flutter** ❌

あらかじめ定義された HTML／テキストの断片を出力します。テンプレートシステムで、名前を指定して固定のテンプレートブロック（`footer.aa`、`footer.zz` など）を挿入するのによく使われます。空要素です。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `name` | (必須) | テンプレートブロック名 |

```xml
<block name="footer.aa"/>
```

#### `<platform>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

実行プラットフォームに応じて実行する内容を選び、同じ `.wml` がプラットフォームごとに別々の実装をとれるようにします。Windows／Web のエンジンは `name` に自分のプラットフォーム名を含むブロックだけを実行し、残りは読み飛ばします。WapForm for Flutter のジェネレーターは、`name="flutter"` ブロック内の `<![CDATA[ ]]>` を Dart コードとしてそのまま生成される `.dart` に入れます。ある機能に Flutter 側の対応タグがまだない場合（たとえば `<open>` ＋ `<webcopy>` による画像アップロード）や、2 つのプラットフォームで書き方を変える必要がある場合によく使います。

**WML にネイティブコードを埋め込む**：`<platform>` ＋ `<![CDATA[ ]]>`

- 1 つの `.wml` にターゲットプラットフォームのネイティブコードを直接持たせられます。
- 現在対応しているのは Flutter（Dart）です。COBOL のソースも同じ仕組みを使う予定です（`<platform name="cobol">`、開発中）。
- CDATA の内容は生成されるプログラムにそのまま入り、それ以外の部分は宣言型の WML のままです。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `name` | (必須) | プラットフォーム名：`windows`、`web`、`flutter`。複数同時に書ける（例 `name="windows,web"`） |
| `part` | (任意) | `name="flutter"` 専用：`import` は内容が Dart の `import` 文であることを示し、生成ファイル先頭のインポート部に置かれる |

**よく使う子タグ：** `windows`／`web` ブロックには通常の WML タグを、`flutter` ブロックには `<![CDATA[ Dart コード ]]>` を 1 つ置きます

`flutter` ブロックは置く位置によって 3 通りに使えます：

| 位置 | 生成される Dart |
|---|---|
| `part="import"` | ファイル先頭の `import` 部に追加 |
| `<function>`、`<onevent>` などのフロー内 | 文として関数にそのまま挿入。内容に `await` があれば関数は自動的に `async` になる |
| レイアウト内（`<td>` など） | 1 つの `Widget` 式としてレイアウトに挿入 |

**完全な例：`app002.wml` の商品画像アップロード**（Windows は `<open>` ＋ `<webcopy>`、Flutter は `file_picker` ＋ `http`）：

```xml
<card id="P" title="Product Master" width="1200">

  <!-- Flutter：生成ファイルでさらに 2 つのパッケージをインポートする -->
  <platform name="flutter" part="import"><![CDATA[
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
  ]]></platform>

  <!-- 画像を選んでアップロード -->
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

  <!-- 画像を消去 -->
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

  <!-- 画像を表示：Windows だけが必要 -->
  <function id="SHOWIMG">
    <platform name="windows">
      <setprop name="g0" prop="img" value="IF(paicon='', 'http://localhost:90/xyz/upload/300x300.jpg', 'http://localhost:90/xyz/upload/'+paicon)"/>
    </platform>
  </function>

  <dbquery id="pa">
    <![CDATA[select * from pa order by pno]]>
    <field fieldname="icon" displaylabel="Icon"/>
    <onevent type="afterscroll">
      <!-- Flutter の画面はカーソル移動後に再描画されるので、画像も自動で切り替わる -->
      <platform name="windows"><go href="@SHOWIMG"/></platform>
    </onevent>
  </dbquery>

  <datasource dataset="pa">
    <table columns="1">
      <tr>
        <td>
          <!-- レイアウト：Windows はリンクと <img>、Flutter は 1 つの Widget 式 -->
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

この例からわかるポイント：

1. **1 つのプラットフォームだけが必要とするブロック**（`SHOWIMG`、`afterscroll` 内の `<go>`）は `windows` だけに書きます。Flutter はそれを自然に読み飛ばします。
2. **`flutter` ブロックでは生成ファイル内の名前を直接使えます**：`<function id="A0">` は `_a0()` を生成し、データセット `pa` は `_pa` です。生成ファイルに組み込まれた `_saveAsync()`（データベースへ書き戻す）、`_alert()`、`_str()` も使えます。`setvar()` などは `wapform_flutter` の関数です。
3. **アップロードのファイル名の扱いは同じです**：Windows の `unique` はタイムスタンプで名前を付け、Flutter 側も同様にタイムスタンプからファイル名を作り、`upload.php?name=` で受け取ります。
4. `<platform>` は関数に限らず任意の WML を包めます。たとえば Web だけに表示する説明文：`<platform name="web"><p>…</p></platform>`。

> **注意：**`flutter` ブロックの内容は Dart ファイルにそのまま入るため、構文エラーは Flutter のコンパイル時まで見つかりません。`.wml` を変更したら再生成して `flutter analyze` を実行してください。

---

### 4.6 変数とデータセット操作のタグ

#### `<setvar/>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

変数を宣言または代入します。WML で最もよく使うタグです。`value` は完全な式の文法（第 6 章参照）に対応し、`cnd` を付けて条件付きで代入できます。空要素です。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `name` | (必須) | 変数名 |
| `value` | (必須) | 式またはリテラル |
| `cnd` | (任意) | 条件が成立したときだけ代入 |

```xml
<setvar name="TempTotal" value="TempTotal+sn.Total"/>
<setvar name="mnu_id" value="[0..1023]"/>  <!-- 固定長の配列を宣言 -->
```

**📱 Flutter**（`wapform_lazarus.dart`：`setvar()`；`wapform_expression.dart`：`WapEvaluator.setVar()`）

```dart
void setvarDemo() {
  setvar("TempTotal", "TempTotal+sn.Total");     // value は式
  setvar("mnu_id", "[0..1023]");                 // 固定長の配列を宣言
  setvar("mnu_id[3]", "mnu.pno");                // 配列要素に書き込む
  setvar("sh.amount", "TempTotal");              // データセットのフィールドに書き込む
  if (condition("qty>0")) setvar("OK", "1");     // cnd=
  _ev.setVar("USER_INPUT", "O'Brien");           // Dart の値を式を通さずそのまま格納
}
```

| `name` の書き方 | 動作 |
|---|---|
| `X` | 変数を設定 |
| `X[i]` | 配列要素を設定。`i` は式で、配列が足りなければ自動で延長（`null` で埋める） |
| `ds.フィールド` | `ds` が登録済みかつ開いている場合：現在のレコードに書き込む（閲覧中なら先に自動で編集状態に入る）。そうでなければ変数名として扱う |

`setvar()` は変数を変更すると `varChangeHooks` の関数に通知し、画面を同期させます（7.7 節）。

#### `<setprop/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ✅

画面要素のプロパティ値（色、表示／非表示、タブのインデックスなど）を動的に設定し、実行時に条件に応じて UI の見た目を変えます。空要素です。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `name` | (必須) | 対象要素の id |
| `prop` | (必須) | 設定するプロパティ名（`enabled`、`Readonly`、`img`、`filter`、`ActivePageIndex` など） |
| `value` | (必須) | 新しいプロパティ値 |
| `cnd` | (任意) | 条件が成立したときだけ設定 |

```xml
<setprop name="$ID" prop="enabled" value="0" cnd="I=-1"/>
<setprop name="b0" prop="img" value="$(sys.GSWEB+'nopic.jpg')"/>
<setprop name="pagecontrol" prop="ActivePageIndex" value="0"/>
```

#### `<getprop/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ✅

画面要素の現在のプロパティ値を読み取って変数に格納します。`<setprop>` と対になるタグです。空要素です。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `name` | (必須) | 対象要素の id |
| `prop` | (必須) | 読み取るプロパティ名 |
| `result` | (必須) | 格納先の変数名 |

#### `<invoke/>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

データセットオブジェクトのメソッド（`First`／`Next`／`Edit`／`Post`／`GetBookmark` など）を呼び出します。データセットのカーソルとトランザクション状態を操作する主な手段で、メソッドの完全な一覧は第 7 章 7.7 節にあります。空要素です。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `instance` | (必須) | 対象データセットの `id` |
| `method` | (必須) | メソッド名 |
| `arg1`／`arg2`／`arg3` | (任意) | メソッドの引数（`locate` のキー値と照合オプションなど） |
| `params` | (任意) | 一部のメソッド（`GoToBookmark` など）はこれでブックマーク変数を渡す |
| `result` | (任意) | メソッドの戻り値を格納する変数名 |
| `cnd` | (任意) | 条件が成立したときだけ呼び出す |

```xml
<invoke instance="sn" method="GetBookmark" result="BookMark"/>
<invoke instance="sn" method="First"/>
<invoke instance="mnu" method="locate" arg1="'id'" arg2="[pa.gid]" arg3="[loCaseInsensitive,loPartialKey]"/>
<invoke instance="sn" method="GoToBookmark" params="BookMark"/>
```

**📱 Flutter**（`wapform_lazarus.dart`：`invoke(instance, method, {params, result})`）

```dart
void invokeDemo() {
  invoke("sn", "getbookmark", result: "BookMark");     // result=
  invoke("sn", "first");
  invoke("sn", "gotobookmark", params: _ev.getVar("BookMark")); // params=
  if (condition("sn.state<>'BROWSE'")) invoke("sn", "post");    // cnd=
}
```

| `method` | 説明 |
|---|---|
| `first`／`next`／`prior`／`last` | カーソルを移動 |
| `edit`／`insert`／`append`／`cancel`／`post`／`delete` | 編集状態（`post`／`delete` はデータセットへ書き戻す。データベースへの送信はデータセットの更新機構が処理する） |
| `disablecontrols`／`enablecontrols` | 画面更新の一時停止／再開（`beginwalk`／`endwalk` も同じ意味） |
| `getbookmark`／`gotobookmark`／`freebookmark` | ブックマーク |

メソッド名は大文字・小文字を区別しません。`invoke()` はデータセットが見つからないと `null` を返し、何もしません。`locate` と `refresh` に対応する `invoke` メソッドはありません。再検索には `db.query("ds", sql)` を使います。

---

### 4.7 レポート出力のタグ

#### `<report>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

データセットを 1 件ずつ反復して内容を出力します。レポートと Web のレイアウト描画の中核となるタグで、`<group>` と組み合わせてグループ小計を、`<page>` と組み合わせて改ページを制御します。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `dataset` | (必須) | 反復するデータセットの `id` |
| `rows` | (任意) | 1 ページあたりの固定行数。連続帳票の自動改ページに使う（12.11 節参照） |
| `dialog` | (任意) | グループ化ダイアログの基準フィールド。多階層のグループ化レポートでよく使う |

**よく使う子タグ：** `<setvar>`、`<group>`、`<page>`

```xml
<report dataset="sh" dialog="cno;sno">
  <group change="sh.cno">
    <setvar name="AMOUNT_SUM" value="0"/>
    <page>...</page>
  </group>
</report>
```

**📱 Flutter**（`wapform_report.dart`：`WapReport`、`WapPage`；`wapform_report_style.dart`；`report_web.dart`）

`<report dataset="sh">` は `WapReport` サブクラスとして書き、`WapPage` で表示します。実行順序：

```
initParams() → fetchFirst()
PREFIX → PAGEPREFIX
  ┌ 各行：グループ値が変わった？→ onGroupPrepare() → G1_PREFIX…G9_PREFIX
  │       RECORD → fetchNext()
  │       次の行でグループ値が変わる？→ fetchPrior() → G9_SUFFIX…G1_SUFFIX → fetchNext()
  └ wapLpp 行に達するごと（emitRow が数える）→ PAGESUFFIX → PAGEBREAK → PAGEPREFIX
最後のグループの SUFFIX → PAGESUFFIX → SUFFIX
```

| サブクラスで実装するもの | 説明 |
|---|---|
| `initParams()` | `wap.wapLpp`（1 ページの行数）、`wap.wapGroups`（グループの階層数、最大 9）、`wap.wapRow[i].tagPrefix`／`tagSuffix`（第 i 階層のブロック名） |
| `expression(int idx)` | 第 idx 階層のグループの値。値が変わるとグループが切り替わる（`<group change>` に対応） |
| `fetchFirst()`／`fetchNext()`／`fetchPrior()` | データの読み方。通常は `invoke()` ＋ `condition("ds.EOF")` |
| `parseBlock(String id)` | 各ブロックで何を出力するか |
| `onGroupPrepare()` | （任意）グループが切り替わる前の非同期の準備。たとえばそのグループの集計データを先に検索する |

| 呼び出せるもの | 説明 |
|---|---|
| `emitRow(html, {isHeader, isFooter})` | 1 行出力して行数を数え、`wapLpp` に達すると自動改ページし `PAGEPREFIX` を再出力 |
| `emit(text, {isHeader, isFooter, tag})` | 行数を数えずに出力（表の開始・終了部分） |
| `forcePageBreak()` | 強制改ページ |
| `buildHtml()` | レポート全体の HTML |
| `buildPdf({orient, paper, fontAsset})` | PDF を生成（Android）。Web では新しいタブを開いて印刷する |

> **注意：**`WapReport` 自身が `expression(int idx)` メソッドを持つため、`wapform_lazarus.dart` の最上位の `expression()` が隠れてしまいます。レポートクラス内で式を評価するには、`expandText(r"$(...)")`、`condition()`、または `currentEvaluator!.eval("...")` を使ってください。

`WapPage` は Web では iframe でプレビューし、印刷時は新しいタブを開いてブラウザーに渡します（`report_web.dart` の `openHtmlForPrint()`）。Android ではシステムの WebView でプレビューし、印刷時に PDF を生成します。画面用と印刷用のスタイルは `wapform_report_style.dart` の `reportCssScreen`／`reportCssPrint` から来ます。`dialog="cno;sno"` の条件入力は、Flutter では `WapFilter` で条件を受け取り、データセットを検索してからレポートを開きます。

#### `<group>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

`<report>`／`<crosstab>` 内のグループブロックです。`change` 属性がなければ 1 件ずつの出力（RECORD ブロック）を表し、`change` があればその式の値が変わったときだけこのブロックに入り直します。グループ小計や自動改ページによく使います。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `change` | (任意) | グループ化の基準となる式。値が変わったときだけ再度トリガーされる |

**よく使う子タグ：** `<setvar>`、内側の `<group>`（多階層のグループ化）、任意の出力内容

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

**📱 Flutter**（`wapform_report.dart`：`expression(idx)`、`G1_PREFIX`／`RECORD`／`G1_SUFFIX`）

`<group change="sh.cno">` が第 1 階層、`<group change="datetostr(sh.sdate)">` が第 2 階層で、最も内側の `change` のない `<group>` が `RECORD` です：

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
        emitRow(expandText(r"<tr><td colspan='2'>日計</td>"
            r"<td align='right'>$(FORMAT('%.0n',DAY_SUM))</td></tr>"), isFooter: true);
        break;
      case 'G1_SUFFIX':
        emitRow(expandText(r"<tr><td colspan='2'>小計</td>"
            r"<td align='right'>$(FORMAT('%.0n',AMOUNT_SUM))</td></tr>"), isFooter: true);
        break;
      case 'PAGESUFFIX':
        emit('</table>');
        break;
    }
  }
}

Future<void> showStatement() async {
  await db.query("sh", "select * from sh order by cno, sdate");   // グループのフィールドで並べ替える
  if (!mounted) return;
  await Navigator.push(context, MaterialPageRoute(
    builder: (_) => WapPage(title: "売掛金明細書", report: StatementReport()),
  ));
}
```

グループが切り替わるとき、エンジンはまず `fetchPrior()` で前のグループの最後の行に戻ってから `G?_SUFFIX` を出力します。そのため小計行の `sh.cname` はまだ前のグループの顧客です。

#### `<newpage/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（Web はページ送りボタン／URL パラメーターで物理的な改ページを代替） | 📱 **Flutter** ✅

空要素で、強制的に改ページします。行数固定の連続帳票で改ページを手動制御するのによく使われます（14.7 節参照）。属性はありません。

**📱 Flutter**（`wapform_report.dart`：`forcePageBreak()`）

```dart
// WapReport サブクラスの parseBlock() の一部：顧客ごとに新しいページから始める
void newPageDemo(String id) {
  if (id == 'G1_PREFIX' && condition("not(cu.bof)")) forcePageBreak(); // <newpage cnd="not(cu.bof)"/>
}
```

`forcePageBreak()` は `PAGESUFFIX` → `PAGEBREAK` → `PAGEPREFIX` を順に出力します。そのページにまだ明細がなければ空白ページは作られません。通常は手動で改ページする必要はなく、`emitRow()` が `wap.wapLpp` 行まで数えると自動で改ページします。

#### `<varblock/>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

HTML を名前付きの変数に少しずつ蓄積し、テンプレートの最後で `$(varname)` により一度に挿入します。逐次出力の代わりに使います（第 9 章の varblock による事前蓄積注入を参照）。空要素です。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `name` | (必須) | 蓄積先の変数名 |
| `block` | (必須) | 追加するコンテンツブロック名 |

```xml
<report dataset="mnu">
  <varblock name="footer" block="footer.aa"/>
  <varblock name="footer" block="footer-item"/>
  <varblock name="footer" block="footer.zz"/>
</report>
```

#### `<debug/>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ⚠️

開発時の補助タグで、レポートエンジンの現在の座標と累計状態（`$row,$col;$K,$(X[K])` など）を出力します。公開前に取り除いてください。属性はありません。

**📱 Flutter**（`wapform_expression.dart`：`getUserVars()`、`hasError`／`lastError`；`wapform_lazarus.dart`：`DataSetRegistry.registeredIds`）

```dart
void debugDump() {
  debugPrint(expandText(r"$K,$(X[K])"));         // 指定した値
  debugPrint("${_ev.getUserVars()}");            // すべてのユーザー変数
  debugPrint("datasets: ${_reg.registeredIds}"); // 登録済みのデータセット
  _ev.eval("1>0 AND 2>1");
  if (_ev.hasError) debugPrint(_ev.lastError);   // 式のエラー原因
}
```

`expression()`／`condition()` がエラーになると、コンソールに `[ERROR] 式 # 原因` が自動的に出力されます。

---

### 4.8 クロス集計とチャートのタグ

#### `<crosstab>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ❌

宣言型のクロス集計（ピボット分析）です。行グループ、列グループ、交差セルの集計で複雑なレポートを記述し、外部のレポートツールを不要にします。詳しくは第 13 章を参照してください。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `dataset` | (必須) | 取得元データセット |
| `field` | (必須) | クロス集計する数値フィールド |
| `dialog` | (任意) | ダイアログの基準フィールド |
| `autospan` | (任意) | `yes` のとき、同じグループ値の見出しセルを自動で結合 |

**よく使う子タグ：** `<row change>`、`<col change>`、内側の `<group>`

```xml
<crosstab dataset="xy" dialog="cno;sdate" field="amount" autospan="yes">
  <row change="xy.cno">...</row>
  <col change="xy.YM">...</col>
</crosstab>
```

#### `<row>` / `<col>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ❌

`<crosstab>` 内で行グループと列グループをそれぞれ定義します。`change` 属性の意味は `<group change>` と同じで、多階層にネストできます。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `change` | (任意) | グループ化の基準となる式 |

#### `<chart>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（Web では Chart.js などのフロントエンドのチャートライブラリで代替することが多い） | 📱 **Flutter** ❌

宣言型のチャート出力です。開発者は JavaScript を書かずに対話型のチャートを作れます。すべての属性は第 10 章 10.3 節を参照してください。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `title` | (任意) | チャートのタイトル |
| `dataset` | (任意) | バインドするデータセット名（データセット駆動モード） |
| `rangeto` | (任意) | 軸の最大目盛り値 |
| `legend` | (任意) | `yes` で凡例を表示 |
| `autocolor` | (任意) | `yes` で各データポイントに自動で異なる色を適用 |
| `xaxisposition` / `yaxisposition` | (任意) | 座標軸の表示位置。`none` で非表示 |
| `titlefontsize` | (任意) | タイトルのフォントサイズ（ポイント） |
| `xresult` | (任意) | チャートの出力結果を指定した変数に格納 |

**よく使う子タグ：** 1 つ以上の `<serie>`

#### `<serie>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ❌

`<chart>` 内で 1 つのデータ系列を定義します。すべての属性は第 10 章 10.4 節を参照してください。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `type` | (必須) | チャートの種類。全 12 種（完全な例は第 10 章 10.6 節）：折れ線系 `line`／`digitalline`、棒系 `bar`／`stackedbar`／`histogram`、面系 `area`／`stackedarea`、円系 `pie`／`donut`／`sizedpie`／`sizeddonut`、レーダー系 `spider` |
| `title` | (任意) | 系列名（凡例に表示） |
| `color` | (任意) | 塗りつぶし色（`#RRGGBB`） |
| `linecolor` / `linewidth` | (任意) | 線の色／太さ（line 系） |
| `opacity` | (任意) | 不透明度 0–255（area 系） |
| `marker` | (任意) | `yes` でデータポイントのマーカーを表示（line 系） |
| `valuewidth` | (任意) | データポイントの幅（bar 系） |
| `fieldnamevalue` / `fieldnamexaxis` | (任意) | データセット駆動モードの値／X 軸のフィールド |
| `pielegend`／`pieposition`／`pieleft`／`pietop`／`piesize`／`pieshowvalues`／`pieshowlegendonslice`／`pievalueposition` | (任意) | 円／ドーナツ系専用の属性 |

**よく使う子タグ：** 1 つ以上の `<point>`（プログラム生成モード）

#### `<point/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ❌

`<serie>` 内の 1 つのデータポイントで、通常は `<while>` や `<for>` ループ内で動的に生成します。空要素です。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `label` | (必須) | X 軸のラベルまたは凡例名。式を使える |
| `value` | (必須) | Y 軸の値。式を使える |
| `color` | (任意) | 個々のデータポイントの色 |

```xml
<chart title="line" rangeto="11" legend="yes">
  <serie type="line" linecolor="#f37735" linewidth="2" marker="yes">
    <point label="1月" value="120"/>
    <point label="2月" value="95"/>
  </serie>
</chart>
```

---

### 4.9 ナビゲーションとメニューのタグ

#### `<include/>`

🖥️ **Win** ⚠️ | 🌐 **Web** ✅ | 📱 **Flutter** ⚠️

別の名前付き card の出力を取り込みます。Web テンプレートの共通部品（`header`／`footer`／`asider`）の中核となる仕組みです。詳しくは第 9 章、第 15 章を参照してください。空要素です。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `name` | (必須) | 対象 card の `id` |

```xml
<include name="header"/>
```

#### `<redirect/>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

空要素で、別の URL や `.wml` へ移動します。ログイン認証の失敗時やフロー終了後の遷移によく使われます。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `href` | (必須) | 移動先の URL または `.wml` |

```xml
<redirect href="index.wml"/>
```

#### `<mainmenu>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

Windows の MDI メインウィンドウのメニューバーを定義します。通常は `device="MDI"` のメイン card に置きます。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `images` | (任意) | メニューアイコンのリスト（imagelist）の名前 |

**よく使う子タグ：** 1 つ以上の `<menuitem>`（ネストするとサブメニューになる）

#### `<menuitem>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

`<mainmenu>` の下のメニュー項目で、ネストして多階層のメニューを作れます。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `name` | (任意) | 要素の id。`<setprop>` で動的に制御する（無効化など）ために使う |
| `caption` | (必須) | 表示テキスト。式を使える |
| `hint` | (任意) | ヒントテキストまたは分類マーク |
| `imageindex` | (任意) | `images` のアイコンリストのインデックス |
| `onclick` | (任意) | クリック時の移動先（メニュー項目に対応する `href` など） |

**よく使う子タグ：** 内側の `<menuitem>`（サブメニュー）

```xml
<mainmenu images="imagelist1">
  <menuitem caption="販売業務" hint="sub">
    <menuitem name="A001" caption="出荷伝票入力" hint="app006.wml"
              imageindex="1" onclick="app006.wml"/>
  </menuitem>
</mainmenu>
```

#### `<tabsheet>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（Web は Bootstrap のタブ部品で手作業で実装） | 📱 **Flutter** ✅

タブのコンテナで、複数タブの検索フォームや、入力ページで表示モードを切り替える場面によく使われます。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `caption` | (必須) | タブの見出し |

**よく使う子タグ：** 任意のレイアウトタグと入力タグ（そのタブの内容）

#### `<pagecontrol>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ✅

`<tabsheet>` の外側のコンテナで、複数のタブ間の切り替えを管理します。`<setprop prop="ActivePageIndex">` と組み合わせて、表示中のタブを動的に切り替えられます。

**よく使う子タグ：** 1 つ以上の `<tabsheet>`

---

### 4.10 システム連携のタグ

#### `<mail>`

🌐 **Web** ✅ | 🖥️ **Win** ❌（Win は `<shellexecute>` で `mailto:` を呼び出して代替。14.9 節参照） | 📱 **Flutter** ❌

サーバーサイドから直接メールを送信します。ユーザーのローカルにメールソフトは不要です。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `to` | (必須) | 宛先 |
| `subject` | (任意) | 件名 |
| `body` | (任意) | 本文 |

#### `<shellexecute/>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

OS レベルの外部プログラムやプロトコルを呼び出します。既定のメールソフトを開く（`mailto:`）、外部アプリケーションを起動する、といった用途によく使われます。空要素です。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `operation` | (必須) | 通常は `open` |
| `file` | (必須) | 対象のパスまたはプロトコル URL |

```xml
<shellexecute operation="open" file="mailto:$(cu.email)?subject=出荷のお知らせ"/>
```

#### `<webcopy/>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

`protocol` 属性に応じて、ローカルのファイルシステム、HTTP、FTP の間でファイルを転送します。Windows 側で唯一の組み込みファイル転送手段で、`<open/>` と組み合わせて「ファイル選択 → アップロード」の画像管理フローによく使われます。空要素です。プロトコルごとの動作、`host`/`url`/`dir` の対照表、実践例は第 12 章を参照してください。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `protocol` | (任意、既定 `file`) | `file`／`httpupload`／`httpdownload`／`ftpupload`／`ftpdownload` のいずれか |
| `host` | プロトコルによる | 意味は `protocol` によって変わる（保存先ディレクトリ／アップロード先 URL／取得元 URL／FTP ホスト） |
| `url` | プロトコルによる | 意味は `protocol` によって変わる（取得元パス／ローカルファイルのパス／FTP 上のファイル名） |
| `dir` | プロトコルによる | 意味は `protocol` によって変わる（保存先ディレクトリ／FTP 上のディレクトリ）。`file`／`httpupload` プロトコルでは使わない |
| `username` / `password` | FTP プロトコルでは必須 | FTP のログインアカウントとパスワード |
| `unique` | (任意) | この属性があれば `true` を意味する：タイムスタンプで自動命名し、名前が重なれば連番を付け、既存ファイルを上書きしない |
| `result` | (任意) | 成功時は保存／アップロード後のファイル名、失敗時はエラーメッセージを書き込む |
| `errmsg` | (任意) | 失敗時はエラーメッセージを書き込み、成功時は空文字列にする |
| `response` | (任意、`httpupload` のみ有効) | サーバー応答の生の内容を書き込む |

#### `<open/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ⚠️

属性の組み合わせによってまったく異なる 2 つの用途に分かれ、属性を混用することはできません：

| 用途 | 属性 | プラットフォーム | 説明 |
|---|---|---|---|
| 別の card をポップアップ | `href` (必須) | 🖥️ **Win** ✅ \| 🌐 **Web** ⚠️ \| 📱 **Flutter** ⚠️ | 別の card をポップアップウィンドウとして開く。`href` は対象 card の `id`（`#id` と書くことが多い）。`<include>` との違いは、出力を埋め込むのではなく独立したウィンドウ／ダイアログを作る点 |
| システムのファイル選択ダイアログ | `filename` (必須)、`result` (必須) | 🖥️ **Win** ✅ \| 🌐 **Web** ❌ \| 📱 **Flutter** ⚠️ | OS ネイティブの「ファイルを開く」ダイアログを表示する。`filename` にはユーザーが選んだフルパス、`result` にはユーザーが確定したかどうか（`1` で確定）を書き込む。詳しくは第 12 章 12.1 節 |

#### `<upload/>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

サーバーサイドで生の HTTP `PUT` リクエストを受け取って保存します。リクエストボディ全体がファイルそのもののバイト列で、multipart の包みもファイル名もなく、従来の `upload.php` の受け取り方と互換です。空要素です。ファイル名の決定順序、Content-Type の推定、セキュリティ機構の詳細は第 11 章 11.2 節を参照してください。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `destination` | (必須) | 保存先ディレクトリ |
| `filename` | (任意) | 固定の保存ファイル名。空なら `Content-Disposition` ヘッダーまたはタイムスタンプで決める |
| `accept` | (任意) | 許可する拡張子のホワイトリスト（カンマ区切り）。空なら制限なし |
| `unique` | (任意) | `yes` のとき、名前が重なれば自動で連番を付けて上書きを防ぐ（`nameconflict="unique"` と同じ意味） |
| `result` | (任意) | エラーメッセージ／状態を書き込む変数 |
| `size` | (任意) | 受信したバイト数を書き込む変数 |
| `savedname` | (任意) | 実際に保存されたファイル名を書き込む変数 |

#### `<multiupload>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

サーバーサイドで、ブラウザーの `<form enctype="multipart/form-data">` から送られた複数ファイルのアップロード要求を受け取ります。コンテナ要素で、ファイルを 1 つ保存するたびに子ノードを 1 回実行するため、ページでファイルごとにサムネイルを表示したりデータベースに書き込んだりできます。完全な例とエンジンの規則は第 11 章 11.1 節を参照してください。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `filefield` | (必須) | `<input type="file" name="...">` に対応するフィールド名 |
| `destination` | (必須) | 保存先ディレクトリ |
| `filename` | (必須) | 保存後のファイル名を書き込む変数（ループ内でファイルごとに更新） |
| `srcname` | (任意) | ユーザー側の元のファイル名を書き込む変数 |
| `index` | (任意) | 現在何番目のファイルか（1 から数える）を書き込む変数 |
| `count` | (任意) | アップロード終了後、保存に成功したファイルの総数を書き込む変数 |
| `result` | (任意) | エラーメッセージを書き込む変数。すべて成功なら空文字列 |
| `accept` | (任意) | 許可する拡張子のホワイトリスト（カンマ区切り）。空なら制限なし |
| `nameconflict` | (任意) | 名前が重なったときの方針。`unique` はタイムスタンプと連番を自動で付けて上書きを防ぐ |

---

### 4.11 Web 専用タグ

#### `<wap>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

Web 環境で生の HTML／テキストをそのまま出力するコンテナです。内部で `$()` 補間式を使えます。AJAX で部分的に読み込むコンテンツ card によく使われます（15.5 節 `book-js.wml` 参照）。

**よく使う子タグ：** 通常は `<![CDATA[ ]]>` で HTML の断片を包む

```xml
<wap><![CDATA[
  $pa.topic
  <div>$pa.pno</div>
]]></wap>
```

**📱 Flutter**（`wapform_report.dart`：`WapPage(src:)`；`wapform_lazarus.dart`：`expandText()`）

```dart
Widget wapBlock() => WapPage(
      title: "Topic",
      src: r'$pa.topic <div>$pa.pno</div>',      // 先に expandText() してから HTML として表示
      showPrint: false,
    );
```

`src` は `expandText()` を通るため、内容に `$` の文字を出力したいときは `$$` と書きます。

#### `<session/>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

サーバーサイドの Session 状態に書き込むタグで、文法は `<setvar>` に対応する空要素です。ユーザーのログイン状態やショッピングカートの連番など、ページをまたぐリクエストで保持すべき値を維持します。`<setsession>` は同じタグの別名で、動作はまったく同じです。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `name` | (必須) | Session 変数名 |
| `value` | (必須) | 書き込む値。**空文字列 `''` を設定するとその変数を削除** |
| `expire` | (任意) | この変数の有効期間。単位は**分**。省略＝期限なしで、session 全体の寿命に従う。`expire="0"`＝既存の期限設定を解除。**2026-09 以降のエンジンが必要**で、旧版はこの属性を無視する（省略と同じ動作） |
| `cnd` | (任意) | 条件式。成立したときだけ書き込む |

```xml
<session name="usr" value="A"/>              <!-- A はユーザーが入力したアカウント -->
<session name="ord" value="''"/>             <!-- ショッピングカートの連番を消去 -->
<session name="usr" value="A" expire="480"/> <!-- 8 時間後に自動で失効 -->
<session name="lang" value="'tw'" cnd="DEFINE(request.lang)"/>
```

読み取り側では `<session>` タグを使わず、式の中で `session.フィールド` のプレフィックスで読みます（`session.usr`、`session.ord` など）。書き方は `sys.*`、`request.*` といった属性プレフィックスと同じです。詳しくは第 7 章 7.4 節を参照してください。

**変数ごとの期限：`expire` 属性**

同じ session 内の変数は、それぞれ独自の有効期間を持てます。エンジンは各 HTTP リクエストでカードを解析する**前に**期限切れの変数を消去します——そのためカード内の `DEFINE(session.xxx)` からは期限切れの値が自然に見えなくなり、ページごとにタイムアウトを判定する必要はありません。

```xml
<!-- ログイン状態は 8 時間、ショッピングカートの一時保存は 2 時間だけ -->
<session name="usr" value="A"   expire="480"/>
<session name="ord" value="S"   expire="120"/>

<!-- 後で延長したい場合は同じ変数に書き込み直せばよく、期限はその時点から計算し直される -->
<session name="usr" value="session.usr" expire="480"/>
```

よく使う換算：`60`＝1 時間、`480`＝8 時間、`1440`＝1 日、`10080`＝7 日、`43200`＝30 日。

`<delsession>` で変数を削除すると、付随する期限のタイムスタンプも一緒に消去されます。`<clearsession>` で session 全体を消去した場合も当然含まれます。

**Session の 3 層の寿命**

`expire` は変数を「早く」失効させることしかできず、その上に WML からは越えられない上限が 2 つあります：

| 層 | 制御方法 | 既定 | 動作 |
|---|---|---|---|
| session 変数 | `<session expire="分"/>` | 期限なし | 変数ごとに計時し、期限が来たら削除 |
| ブラウザーの cookie | サーバー設定 | ブラウザーを閉じると失効 | ユーザーが「戻ってこられる」期限を決める |
| サーバーの session | サーバー設定 | 7 日間アイドルで回収 | **アイドル**時間が超えたときだけ回収。リクエストのたびに計時がリセットされる |

session のデータはサーバーのメモリに置かれるため、**サーバーを再起動するとすべて消えます**。したがって `expire` を cookie やサーバーの回収時間より長く設定しても意味がありません——ユーザーは先に cookie の失効や session の回収でログアウトしてしまいます。設計は最も短い層から逆算してください。

#### `<operator>`

🌐 **Web** ✅ | 🖥️ **Win** ⚠️ | 📱 **Flutter** ❌

Web テンプレートの計算補助タグで、テンプレートのブロック間で簡単な計算結果を受け渡し、HTML に `$()` 式を埋め込みすぎないようにします。

---

### 4.12 HTML テキストとレイアウトのタグ

📱 **Flutter**：本節のタグはすべて ❌ 対象外です。WapForm for Flutter がエクスポートするのはネイティブの Dart／Flutter のウィジェットツリーで、HTML を経由しません。本節に挙げる埋め込み HTML タグは、Web 版の出力内容と HTML テンプレートファイルにしか存在しないため、以下の表では表記を繰り返しません。

WML の出力内容（`<wap>`、`<varblock>`、レポートのセル、`<fieldset>` 内の説明文のいずれでも）には、標準の HTML タグを直接埋め込めます。以下は本書で実際に使っているよく使うタグを用途別に分類したものです。

#### テキスト効果のタグ（inline）

| タグ | 説明 |
|---|---|
| `<b>...</b>` | 太字 |
| `<i>...</i>` | 斜体 |
| `<u>...</u>` | 下線 |
| `<small>...</small>` | 小さい文字。注記や単位によく使う |
| `<big>...</big>` | 大きい文字 |
| `<ins>...</ins>` | 挿入内容の注記／強調。備考欄で変更箇所を示すのによく使う |
| `<span class="...">...</span>` | インラインのコンテナ。既定のスタイルはなく、`class` や `style` で見た目を制御する |
| `<br/>` | 強制改行。空要素 |
| `<hr/>` | 水平の区切り線。空要素 |

```xml
<p>単価：<b>$(FORMAT('%.2n',od.price))</b>　<small>（税抜）</small></p>
<span class="text-danger">期限超過・未回収</span><br/>
```

#### レイアウトコンテナのタグ（block）

| タグ | よく使う属性 | 説明 |
|---|---|---|
| `<div class="...">...</div>` | `class`、`id`、`style` | ブロックコンテナ。Web レイアウトを区切る主なコンテナ |
| `<section style="...">...</section>` | `style`、`class` | HTML5 の意味的なブロックコンテナ。`$()` 式で `style` を動的に計算する組み合わせが多い（第 9 章 9.10 節のブロック間の状態関数 `var()`／`inc()` 参照） |
| `<p align="...">...</p>` | `align` | 段落 |
| `<article>...</article>` | — | 意味的なコンテンツブロック。マニュアルや記事の本文に使う（15.5 節のマニュアル本文参照） |
| `<h1>...</h1>` ～ `<h6>...</h6>` | — | 見出しのレベル。数字が小さいほど文字が大きい |

```xml
<div class="card p-3">
  <h4>顧客情報</h4>
  <p align="left">$(cu.cname)</p>
</div>

<!-- section と var()/inc() を組み合わせて、循環して変わる背景色を作る -->
<section style="background-color:$('#'+COLOR2HEX(color[inc('idx',1) mod 5]));">
  ...
</section>
```

#### 表のタグ

| タグ | よく使う属性 | 説明 |
|---|---|---|
| `<table>...</table>` | `class`、`width`、`border`、`cols`、`columns`、`rows` | 表のコンテナ。`rows` は連続帳票の固定行数によく使う（14.7 節参照） |
| `<tr>...</tr>` | — | 表の行 |
| `<th>...</th>` | `align`、`width` | 見出しセル |
| `<td>...</td>` | `align`、`valign`、`class`、`width`、`colspan`、`rowspan` | データセル。`colspan`／`rowspan` でセルを結合する（12.11 節の列をまたぐ合計参照） |

```xml
<table class="wap" width="100%" border="1" rows="40">
  <tr>
    <th>伝票番号</th><th>金額</th>
  </tr>
  <tr>
    <td>$(rpt_data.work_order_no)</td>
    <td align="right">$(FORMAT('%.2n',rpt_data.order_price))</td>
  </tr>
  <tr>
    <td colspan="4">作成者:$aa.prepared_by</td>
  </tr>
</table>
```

**📱 Flutter**（`wapform_report.dart`、`wapform_report_style.dart`、`wapform_colors.dart`）

レポートと `WapPage(src:)` が出力するのは HTML なので、本節の `<table>`／`<tr>`／`<td>` などのタグはそのまま使え、`class="wap"` の書式は `wapform_report_style.dart` が提供します（画面用 `reportCssScreen`、印刷用 `reportCssPrint`）。`class="row1"`／`"row2"` などの交互の行の色は、Flutter の画面では `WapColors` から同じ色を取得できます：

```dart
Future<Color> stripe(int i) async {
  await WapColors.load();                        // assets/wapform.htm の CSS を読む。読めなければ組み込みの既定値
  return i.isEven ? WapColors.trRow1 : WapColors.trRow2;  // または WapColors.flutter("row2")
}
```

`WapColors.hex("row2")` は CSS のカラーコードを返すので、レポートの HTML に直接書き込めます。

#### リストのタグ

| タグ | 説明 |
|---|---|
| `<ul>...</ul>` | 順序なしリストのコンテナ |
| `<ol>...</ol>` | 順序付きリストのコンテナ |
| `<li>...</li>` | リスト項目。`<ul>`／`<ol>` の子タグでなければならない |

```xml
<ul>
  <li>$(itm.title)</li>
</ul>
```

#### リンクとメディアのタグ

| タグ | よく使う属性 | 説明 |
|---|---|---|
| `<a href="...">...</a>` | `href`、`class`、`op`、`pg`、`gp`、`az` | ハイパーリンク。Web 版のメニューやページ送りのリンクでは `href` の後に独自のクエリパラメーター（`op`、`pg`、`gp`、`az`）を付けることが多い。例：ページ送りリンク `shop.wml?op=$op&gp=$gp&pg=$K&az=$az` |
| `<img src="..." />` | `src`、`width`、`height`、`border`、`id` | 画像。空要素。`src` は `sys.GSWEB`／`sys.images` と組み合わせて完全なパスを作ることが多い |
| `<link rel="..." href="..." />` | `rel`、`href` | 外部スタイルシートやリソースへのリンク。HTML テンプレートの `<head>` で使う |
| `<script>...</script>` | `src`（外部）または埋め込み JS | JavaScript を埋め込むか読み込む。`loadDoc()` の定義と呼び出しなど（15.5 節参照） |

```xml
<a href="javascript:loadDoc('book-js.wml?pg=$itm.pno')">$itm.des</a>
<img src="$(sys.GSWEB+pa.pic1)" width="120" border="0"/>
```

#### ドキュメント構造のタグ（Web の HTML テンプレートでのみ使用）

| タグ | 説明 |
|---|---|
| `<html>...</html>` | HTML ドキュメントのルートコンテナ |
| `<head>...</head>` | ドキュメントのヘッダー。`<title>`、`<link>`、`<script>` を含む |
| `<body>...</body>` | ドキュメントの本体 |
| `<title>...</title>` | ブラウザーのタイトルバーの文字 |

これらのタグは Web 版の HTML テンプレートファイル（`wapform.html` など）自体にのみ現れます。通常の `.wml` card の出力内容はテンプレートの既存の `<body>` ブロックに埋め込まれるため、繰り返し宣言する必要はありません。

---

### 4.13 タグ早見表

| 分類 | タグ |
|---|---|
| ドキュメントとレイアウト | `wml`、`card`、`page`、`section`、`fieldset` |
| データアクセス | `dbquery`、`dbtable`、`field`、`dbfilter` |
| データバインドとリスト | `datasource`、`dbgrid`、`item`、`navigator`、`column` |
| フォーム入力と対話 | `input`、`do`、`prev`、`alert`、`prompt` |
| フロー制御 | `if`／`elseif`／`else`、`switch`／`case`／`default`、`while`、`for`、`go`、`exit`、`function`、`block`、`platform` |
| 変数とデータセット操作 | `setvar`、`setprop`、`getprop`、`invoke` |
| レポート出力 | `report`、`group`、`newpage`、`varblock`、`debug` |
| クロス集計とチャート | `crosstab`、`row`、`col`、`chart`、`serie`、`point` |
| ナビゲーションとメニュー | `include`、`redirect`、`mainmenu`、`menuitem`、`tabsheet`、`pagecontrol` |
| システム連携 | `mail`、`shellexecute`、`webcopy`、`open`、`upload`、`multiupload` |
| Web 専用 | `wap`、`session`、`operator` |
| HTML テキスト効果 | `b`、`i`、`u`、`small`、`big`、`ins`、`span`、`br`、`hr` |
| HTML レイアウトコンテナ | `div`、`p`、`article`、`h1`–`h6` |
| HTML 表 | `table`、`tr`、`th`、`td` |
| HTML リスト | `ul`、`ol`、`li` |
| HTML リンクとメディア | `a`、`img`、`link`、`script` |
| HTML ドキュメント構造（テンプレートファイルのみ） | `html`、`head`、`body`、`title` |

各タグの完全な使用場面と実例は、第 3 章のコアパターン、第 11～16 章の実践例と照らし合わせて読んでください。

📱 **Flutter 対応状況の総覧**（前述の各節で 1 つずつ表記。詳しい根拠は「プラットフォーム対応表記の説明」参照）：まったく対応していないのは 2 種類だけです——**クロス集計**（`crosstab`／`row`／`col`）と**チャート**（`chart`／`serie`／`point`）で、モバイルデバイスの表示上の制約により、どの有償エディションでも対応していません。**Web 専用タグ**（`wap`、`session`、`operator`）と Web 版にしかないシステム連携タグ（`mail`、`upload`、`multiupload`）、テンプレート機構（`varblock`、`redirect`、`block`）も対応していません。Flutter がエクスポートするのは Windows のコンポーネントモデルであり、Web のテンプレート機構ではないためです。その他のフォーム、データ、マスター・ディテール構造、Lookup、計算フィールド、イベント、動的クエリ、レポートのグループ化と改ページ、複数タブといったコア機能はすべて対応しています。Windows デスクトップ専用のタグや、本書で公式サイトの資料から確認できなかった少数のタグ（`column`、`prompt`、`debug`、`mainmenu`／`menuitem`、`include`、`shellexecute`、`webcopy`、`open` など）は ⚠️ としています。実際の動作は `wapform_flutter` の生成結果で確認してください。

**📱 Flutter モジュール対照表**（対応モジュールのあるタグのみ）

| タグ | モジュール | API |
|---|---|---|
| `card`（`device="PRV"`／`"PRN"`）、`page` | `wapform_report.dart` | `WapPage`、`PAGEPREFIX`／`PAGESUFFIX` |
| `dbquery`、`dbtable` | `wapform_lazarus.dart` | `DbQuery.query()`／`exec()`、`DataSetRegistry` |
| `dbfilter`、`item`（フィルター） | `wapform_filter.dart` | `WapFilter`、`FilterItem` |
| `input lookup`、`item lookup` | `wapform_lookup_box.dart` | `WapLookupBox` |
| `if`、`switch`、`while` | `wapform_lazarus.dart` | `condition()`、`expression()` |
| `setvar`、`invoke` | `wapform_lazarus.dart` | `setvar()`、`invoke()` |
| `report`、`group`、`newpage` | `wapform_report.dart` | `WapReport`、`expression(idx)`、`forcePageBreak()` |
| `debug` | `wapform_expression.dart` | `getUserVars()`、`lastError` |
| `wap` | `wapform_report.dart` | `WapPage(src:)` |
| `platform` | （ジェネレーター） | `name="flutter"` ブロックがそのまま Dart コードになる |
| `$(...)` 補間 | `wapform_lazarus.dart` | `expandText()`、`expandSql()`、`expandSqlAuto()`、`expandSqlQuoted()` |

---

---

## 第 5 章　配列

## 5.1 宣言

WapForm の配列は `<setvar>` で設定する特殊な Variant 値で、3 種類の宣言の書き方があります：

### 範囲宣言（固定長をあらかじめ確保）

```xml
<!-- 整数の範囲。要素の初期値は 0 -->
<setvar name="X" value="[1..999]"/>
<setvar name="P" value="[0..1023]"/>
<setvar name="L" value="[1..26]"/>
```

宣言後は `X[i]` で配列にアクセスできます。下限は範囲の開始値（`1` または `0`）で、`low(X)` / `high(X)` は下限 / 上限を返します。

### リテラル宣言（初期内容を直接指定）

```xml
<!-- 整数の配列 -->
<setvar name="L" value="[31,28,31,30,31,30,31,31,30,31,30,31]"/>

<!-- 文字列の配列 -->
<setvar name="P" value="['代引','店頭受取','月締め','振込']"/>

<!-- カラーコードの配列 -->
<setvar name="C" value="['#ffeeee','#fff4ea','#ffffe3','#ebffec','#f1f4ff']"/>

<!-- 数値の配列 -->
<setvar name="myArray" value="[1, 2, 3, 4, 5]"/>
```

リテラル配列の下限は `0`、上限は要素数から 1 を引いた値です。

### 空の配列

```xml
<!-- すべて空文字列 -->
<setvar name="VR" value="['','','','','','','','','','','','','','','']"/>

<!-- すべてゼロ -->
<setvar name="XV" value="[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"/>
```

**📱 Flutter**（`wapform_lazarus.dart`：`setvar()`；`wapform_expression.dart`：`WapEvaluator.setVar()`）

3 種類の宣言の書き方はそのまま `setvar()` に書きます。Dart 側に既にある `List` は `_ev.setVar()` でエンジンに入れます：

```dart
void declareArrays() {
  setvar("X", "[1..999]");                                        // 範囲宣言、初期値 0
  setvar("L", "[31,28,31,30,31,30,31,31,30,31,30,31]");          // リテラル
  setvar("P", "['代引','店頭受取','月締め','振込']");
  setvar("VR", "['','','','','']");                               // 空の配列
  _ev.setVar("N", [10, 20, 30]);                                  // Dart の List
}
```

Dart の配列は 0 から始まります。範囲宣言 `[1..26]` はインデックス 0～26 の 27 要素を作るため、もともと 1 から始まるインデックスはそのまま使えますが、`LOW(X)` は 0 を返します。

---

## 5.2 アクセス

### 要素の読み取り

```xml
<!-- 式の中で直接インデックス指定 -->
<setvar name="days" value="L[month-1]"/>
<td>$(C[i MOD 5])</td>
<setvar name="sp" value="spec[j]"/>

<!-- 出力の中で補間 -->
<p>1 番目の要素：$(myArray[0])</p>
<p>3 番目の要素：$(myArray[2])</p>
```

### 要素への書き込み

```xml
<setvar name="X[K]" value="X[K]+N"/>
<setvar name="C[0]" value="'#ffeeee'"/>
<setvar name="mnu_title[k]" value="mnu.title"/>
```

インデックスには、変数や関数の戻り値を含む任意の整数式を使えます。

**📱 Flutter**（`wapform_lazarus.dart`：`expression()`、`setvar()`、`expandText()`）

```dart
void arrayAccess() {
  setvar("days", "L[month-1]");
  final td = expandText(r"<td>$(C[i MOD 5])</td>");
  setvar("X[K]", "X[K]+N");
  setvar("C[0]", "'#ffeeee'");
  debugPrint(td);
}
```

長さを超えるインデックスに書き込むと配列は自動で延長されます（間は `null` で埋められる）。この点は「上限を超えるとエラー」になる Windows 版と異なります。

---

## 5.3 配列関数

| 関数 | 説明 | 備考 |
|---|---|---|
| `low(arr)` | 配列の下限インデックスを返す | リテラル配列は `0`、範囲宣言は開始値 |
| `high(arr)` | 配列の上限インデックスを返す | つまり最後の有効なインデックス |
| `COUNT(arr)` | 配列の要素数を返す | `high(arr) - low(arr) + 1` に等しい |

```xml
<!-- すべての要素をたどる -->
<for int="i" from="low(spec)" to="high(spec)">
  <setvar name="sp" value="spec[i]"/>
  <block name="spec-option" id="name(sp)" opt="value(sp)"/>
</for>

<!-- while でたどる（Win/Web どちらも可） -->
<setvar name="I" value="low(L)"/>
<while cnd="I&lt;=high(L)">
  <setvar name="total" value="total+L[I]"/>
  <setvar name="I" value="I+1"/>
</while>
```

**📱 Flutter**（`wapform_expression.dart`）

`LOW()`、`HIGH()`、`COUNT()` は通常どおり使えます。さらに可変長引数の集計関数 `ARRSUM`、`ARRAVG`、`ARRMAX`、`ARRMIN`、`ARRJOIN`（最後の引数が区切り文字）、`ARRUNIQ`、`ARRCONTAINS` があります。

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

## 5.4 `name()` / `value()` 関数

配列の要素が「キー=値」形式の文字列（`'色=赤'` など）の場合、`name()` / `value()` でキーと値を分解できます：

| 関数 | 説明 |
|---|---|
| `name(s)` | 文字列の `=` より前の部分（キー）を返す |
| `value(s)` | 文字列の `=` より後の部分（値）を返す |

```xml
<setvar name="spec" value="['色=赤','サイズ=XL','素材=綿']"/>
<for int="i" from="low(spec)" to="high(spec)">
  <setvar name="item" value="spec[i]"/>
  <!-- name(item) → '色' / value(item) → '赤' -->
  <block name="spec-row" label="name(item)" val="value(item)"/>
</for>
```

**📱 Flutter**（`wapform_expression.dart`：`NAME()`、`VALUE()`）

```dart
List<String> specRows() {
  setvar("spec", "['色=赤','サイズ=XL','素材=綿']");
  final rows = <String>[];
  setvar("i", "LOW(spec)");
  while (condition("i<=HIGH(spec)")) {
    setvar("item", "spec[i]");
    rows.add(expandText(r"$(NAME(item))：$(VALUE(item))"));   // 色：赤 …
    setvar("i", "i+1");
  }
  return rows;
}
```

---

## 5.5 カウンターとしての配列（レポートの累計）

レポート出力で最もよくある配列の使い方は**列ごとの累計**です。crosstab を例にします：

```xml
<!-- 列合計の配列と列総計の配列を宣言 -->
<setvar name="X" value="[1..999]"/>   <!-- グループ合計、グループごとにリセット -->
<setvar name="Y" value="[1..999]"/>   <!-- 全体の総計、リセットしない -->

<!-- crosstab の外側のグループの開始時に列合計をリセット -->
<row change="xy.cno">
  <setvar name="I" value="1"/>
  <while cnd="I&lt;=99">
    <setvar name="X[I]" value="0"/>
    <setvar name="I" value="I+1"/>
  </while>
  ...
  <!-- セルごとに累計 -->
  <setvar name="K" value="K+1"/>
  <setvar name="X[K]" value="X[K]+N"/>
  <setvar name="Y[K]" value="Y[K]+N"/>
</row>

<!-- グループ小計の行を出力 -->
<setvar name="I" value="1"/>
<while cnd="I&lt;=K">
  <td align="right">$(FORMAT('%d',X[I]))</td>
  <setvar name="I" value="I+1"/>
</while>
```

**📱 Flutter**（`wapform_report.dart`：`WapReport` のブロック内で累計）

```dart
// WapReport サブクラスの parseBlock() の一部：X はグループごとにゼロに戻し、Y は戻さない
void counterBlocks(String id) {
  switch (id) {
    case 'PREFIX':
      setvar("Y", "[1..999]");
      break;
    case 'G1_PREFIX':
      setvar("X", "[1..999]");                     // 宣言し直せばゼロに戻る
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

## 5.6 ルックアップ表としての配列

データセットから読み込んだ後、配列をメモリ上のルックアップ表として使い、繰り返しの検索を避けます：

```xml
<!-- データセットからメニューデータを複数の並列配列に読み込む -->
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

<!-- 以後はインデックスで直接アクセスし、データベースを再検索しない -->
<setvar name="I" value="0"/>
<while cnd="I&lt;k">
  <if cnd="mnu_typ[I]='b'">
    <td>$(mnu_title[I])</td>
  </if>
  <setvar name="I" value="I+1"/>
</while>
```

**📱 Flutter**（`wapform_lazarus.dart`：`DbQuery`、`invoke()`、`setvar()`）

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

## 5.7 色の対応表としての配列

```xml
<!-- インデックスで Bootstrap のスタイルクラスに対応づける -->
<setvar name="btn" value="[0..9]"/>
<setvar name="btn[0]" value="'btn-primary'"/>
<setvar name="btn[1]" value="'btn-secondary'"/>
<setvar name="btn[2]" value="'btn-success'"/>
<setvar name="btn[3]" value="'btn-warning'"/>
<setvar name="btn[4]" value="'btn-danger'"/>

<!-- 使うとき -->
<block name="card-url" style="btn[I MOD 5]" link="midb(s,i+1,j-i-1)"/>
```

```xml
<!-- 月の日数表（うるう年を考慮する場合は 2 月を別に処理） -->
<setvar name="L" value="[31,28,31,30,31,30,31,31,30,31,30,31]"/>
<setvar name="days_this_month" value="L[MONTH(DATE)-1]"/>
```

**📱 Flutter**（`wapform_expression.dart`）

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

## 5.8 データセットの配列式アクセス

`<dbquery>` のデータセットは `.FIELDS[n]` でフィールドの位置（1 始まり）によってアクセスできます：

```xml
<dbquery id="ds"><![CDATA[SELECT col1, col2, col3 FROM t]]></dbquery>

<!-- 位置でフィールド値を取得 -->
<setvar name="v1" value="ds.FIELDS[1]"/>   <!-- col1 -->
<setvar name="v2" value="ds.FIELDS[2]"/>   <!-- col2 -->
```

データセットの `COUNT`、`EOF`、`BOF` プロパティは配列ではありませんが、似た振る舞いをします：

| 式 | 説明 |
|---|---|
| `ds.COUNT` | クエリ結果の総行数 |
| `ds.EOF` | カーソルが最後のレコードの後ろにあるか（ブール値） |
| `ds.BOF` | カーソルが最初のレコードの前にあるか（ブール値） |
| `ds.FIELDS[n]` | フィールドの位置（1 始まり）で現在のレコードのフィールド値を取得 |

**📱 Flutter**（`wapform_lazarus.dart`：`ds.FIELDS[n]`）

`ds.FIELDS[n]`（1 始まり）、`ds.COUNT`、`ds.EOF`、`ds.BOF` は Flutter でも同じように使えます：

```dart
Future<void> fieldsByPosition() async {
  await db.query("ds", "SELECT col1, col2, col3 FROM t");
  setvar("v1", "ds.FIELDS[1]");                    // col1
  setvar("v2", "ds.FIELDS[2]");                    // col2
}
```

---

## 5.9 制限と注意事項

**2 次元配列はない**　WapForm は `arr[i][j]` に対応していないため、並列の 1 次元配列で模擬します：

```xml
<!-- 2 次元を模擬：命名規則で次元を区別 -->
<setvar name="row1" value="[0..9]"/>
<setvar name="row2" value="[0..9]"/>
```

**インデックスは宣言した開始値から始まる**　範囲宣言 `[1..26]` の開始インデックスは `1`、リテラル宣言 `[a,b,c]` の開始インデックスは `0` です。混在させるときは `low()` の戻り値に特に注意してください。

**動的な拡張はできない**　配列の長さは宣言時に固定され、実行時に要素を追加することはできません。上限を超えてアクセスするとエラーになります。

**`while` ループでのリセット**　同じ card 内で `<while>` ループにより配列をリセットするのが標準的なパターンで、配列全体を宣言し直す必要はありません：

```xml
<!-- 宣言し直すのではなく中身を消す -->
<setvar name="I" value="1"/>
<while cnd="I&lt;=99">
  <setvar name="X[I]" value="0"/>
  <setvar name="I" value="I+1"/>
</while>
```

**📱 Flutter**（Dart の式エンジン）

| 項目 | Windows／Web | Flutter |
|---|---|---|
| 2 次元配列 | 非対応 | 非対応 |
| 開始インデックス | 宣言どおり（範囲宣言は 1 から始められる） | 常に 0 から（`[1..n]` はインデックス 0 が 1 つ多くなり、`LOW()` は 0） |
| 動的な拡張 | 不可 | `setvar("X[i]", ...)` で長さを超えると自動で延長 |
| リセット | `while` で要素ごとにゼロにする | `setvar("X", "[1..99]")` で宣言し直すだけ |

---

## 第 6 章　式と関数ライブラリ

WapForm の式は、動的な値を受け付けるすべての属性（`cnd`、`value`、`message`、`href`、`device` など）と、HTML 出力中の `$variable` と `$(expression)` の補間に現れます。

---

## 6.1 補間の文法

| 文法 | 用途 | 例 |
|---|---|---|
| `$varname` | 単純な変数の置換 | `$total`、`$ds.field` |
| `$(expression)` | 任意の式を計算して出力 | `$(FORMAT('%.2f',total))`、`$(IF(qty>0,'あり','なし'))` |

両者は混在させて使えます：

```xml
<td>$(sys.GSWEB+pa.pic1)</td>
<setvar name="label" value="'注文 '+sn.order_no+' 合計 '+STR(total)+'円'"/>
```

**📱 Flutter**（`wapform_lazarus.dart`：`expandText()`、`expandSql()`、`expandSqlAuto()`、`expandSqlQuoted()`）

4 つの展開関数はいずれも `$名前`、`$(式)`、`$$`（`$` を 1 つ出力）を認識し、バッククォート `` ` `` を `'` に置き換えます。違いは値の挿入方法です：

| 関数 | 値の挿入方法 | 用途 |
|---|---|---|
| `expandText(s)` | そのまま | 画面のテキスト、レポートの HTML |
| `expandSql(s)` | そのまま | SQL 条件全体（`$S`）の挿入。`DbQuery.query()` の既定 |
| `expandSqlAuto(s)` | 文字列は自動で単一引用符を付けてエスケープ、数値はそのまま | 単一の値の挿入 |
| `expandSqlQuoted(s)` | 常に単一引用符を付けてエスケープ | 単一の値の挿入 |

```dart
void expandDemo() {
  _ev.setVar("cname", "O'Brien");
  debugPrint(expandSql(r"where cname='$cname'"));            // where cname='O'Brien'   ← 壊れる
  debugPrint(expandSqlAuto(r"where cname=$cname"));          // where cname='O''Brien'  ← 正しい
  debugPrint(expandSql(r"where cname=$(AsQuoted(cname))"));  // 同上
  debugPrint(expandText(r"$(sys.GSWEB+pa.pic1) 合計 $$100"));  // $$ → $
}
```

---

## 6.2 演算子

### 算術

| 演算子 | 説明 | 例 |
|---|---|---|
| `+` | 加算。どちらかのオペランドが文字列なら文字列連結 | `qty * price`、`'コード:'+sn.code` |
| `-` | 減算 | `total - discount` |
| `*` | 乗算 | `sn.qty * sn.price` |
| `/` | 除算（浮動小数点） | `AZ/AY*100` |
| `MOD` | 剰余（整数） | `seq MOD 2` |
| `DIV` | 整数除算 | `n DIV 3` |

### 比較

| 演算子 | XML 属性での書き方 | 説明 |
|---|---|---|
| `=` | `=` | 等しい |
| `<>` | `&lt;&gt;` | 等しくない |
| `<` | `&lt;` | より小さい |
| `>` | `&gt;` | より大きい |
| `<=` | `&lt;=` | 以下 |
| `>=` | `&gt;=` | 以上 |

> XML 属性（`cnd`、`value` など）の中の山括弧は、**必ず**実体参照で表してください。`<![CDATA[...]]>` の中なら `<`、`>` をそのまま書けます。

### 論理

| 演算子 | 説明 | 例 |
|---|---|---|
| `AND` | 論理積 | `qty>0 AND active='Y'` |
| `OR` | 論理和 | `status='A' OR status='B'` |
| `NOT(expr)` | 論理否定（関数形式） | `NOT(ds.EOF)` |

### 文字列の連結

`+` は、どちらかのオペランドが文字列なら自動的に連結に切り替わります：

```xml
<setvar name="S" value="S+' AND dept=`'+filter+'`'"/>
<setvar name="key" value="FORMAT('%3.3d',YEAR(DATE)-1911)+FORMAT('%2.2d',MONTH(DATE))"/>
```

### 優先順位（高い順）

1. 関数呼び出し、括弧 `()`
2. 乗除　`*`　`/`　`MOD`　`DIV`
3. 加減 / 連結　`+`　`-`
4. 比較　`=`　`<>`　`<`　`>`　`<=`　`>=`
5. `NOT`
6. `AND`
7. `OR`

**📱 Flutter**（`wapform_expression.dart`：`WapEvaluator`）

Dart エンジンと Windows 版の違い：

- **`AND`／`OR` の両側の比較には括弧が必要です**：`(qty>0) AND (active='Y')`。`qty>0 AND active='Y'` と書くと `Invalid end token` が報告され、`condition()` は `false` を返します。
- Dart の文字列では `<`、`>` をそのまま書き、`&lt;`、`&gt;` は不要です。
- 整数どうしの `+`、`-`、`*` の結果は整数、それ以外（`/` を含む）は浮動小数点数です。

エンジンを直接使う：

```dart
void evaluatorDemo() {
  final ev = WapEvaluator();
  ev.setVar("qty", 3);
  ev.setVar("price", 99.5);
  final total = ev.eval("qty*price");                // 298.5
  final ok = ev.cond("(qty>0) AND (price<100)");     // true
  ev.addFunction1Param("TAXED", (v) => (v as num) * 1.05); // 独自関数
  debugPrint("$total $ok ${ev.eval("TAXED(100)")}"); // 298.5 true 105.0
}
```

| `WapEvaluator` のメンバー | 説明 |
|---|---|
| `eval(expr, {nul})`／`evalNul(expr)` | 式を評価。エラー時は `lastError` に内容が入る |
| `cond(expr)` | 条件を評価し、`bool` を返す |
| `setVar(name, value)`／`getVar(name)` | 変数を読み書き（値は評価されない） |
| `setRow(table, map)` | 1 行分をまとめて設定：`table.フィールド` と `フィールド` の両方の名前を設定 |
| `clearVars()`／`getUserVars()` | ユーザー変数の消去／一覧 |
| `addFunction0Param`～`addFunction4Param`、`addFunctionAParam` | 引数 0～4 個または可変長引数の独自関数を登録（同名がすでにあれば上書きしない） |
| `datasetResolver` | データセットのリゾルバー（`useEngine()` が `DataSetRegistry.resolveDataSet` に設定） |
| `hasError`／`lastError` | エラー状態 |

関数の Flutter での違いは付録 C を参照してください。

---

## 第 7 章　データセットオブジェクト・リファレンス

WapForm のデータセット（dataset）はカーソルを持つレコードセットオブジェクトで、`<dbquery id="ds">` または `<dbtable name="ds">` で宣言します。宣言後は、データセットのフィールド値、状態プロパティ、Lookup プレフィックスをすべて式の中で直接参照できます。

---

## 7.1 フィールド値へのアクセス

### `ds.fieldname`

データセット `ds` の現在のレコードの `fieldname` フィールドの値にアクセスします。

```xml
$xy.city
$(sn.qty * sn.unit_price)
<if cnd="oh.work_order_no&lt;&gt;''">
```

**📱 Flutter**（`wapform_lazarus.dart`：`expression()`、`expandText()`）

```dart
void readFields() {
  final city = expandText(r"$xy.city");
  final amt = expression("sn.qty * sn.unit_price");
  final hasNo = condition("oh.work_order_no<>''");
  debugPrint("$city $amt $hasNo");
}
```

式から参照するデータセットは、`useEngine()` で指定した `DataSetRegistry` に登録済みでなければなりません（`db.query()` が自動で登録します）。

### フィールドへの書き込み（`<setvar>` を使う）

データセットの id とフィールド名を連結して `<setvar>` の `name` にします：

```xml
<!-- oh データセットの order_date フィールド -->
<setvar name="ohorder_date" value="DATE"/>

<!-- sn データセットの material_name フィールド -->
<setvar name="snmaterial_name" value="luppm.material_name"/>
```

命名規則：`{dataset_id}{fieldname}`。区切り記号はありません。

**📱 Flutter**（`wapform_lazarus.dart`：`setvar("ds.フィールド", ...)`）

```dart
void writeFields() {
  setvar("oh.order_date", "DATE");                   // ohorder_date
  setvar("sn.material_name", "pm.material_name");    // snmaterial_name
}
```

Flutter では `ds.フィールド`（間にドット）を使い、`ohorder_date` のような連結名は使いません。

---

## 7.2 データセットの状態プロパティ

### `ds.COUNT`

クエリ結果の総行数（整数）。

```xml
<if cnd="em.COUNT=0">
  <alert message="データがありません"/>
  <exit/>
</if>
<if cnd="xx.count&gt;0">
  <!-- 既存レコードがある場合はこちらの経路 -->
</if>
```

**📱 Flutter**：`condition("em.COUNT=0")`。`em.RECORDCOUNT` とも書けます。

### `ds.EOF`

カーソルが最後のレコードの**後ろ**にあるか（ブール値）。末尾まで反復すると `True` になります。

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

カーソルが最初のレコードの**前**にあるか（ブール値）。空のデータセットを開いた直後は `True` です。

```xml
<newpage cnd="not(cu.bof)"/>
```

**📱 Flutter**：`condition("not(cu.bof)")`。

### `ds.FIELDS[n]`

フィールドの位置（1 始まり）で現在のレコードのフィールド値を取得します。フィールド名を知る必要はありません。

```xml
<dbquery id="ds"><![CDATA[SELECT col1, col2, col3 FROM t]]></dbquery>
<setvar name="v1" value="ds.FIELDS[1]"/>   <!-- col1 -->
<setvar name="v2" value="ds.FIELDS[2]"/>   <!-- col2 -->
```

**📱 Flutter**：`setvar("v1", "ds.FIELDS[1]")` は通常どおり使えます（1 始まり）。

### `ds.state` *(Windows 専用)*

データセットの現在の編集状態を表す文字列です。

| 値 | 説明 |
|---|---|
| `'BROWSE'` | 閲覧モード（読み取り専用） |
| `'EDIT'` | 編集モード |
| `'INSERT'` | 追加モード |

```xml
<if cnd="em.state='INSERT'">
  <!-- 追加モードのとき作成日を自動入力 -->
  <setvar name="emcreate_date" value="DATE"/>
</if>
```

**📱 Flutter**：`ds.STATE` は Flutter でも使え、`BROWSE`、`EDIT`、`INSERT`、`INACTIVE` のいずれかを返します：`if (condition("em.state='INSERT'")) setvar("em.create_date", "DATE");`

---

## 7.3 Lookup プレフィックス（`lup{dataset}`）

`<input>` で `lookup` 属性を使い、ユーザーが Lookup リストからレコードを選ぶと、システムは `lup` をプレフィックスとする一時データセットを自動で作り、選択された行のすべてのフィールドを読めるようにします。

```xml
<input field="material_code" lookup="pm;material_code;material_name" size="12">
  <onevent type="oncloseup">
    <!-- lup + dataset_id = luppm -->
    <setvar name="snmaterial_name" value="luppm.material_name"/>
    <setvar name="snunit_price"    value="luppm.unit_price"/>
  </onevent>
</input>
```

**形式：** `lup{dataset_id}.{fieldname}`

**Lookup 属性の形式：** `"dataset_id;key_field;display_field"`

| 部分 | 説明 |
|---|---|
| `dataset_id` | 検索元のデータセット id（`<dbquery id>` または `<dbtable name>`） |
| `key_field` | 書き戻し先のフィールドに入れるキーフィールド |
| `display_field` | 入力欄に表示するフィールド |

**SQL ベースの Lookup：**

```xml
<input field="color_no"
       lookup="sql;color_no;SELECT color_no, color_name FROM colors ORDER BY color_no"
       size="10">
  <onevent type="oncloseup">
    <setvar name="sncolor_name" value="lupyy.color_name"/>
    <!-- dataset_id が sql のとき、プレフィックスは lupyy に固定 -->
  </onevent>
</input>
```

**📱 Flutter**（`wapform_lookup_box.dart`：`WapLookupBox`）

Flutter では `luppm` データセットを別に作りません。`onPicked` は選ばれたコードを受け取ります。選択行の他のフィールドを読むには、取得元データセットをその行へ移動します（例は 3.4 節）。`WapLookupBox` のパラメーター：

| パラメーター | 説明 |
|---|---|
| `value` | 現在のコード（必須） |
| `dataSet` ＋ `keyField` ＋ `displayFields` | データセットからリストを作る（`lookup="ds;key;display"` に対応） |
| `lookupItems` | 1 列のリスト `{コード: 表示テキスト}` |
| `lookupColumns` ＋ `colWidths` | 複数列のリスト `{コード: [列1, 列2, ...]}` と各列の幅 |
| `onPicked` | ドロップダウンリストから選んだときに呼ばれる（`oncloseup` に対応） |
| `onChanged` | 文字入力時、またはフォーカスを失って値が書き戻されたときに呼ばれる |
| `readOnly` | 読み取り専用 |
| `width`／`height`／`textStyle` | 外観（既定 130 × 28） |
| `autofocus`、`tapRegionGroupId` | フォーカス制御 |
| `forGrid`、`onTab`、`onTabPrev` | グリッドのセル内に置く（枠線なし、Tab でセル移動） |

---

## 7.5 Web 環境オブジェクト

### `request.*`

HTTP GET / POST リクエストのパラメーター値にアクセスします。パラメーター名はそのままフィールド名の形で参照します。

| パターン | 説明 |
|---|---|
| 読み取り | `$request.gp`、`$(val(request.pg))` |
| 存在確認 | `DEFINE(request.gp)` |

**標準的な読み取りパターン（既定値付き）：**

```xml
<setvar name="gp" value="'0001'"/>
<setvar name="gp" value="request.gp" cnd="DEFINE(request.gp)"/>

<setvar name="pg" value="1"/>
<setvar name="pg" value="val(request.pg)" cnd="DEFINE(request.pg)"/>
```

**操作の振り分けパターン：**

```xml
<if cnd="DEFINE(request.del)">
  <dbquery><![CDATA[DELETE FROM rn WHERE sno='$session.ord']]></dbquery>
  <redirect href="cart.wml"/>
  <exit/>
</if>
<if cnd="DEFINE(request.ok)">
  <!-- 送信を確定 -->
</if>
```

---

### `session.*`

サーバーサイドの session 変数にアクセスし、HTTP リクエストをまたいでユーザーの状態を保持します。

| 操作 | 文法 |
|---|---|
| 読み取り | `$session.usr`、`$(session.ord)` |
| 書き込み | `<session name="usr" value="A"/>` |
| 期限付きの書き込み | `<session name="usr" value="A" expire="480"/>`（480 分後に失効。2026-09 以降のエンジンが必要） |
| 条件付きの書き込み | `<session name="lang" value="request.lang" cnd="DEFINE(request.lang)"/>` |
| 消去 | `<session name="usr" value="''"/>` |
| 存在確認 | `DEFINE(session.usr)` |

**Session のライフサイクル管理：**

```xml
<!-- ログイン：session を設定 -->
<session name="usr" value="A"/>     <!-- A はユーザーが入力したアカウント -->
<session name="ord" value="''"/>    <!-- 古いショッピングカートを消去 -->
<redirect href="index.wml"/>

<!-- ログアウト：session をすべて消去 -->
<session name="usr" value="''"/>
<session name="ord" value="''"/>
<redirect href="index.wml"/>

<!-- Session ガード：未ログインならログインページへ -->
<if cnd="NOT(DEFINE(session.usr))">
  <redirect href="login.wml"/>
  <exit/>
</if>
```

**変数ごとの期限（`expire`）：**

`expire` は分単位で、同じ session 内の変数ごとに異なる寿命を持たせます。エンジンは各リクエストでカードを解析する前に期限切れの変数を消去するので、読み取り側で追加の判定は不要です——`DEFINE(session.usr)` は自然に false になります。

```xml
<!-- ログイン状態は 8 時間、ショッピングカートの一時保存は 2 時間 -->
<session name="usr" value="A" expire="480"/>
<session name="ord" value="S" expire="120"/>

<!-- 延長が必要なら書き込み直す。期限はその時点から計算し直される -->
<session name="usr" value="session.usr" expire="480"/>
```

`expire` の上には cookie とサーバーの `SessionTimeout` という 2 つの上限があり、それより長く設定しても効果はありません。詳しい説明と属性表は第 4 章 4.11 節の `<session/>` を、実装例は第 15 章 15.9 節を参照してください。

---

## 7.6 レポート環境の特殊変数

これらの変数はレポートエンジンが自動で管理し、`<report>` / `<crosstab>` の出力環境の中でのみ有効です。

### `$(PAGE)`

現在のページ番号。`1` から始まり、フレームワークが自動で増やします。

```xml
<th align="right">$(PAGE) ページ</th>
```

**📱 Flutter**（`wapform_report.dart`：`wap.wapPageNo`）

Dart エンジンは `PAGE` を自動で設定しません。`PAGEPREFIX` ブロックでページ番号をエンジンに入れます：

```dart
// WapReport サブクラスの parseBlock() の一部
void pageNoBlock(String id) {
  if (id == 'PAGEPREFIX') {
    currentEvaluator!.setVar("PAGE", wap.wapPageNo);
    emit(expandText(r'<p align="right">$(PAGE) ページ</p>'));
  }
}
```

### `cell`（`<crosstab>` 内）

`<crosstab>` の `<col change>` タグ内では、`cell` が現在描画中の列の値に自動的に対応するため、`$ds.fieldname` を手動で参照する必要はありません。

```xml
<col change="xy.area">
  <setvar name="C" value="cell"/>              <!-- cell = xy.area の現在値 -->
  <setvar name="R" value="cell" cnd="col=1"/> <!-- 1 列目のとき行見出しを記録 -->
  <if cnd="row&lt;3">
    <th>$(IF(cell='',' ',cell))</th>
  <else/>
    <setvar name="N" value="VAL(cell)"/>
  </if>
</col>
```

### `row` / `col`（`<crosstab>` 内）

`<crosstab>` の描画中、フレームワークは現在の行座標（`row`）と列座標（`col`）を管理します。どちらも 1 始まりの整数です。

```xml
<if cnd="(row&lt;3) or (col&lt;3)">
  <!-- 見出し領域（最初の 2 行または 2 列） -->
  <th width="60">...</th>
<else/>
  <!-- データ領域 -->
  <td align="right">...</td>
</if>
```

| 座標 | 説明 |
|---|---|
| `row=1` | 1 つ目の `<row change>` フィールドの見出し行 |
| `row=2` | 2 つ目の `<row change>` フィールドの見出し行 |
| `row>2` | データ行 |
| `col=1` | 1 つ目の `<col change>` フィールドの見出し列 |
| `col=2` | 2 つ目の `<col change>` フィールドの見出し列 |
| `col>2` | データ列 |

---

## 7.7 データセットのメソッド早見表

`<invoke>` で呼び出します。

| メソッド | Win | Web | 説明 |
|---|---|---|---|
| `First` | ✅ | ✅ | 最初のレコードへ移動 |
| `Last` | ✅ | ✅ | 最後のレコードへ移動 |
| `Next` | ✅ | ✅ | 次のレコードへ移動 |
| `Prior` | ✅ | ✅ | 前のレコードへ移動 |
| `locate` | ✅ | ✅ | キー値でレコードを探す |
| `post` | ✅ | ⚠️ | 現在のレコードの変更を保存 |
| `cancel` | ✅ | ⚠️ | 現在のレコードの変更を破棄 |
| `refresh` | ✅ | ⚠️ | クエリを再実行し、データベースから読み込み直す |
| `edit` | ✅ | ❌ | 編集モードに切り替え |
| `insert` | ✅ | ❌ | 空のレコードを 1 件追加 |
| `delete` | ✅ | ❌ | 現在のレコードを削除 |
| `open` | ✅ | ⚠️ | データセットを開く（クエリを実行） |
| `close` | ✅ | ⚠️ | データセットを閉じる |
| `GetBookmark` | ✅ | ❌ | 現在のカーソル位置のブックマークを取得し、`result` の変数に格納 |
| `GoToBookmark` | ✅ | ❌ | 指定したブックマークの位置に戻る |
| `FreeBookmark` | ✅ | ❌ | ブックマークのメモリを解放 |
| `DisableControls` | ✅ | ❌ | UI の更新を凍結（反復中に使う） |
| `EnableControls` | ✅ | ❌ | UI の更新を再開 |

**ブックマークパターン**（Windows 環境でバインド済みデータセットを反復する標準的な方法）：

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

**📱 Flutter**（`wapform_lazarus.dart`：`invoke()`、`varChangeHooks`）

`First`、`Last`、`Next`、`Prior`、`post`、`cancel`、`edit`、`insert`、`delete`、`GetBookmark`、`GoToBookmark`、`FreeBookmark`、`DisableControls`、`EnableControls` はすべて `invoke("ds", "メソッド")` で呼び出せます（大文字・小文字を区別しない）。`refresh`／`open` の代わりに `db.query("ds", sql)` で再検索します。ブックマークパターン：

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

**画面の同期：**`setvar()` が通常の変数を変更すると、`varChangeHooks` の各関数が呼ばれるので、画面はそれを使ってその変数を表示している入力欄を更新できます：

```dart
late final void Function(String) _onVar = (name) {
  if (name.toUpperCase() == "TOTAL" && mounted) setState(() {});
};
void hookVars() => varChangeHooks.add(_onVar);       // 画面の初期化時
void unhookVars() => varChangeHooks.remove(_onVar);  // 画面の破棄時
```

---

## 第 8 章　Windows 版のシステムログインと権限制御

🖥️ **Win 専用**

---

## 8.1 3 層の協調アーキテクチャ

WapForm for Windows のログインと権限のシステムは、3 つの層がそれぞれの役割を担って協調して動きます：

```
┌─ 層 1：データベース ─────────────────────────────────────┐
│  users テーブル：アカウント / パスワード / グループ       │
│  mnu   テーブル：メニュー定義（id, title, href, sub）     │
│  login テーブル：ユーザーごと・メニュー項目ごとの権限値 w │
└───────────────────────────────────────────────────────────┘
           ↓ ログイン認証に成功した後
┌─ 層 2：wapform.wml ──────────────────────────────────────┐
│  mnu LEFT JOIN login を検索                               │
│  login.w が決めるもの：                                   │
│    ① メニュー項目をクリックできるか（menuitem enabled）    │
│    ② フレームワークの実行時 LoginLevel の値               │
└───────────────────────────────────────────────────────────┘
           ↓ ユーザーがメニューを選んで機能を開く
┌─ 層 3：各機能の .wml ────────────────────────────────────┐
│  <author level="n"> で入力フィールドのまとまりを包む       │
│  フレームワークが LoginLevel > n かを比較                  │
│    はい → Writable=False → フィールドは読み取り専用        │
│    いいえ → Writable=True → フィールドは書き込み可         │
└───────────────────────────────────────────────────────────┘
```

---

## 8.2 ログインダイアログ

フレームワークに組み込まれており、開発者が UI を書く必要はありません。アプリケーションの起動時に自動で表示されます。

| 欄 | 説明 |
|---|---|
| **Computer** | データベースサーバーの接続先（`http://host:port/path/`）。接続履歴を記録 |
| **Username** | ユーザーのアカウント。フレームワークがグローバル変数 `$username` として注入 |
| **Password** | ユーザーのパスワード。フレームワークがグローバル変数 `$password` として注入 |
| **Connect** | 接続を確定し、`wapform.wml` を読み込む |
| **Cancel** | キャンセルしてアプリケーションを閉じる |

`$username` と `$password` は `wapform.wml` の実行中ずっとグローバルに有効です。

---

## 8.3 本人認証

```xml
<card id="P" title="mainmenu" device="MDI">

  <!-- アカウントを検索 -->
  <dbquery id="usr">
    select pwd from users where userid='$username'
  </dbquery>

  <!-- アカウントが存在しない → ログインダイアログに戻る -->
  <if cnd="usr.count=0">
    <alert message="Account does not exist"/>
    <prev/>
  </if>

  <!-- パスワード不一致（UPPER() で大文字・小文字を区別せず比較） -->
  <if cnd="upper(usr.pwd)&lt;&gt;upper(password)">
    <alert message="Password error"/>
    <prev/>
  </if>

  ...
</card>
```

MDI card での `<prev/>` の動作は**ログインダイアログに戻る**ことで、アプリケーションを閉じずにユーザーに再試行させます。

> **セキュリティ上の推奨：** 本番環境では `MD5()` でパスワードのハッシュを保存してください：
> ```xml
> <if cnd="usr.pwd&lt;&gt;MD5(password)">
> ```

---

## 8.4 メニューの構築と LoginLevel の設定

認証に成功すると、`wapform.wml` は 2 重の `<while>` でメインメニューを動的に構築し、同時に LEFT JOIN で各メニュー項目に対する現在のユーザーの権限値 `w` を読み取ります：

```xml
<setvar name="K" value="0"/>

<!-- 最上位のメニューグループを検索（sub=-1） -->
<dbquery id="sub"><![CDATA[
  select id, title, href from mnu
  where active=1 and sub=-1
  order by id
]]></dbquery>

<mainmenu images="imagelist1">
  <while cnd="NOT(sub.EOF)">
    <menuitem caption="$sub.title" hint="sub">

      <!-- 子項目の検索：LEFT JOIN で権限値 w を取得 -->
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
        <setvar name="I" value="-1"/>                              <!-- 既定は権限なし -->
        <setvar name="I" value="itm.w" cnd="itm.w&gt;0"/>         <!-- レコードがあり w>0 のときだけ更新 -->

        <setvar name="K" value="K+1"/>
        <setvar name="ID" value="'A'+FORMAT('%3.3d',K)"/>

        <menuitem name="$ID" caption="$(itm.title)"
                  hint="$itm.href" imageindex="$I" onclick="$itm.href"/>

        <setprop name="$ID" prop="enabled" value="0" cnd="I=-1"/> <!-- 権限がなければ無効化 -->

        <invoke instance="itm" method="Next"/>
      </while>
    </menuitem>
    <invoke instance="sub" method="Next"/>
  </while>
</mainmenu>
```

### メニュー項目の有効化ロジック

| `login` レコードの状態 | `itm.w` | `I` | `menuitem` |
|---|---|---|---|
| レコードなし（LEFT JOIN → NULL） | NULL | `-1` | 無効（灰色、クリック不可） |
| レコードあり、`w = 0` | `0` | `-1` | 無効 |
| レコードあり、`w > 0` | `w` の値 | `w` の値 | **有効**。`imageindex` に対応するアイコンを表示 |

`imageindex` はアイコンのインデックスと権限フラグの 2 つの役割を兼ねます。`-1` はアイコンなしを表し、同時に `enabled=0` を引き起こします。

### LoginLevel の出どころ

フレームワークはメニューを構築する過程で、読み取った `itm.w`（有効な値）をそのユーザーの実行時 `LoginLevel` として記録します。**`login.w` が `LoginLevel` の唯一の出どころです。**

---

## 8.5 フィールドブロックの権限：`<author>` タグ

`<author>` は入力フィールドのまとまりを、**書き込み可否が制御されるブロック**として包みます。フレームワークは `<author>` を描画するとき、まず `level` 属性を判定して `Writable` フラグを決め、それから内部のすべての子ノード（`<input>`、`<table>` など）を描画します。

### 文法

```xml
<author level="n" color="#RRGGBB" yy="row" cnd="expr">
  <!-- 制御対象の入力フィールドのグループ -->
</author>
```

### 属性

| 属性 | 必須/任意 | 説明 |
|---|---|---|
| `level="n"` | 任意 | 書き込み権限のしきい値。`LoginLevel > n` のときブロック内のすべての `<input>` が読み取り専用。省略または `n=0` なら常に書き込み可。 |
| `color="#RRGGBB"` | 任意 | ブロック内のラベルの文字色を一時的に上書きし、`</author>` の後で自動的に元に戻す。 |
| `yy="n"` | 任意 | 現在の行番号（`Wap.CurrentLine`）を設定し、レイアウト上の位置を制御する。 |
| `cnd="expr"` | 任意 | 予約属性。現行バージョンでは描画ロジックに影響しない。 |
| `id="name"` | 任意 | ブロックの識別子。プログラムから位置を特定するために予約。 |

### 権限の比較規則

**数字が小さいほど権限が高くなります。** `LoginLevel > level` が真のとき読み取り専用です：

| ユーザーの `LoginLevel` | `<author level="1">` | `<author level="2">` | `<author level="3">` | `<author>` |
|---|---|---|---|---|
| `1`（最高） | ✅ 書き込み可 | ✅ 書き込み可 | ✅ 書き込み可 | ✅ 書き込み可 |
| `2` | ❌ 読み取り専用 | ✅ 書き込み可 | ✅ 書き込み可 | ✅ 書き込み可 |
| `3` | ❌ 読み取り専用 | ❌ 読み取り専用 | ✅ 書き込み可 | ✅ 書き込み可 |
| `5`（最低） | ❌ 読み取り専用 | ❌ 読み取り専用 | ❌ 読み取り専用 | ✅ 書き込み可 |

---

## 8.6 実践例：注文承認ブロック

以下は `order.wml` での実際の使い方です。承認欄を `<author>` で包み、特定の担当者だけが記入できるようにしています：

```xml
<!-- 通常の業務フィールド：level なし。ログインしたすべてのユーザーが編集できる -->
<author>
  <table columns="7" align="LLLLLLL"><tr>
    <td>工場出荷日1：<input field="factory_ship_date_1" size="12"/>
                     <input field="factory_ship_qty_1"  size="12"/></td>
    <td width="10"></td>
    <td>ETD1：<input field="etd_1" size="12"/></td>
    <td width="10"></td>
    <td>INVOICE NO.1：<input field="invoice_no_1" size="20"/></td>
    <td width="10"></td>
    <td>入金日1：<input field="payment_date_1" size="12"/></td>
  </tr></table>
</author>

<!-- 本船 / ETA：別の業務フィールドのまとまり -->
<author>
  <table columns="3" align="LLL">
    <tr>
      <td>本船1：<input field="vessel_1" size="40"/></td>
      <td>ETA1：<input field="eta_1" size="12"/></td>
      <td width="500"></td>
    </tr>
    <tr>
      <td>本船2：<input field="vessel_2" size="40"/></td>
      <td>ETA2：<input field="eta_2" size="12"/></td>
      <td></td>
    </tr>
    <tr>
      <td>本船3：<input field="vessel_3" size="40"/></td>
      <td>ETA3：<input field="eta_3" size="12"/></td>
      <td></td>
    </tr>
    <tr>
      <td>本船4：<input field="vessel_4" size="40"/></td>
      <td>ETA4：<input field="eta_4" size="12"/></td>
      <td></td>
    </tr>
  </table>
</author>

<!-- 承認欄：業務慣行として、通常は level で管理者だけが記入できるように制御する -->
<author>
  <table columns="6" align="CCCCCC"><tr>
    <td>承認：<input field="approved_by" size="12"
          lookup="sql;approved_by;select distinct username from users where grp='A'"/></td>
    <td>営業：<input field="sales_rep" size="12"
          lookup="sql;sales_rep;select distinct username from users where grp='B'"/></td>
    <td>購買：<input field="buyer_rep" size="12"
          lookup="sql;buyer_rep;select distinct username from users where grp='C'"/></td>
    <td>作成：<input field="prepared_by" size="12"
          lookup="sql;prepared_by;select distinct username from users where grp='D'"/></td>
    <td>記入日：<input field="form_date" size="14"/></td>
    <td>送信日：<input field="fax_date" size="14"/></td>
    <td><input value="生産指示書" type="button" onclick="@BOM"/></td>
  </tr></table>
</author>

<!-- 1 つのフィールドだけを個別に制御することもできる -->
<author>
  サンプル番号：<input field="sample_no" size="20"/>
</author>
```

**`level=` のない `<author>` の実際の意味：**

既存のプロジェクトでは、`<author>` のほとんどに `level=` 属性がありません——`Level` の既定値は `0` で、Delphi 側の `if Level > 0` は成立せず、`Writable` は常に `True` です。このとき `<author>` の役割は**意味的な目印**です。業務上「権限がある人だけが変更すべき」承認領域にあたるフィールドを明示し、将来 `level=` の仕組みを有効にするための構造上の場所を確保しています。

---

## 8.7 データフロー全体

```
ユーザーがアカウント / パスワードを入力
          ↓
framework が $username, $password を注入
          ↓
wapform.wml を実行：
  ① users WHERE userid='$username' を検索
     → pwd を検証（UPPER で比較 または MD5）
     → 失敗 → <alert> + <prev/>（ダイアログに戻る）
  ② mnu LEFT JOIN login WHERE uid='$username' を検索
     → login.w > 0  → menuitem enabled、imageindex=w
     → login.w なし/0 → menuitem disabled、imageindex=-1
     → フレームワークが LoginLevel = w を記録
          ↓
ユーザーがメニュー項目を選び、xxx.wml を開く
          ↓
フレームワークが <author level="n"> を描画するとき：
  Wap.LoginLevel > n か？
  True  → Writable=False → ブロック内の <input> はすべて読み取り専用（灰色の背景）
  False → Writable=True  → ブロック内の <input> はすべて編集可（白の背景）
  </author> → Writable を True に戻す
          ↓
ユーザーがフォームを操作（書き込み可のフィールドは通常どおり読み書き、読み取り専用のフィールドは閲覧のみ）
```

---

## 8.8 データベース設計の参考

```sql
-- ユーザーアカウント表
CREATE TABLE users (
  userid  VARCHAR(20) PRIMARY KEY,
  pwd     VARCHAR(100),   -- MD5 ハッシュ
  grp     VARCHAR(5)      -- 機能グループ：A=承認 B=営業 C=購買 D=作成
);

-- メニュー定義表
CREATE TABLE mnu (
  id      VARCHAR(10) PRIMARY KEY,
  sub     VARCHAR(10),    -- 親メニューの id。-1 = 最上位グループ
  title   VARCHAR(50),
  href    VARCHAR(100),
  active  INT DEFAULT 1
);

-- ユーザーのメニュー権限表
CREATE TABLE login (
  uid     VARCHAR(20),    -- users.userid に対応
  id      VARCHAR(10),    -- mnu.id に対応
  w       INT             -- 権限値（1=最高、数字が大きいほど権限が低い）
);

-- 推奨する w の値の割り当て
-- w=1：システム管理者（level="1" 以下のすべてのブロックを編集可）
-- w=2：管理職 / 承認者（level="2" 以下のブロックを編集可）
-- w=3：一般の作業者（level="3" 以下のブロックを編集可）
-- w=5：閲覧専用アカウント（level のない <author> のみ書き込み可）

-- 例：3 人のユーザー、3 種類の権限
INSERT INTO users VALUES ('admin',  MD5('admin123'), 'A');
INSERT INTO users VALUES ('mgr01',  MD5('mgr001'),   'A');
INSERT INTO users VALUES ('sales1', MD5('sales001'), 'B');

-- メニューグループ
INSERT INTO mnu VALUES ('10', '-1', '販売管理', '',            1);
INSERT INTO mnu VALUES ('20', '-1', '在庫管理', '',            1);
INSERT INTO mnu VALUES ('11', '10', '注文照会', 'order.wml',  1);
INSERT INTO mnu VALUES ('12', '10', '注文入力', 'order.wml',  1);
INSERT INTO mnu VALUES ('21', '20', '在庫照会', 'inv.wml',    1);

-- admin（w=1）：全機能
INSERT INTO login VALUES ('admin', '11', 1);
INSERT INTO login VALUES ('admin', '12', 1);
INSERT INTO login VALUES ('admin', '21', 1);

-- mgr01（w=2）：照会と入力ができるが、order.wml の level="1" のブロックは読み取り専用
INSERT INTO login VALUES ('mgr01', '11', 2);
INSERT INTO login VALUES ('mgr01', '12', 2);

-- sales1（w=3）：注文の照会のみ。order.wml の level="2" 以上のブロックは読み取り専用
INSERT INTO login VALUES ('sales1', '11', 3);
-- sales1 には '12' の login レコードがない → 「注文入力」メニュー項目は無効
```

---

## 8.9 設計の要点まとめ

| 仕組み | 制御範囲 | 判定条件 |
|---|---|---|
| `login.w = 0` またはレコードなし | メニュー項目を無効化（機能に入れない） | `I=-1` → `<setprop enabled=0>` |
| `login.w > 0` | メニュー項目を有効化し、同時に `LoginLevel` を設定 | `itm.w` を `I` と `Wap.LoginLevel` に書き込む |
| `level` のない `<author>` | すべてのユーザーが編集可 | `Level=0`、`if Level>0` は不成立 |
| `<author level="n">` | `LoginLevel > n` のユーザーは読み取り専用 | Delphi：`Writable := False` |
| `imageindex="$I"` | アイコン + 権限の二重フラグ | `-1` はアイコンなしで、無効化も起こす |
| `UPPER()` によるパスワード比較 | アカウントは大文字・小文字を区別しない | `MD5()` へのアップグレードを推奨 |
| 認証失敗時の `<prev/>` | ログインダイアログに戻り、再試行を許す | MDI card における `<prev/>` の意味 |

---

## 第 9 章　Web テンプレートシステム



🌐 **Web 専用**

---

## 9.1 コンセプト：WML が HTML テンプレートを駆動する

WapForm for Web の中核的な特長の 1 つが**テンプレート機構**です。静的な HTML テンプレート（`wapform.html` など）が見た目の骨格全体を定義し、WML プログラムがロジック、データ検索、コンテンツ出力を担当します。両者は実行時にフレームワークによって合体し、最終的に完全な HTML ページとして出力されます。

その本質を一言で言えば：

> **WapForm のテンプレート機構は、レイアウト駆動のコンポーネント注入を実現する——プログラムが能動的にページを組み立てるのではなく、テンプレートがページ構造を定義し、プログラムはレイアウトを宣言するだけで、フレームワークが自動的につなぎ合わせる。**

ここからいくつかの重要な利点が生まれます：

- **見た目とロジックの完全な分離**：フロントエンドのデザイナーは HTML/CSS を保守し、バックエンドのロジックは `.wml` にだけ書くので、互いに干渉しません。
- **1 つのテンプレートをサイト全体で共有**：テンプレートを替えればサイト全体の見た目が変わり、WML のロジックは一切変更不要です。
- **レイアウトを独立して進化させられる**：デザイナーがサイドバーを右から左へ移したり、新しい領域を追加したりしても WML のロジックは変更ゼロ。バックエンドがクエリを変えても HTML は変更ゼロです。
- **どんな HTML フレームワークにもつなげられる**：Bootstrap、Metronic、Tailwind——静的な HTML でさえあれば適用できます。

---

## 9.2 トリガーブロック（Triggered Block）——テンプレート機構の大きな特長

トリガーブロックは、同種のフレームワークの中で WapForm が持つ最も独特な設計であり、「レイアウト駆動のコンポーネント注入」という概念を具体的に実現したものです。

### 問題：従来のフレームワークではコードが知りすぎている

ほとんどのフレームワーク（PHP、Django、Rails、Laravel Blade）では、ページの組み立ては**プログラム主導**です：

```php
// 何をどこに組み立てるかをコードが決める
$this->render('layout', [
    'header'   => $this->renderHeader(),
    'sidebar'  => $this->renderSidebar($category),
    'content'  => $this->renderContent($articles),
    'footer'   => $this->renderFooter(),
]);
```

コードは、レイアウトにどの領域があり、各領域にどんなデータを渡すかを知っていなければなりません。レイアウトが変われば（たとえば「関連のおすすめ」欄を追加すれば）コードもそれに合わせて変える必要があります。フロントエンドとバックエンドは実際には結合しているのです。

### WapForm のやり方：テンプレートが主導し、プログラムはレイアウトを宣言するだけ

```xml
<!-- WML のコードはレイアウト名を宣言するだけ -->
<block name="onnote"/>
<!-- 以上。残りはすべてフレームワークが自動で行う -->
```

この 1 行で `wapform.html` の `onnote` ブロックの出力がトリガーされます。そのブロックにはすべての `#(card_id)` 注入ポイントがあらかじめ配置されています——フレームワークは `#(breadcrumb)` を見れば `breadcrumb` サブカードを実行し、`#(content)` を見れば `content` サブカードを、`#(side)` を見れば `side` サブカードを実行します。**コードは、レイアウトにいくつ領域があり、それぞれどこにあるかをまったく知らず、知る必要もありません。**

```
従来のフレームワークで書く必要があるもの：   WapForm に必要なのは 1 行だけ：

  include('header.php')
  include('breadcrumb.php')    →    <block name="onnote"/>
  include('sidebar.php')
  include('content.php')
  include('footer.php')
```

### 本当のエンジニアリング上の利点

レイアウトの構造は `wapform.html` の 1 か所にしか存在しないため：

- デザイナーが `onnote` のサイドバーを右から左へ移す——WML は変更ゼロ
- デザイナーが `onnote` に `#(related)` のおすすめブロックを追加する——対応するサブカードを新しく作るだけで、WML のメインフローは変更ゼロ
- バックエンドが `content` card の検索ロジックを変える——HTML は変更ゼロ

フロントエンドとバックエンドは、単に「別のファイルに分けて置く」だけでなく、本当に独立して進化できます。

### 暗黙の命名契約

この設計には正直に説明しておくべき代償があります：**テンプレート中の `#(card_id)` の名前と WML のサブカードの `id` は完全に一致していなければなりません**。これは暗黙の命名契約で、静的な型システムによるチェックはありません。サブカードの `id` を打ち間違えると、その領域は黙って空白になり、エラーは発生しません。

開発時のアドバイス：まずテンプレートでどの `#(...)` 注入ポイント名が使われているかを確認し、それに合わせてサブカードを作ってください。逆の順番にしないことです。

### note.wml の完全な例の解説

`note.wml` はトリガーブロック機構の最良の実例です。パンくずリスト、右側の目次欄、左側の記事内容を含むナレッジベースの文書ページで、3 つの領域は完全に独立しており、たった 1 行でトリガーされます：

```xml
<?xml version="1.0"?>
<wml>
  <card id="P" device="wapform.html">

    <!-- 1. URL パラメーターを読む -->
    <setvar name="gp" value="'note'"/>
    <setvar name="gp" value="request.gp" cnd="DEFINE(request.gp)"/>

    <!-- 2. 分類の階層をさかのぼり、最上位の分類 id を見つける（最大 3 階層） -->
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

    <!-- 3. ページを組み立てる -->
    <block name="wapform.aa"/>
    <block name="wrapper.aa"/>
    <include name="header"/>

    <!-- ★ 要点：1 行で onnote レイアウトをトリガーし、3 つのサブカードを自動でつなぐ -->
    <block name="onnote"/>

    <include name="footer"/>
    <include name="footer2"/>
    <block name="wrapper.zz"/>
    <block name="wapform.zz"/>
  </card>

  <!-- サブカード 1：パンくずリスト -->
  <card id="breadcrumb" device="sub">
    <block name="breadcrumb" one="category"/>
  </card>

  <!-- サブカード 2：右側の目次欄 -->
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

  <!-- サブカード 3：メインコンテンツ領域 -->
  <card id="content" device="sub">
    <dbquery id="pa"><![CDATA[
      select pno, gid, des, typ, topic
      from pa where gid='$gp' and active>0 order by pno
    ]]></dbquery>
    <if cnd="pa.count&gt;0">
      <!-- 子項目あり：記事一覧のカードを出力 -->
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
      <!-- 子項目なし：AJAX で記事本文を読み込む -->
      <![CDATA[<div id="note"></div>
      <script>loadDoc('note','note-js.wml?pg=$gp');</script>]]>
    </if>
  </card>

</wml>
```

### トリガーブロックの実行フロー

`<block name="onnote"/>` の 1 行が、次の一連のフローをトリガーします：

```
<block name="onnote"/>
         │
         ▼
wapform.html の <!-- onnote.aa --> ブロックの出力開始
┌─────────────────────────────────────────────────────┐
│  #(breadcrumb)                                      │
│      └─► <card id="breadcrumb" device="sub"> を実行 │
│           <block name="breadcrumb" one="category"/> │
│           「ホーム > 操作マニュアル」のパンくず HTML を出力 │
│                                                     │
│  <div class="d-flex flex-column flex-xl-row">       │
│    <div class="flex-lg-row-fluid">                  │
│      #(content)                                     │
│          └─► <card id="content" device="sub"> を実行 │
│               pa where gid='$gp' を検索             │
│               子項目あり → 記事カード一覧を出力     │
│               なし       → AJAX 読み込みスクリプトを出力 │
│    </div>                                           │
│    <div class="mw-lg-300px">                        │
│      #(side)                                        │
│          └─► <card id="side" device="sub"> を実行  │
│               メニューのデータベースを検索し、while で目次ツリーを出力 │
│    </div>                                           │
│  </div>                                             │
└─────────────────────────────────────────────────────┘
<!-- onnote.zz -->
```

`wapform.html` での対応するテンプレート定義：

```html
<!-- onnote.aa -->
#(breadcrumb)
<div class="d-flex flex-column-fluid align-items-start container-xxl xyz">
    <div class="content flex-row-fluid py-10 xyz">
        <div class="d-flex flex-column flex-xl-row p-7 xyz">

            <div class="flex-lg-row-fluid me-xl-15 mb-20 xyz">
                #(content)      ← メインコンテンツ：記事一覧または AJAX 記事
            </div>

            <div class="flex-column flex-lg-row-auto mw-lg-300px mw-xxl-350px">
                <div class="card-rounded bg-primary bg-opacity-5 p-10 cls">
                    #(side)     ← サイドバー：目次ツリー
                </div>
            </div>

        </div>
    </div>
</div>
<!-- onnote.zz -->
```

**ポイント**：3 つのサブカード（`breadcrumb`、`content`、`side`）はそれぞれ独立してロジックを書き、互いの存在を知る必要も、自分がページのどこに置かれるかを知る必要もありません——レイアウトの配置は完全にテンプレートが決めます。

---

## 9.3 HTML テンプレートの構造：ブロックマーカー

`wapform.html` は HTML コメントですべての**名前付きブロック**の境界を示します。命名規則は `blockname.aa`（開始）/ `blockname.zz`（終了）です：

```html
<!-- wapform.aa -->
<head>
  <title>...</title>
  <link rel="stylesheet" href="assets/css/style.bundle.css"/>
  <!-- $(var('idx',-1)) -->  ← ブロックをまたぐカウンターを初期化
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
  $(menu)                    ← varblock の注入ポイント

  <!-- onnote.aa -->
  #(breadcrumb)              ← サブカードの注入ポイント
  <div ...>
    #(content)               ← サブカードの注入ポイント
    #(side)                  ← サブカードの注入ポイント
  </div>
  <!-- onnote.zz -->

  <!-- footer.aa -->
  <div>
    $(sys.company)
    <!-- footer-item.aa --><a href="$(app).wml?gp=$(itm.pno)">$itm.des</a><!-- footer-item.zz -->
  </div>
  <!-- footer.zz -->
  $(footer)                  ← varblock の注入ポイント

<!-- wrapper.zz -->
<!-- wapform.zz -->
<script src="assets/js/scripts.bundle.js"></script>
```

### マーカーの文法

| 文法 | 説明 |
|---|---|
| `<!-- blockname.aa -->` | 名前付きブロックの開始 |
| `<!-- blockname.zz -->` | 名前付きブロックの終了 |
| `#(card_id)` | サブカードの注入ポイント。フレームワークが対応するサブカードを自動で呼び出す |
| `$(varname)` | 変数または varblock の蓄積結果の注入ポイント |

---

## 9.4 レイアウトパターン：`<block name="on..."/>` の選択

`wapform.html` には複数のレイアウトがあらかじめ定義されており、レイアウトごとに `#(...)` 注入ポイントの並びが異なります。WML は 1 行呼び出すだけでレイアウトが決まります：

| `<block name="..."/>` | レイアウトの説明 | 注入ポイント |
|---|---|---|
| `onreport` | 標準レイアウト：パンくず + 全幅コンテンツ | `#(breadcrumb)` `#(content)` |
| `onshop` | EC レイアウト：パンくず + 左サイドバー + メインコンテンツ | `#(breadcrumb)` `#(side)` `#(content)` |
| `onfull` | 全幅レイアウト：パンくず + サイドバーなし | `#(breadcrumb)` `#(content)` |
| `onnote` | 文書レイアウト：パンくず + メインコンテンツ + 右サイドバー | `#(breadcrumb)` `#(content)` `#(side)` |
| `onzero` | 最小レイアウト：パンくず + コンテンツのみ | `#(breadcrumb)` `#(content)` |
| `onpage` | 記事レイアウト：padding 付きのカード枠 | `#(breadcrumb)` `#(content)` |
| `onlogin` | ログインレイアウト：中央寄せのカード、上部ナビゲーションなし | `#(content)` |

**同じサブカードの組を別のレイアウトブロックと組み合わせるだけで、まったく異なるページ構造を作れます**。WML のロジックは一切変更不要です：

```xml
<block name="onnote"/>    → 文書レイアウト：左に本文 + 右に目次
<block name="onfull"/>    → 全幅レイアウト：本文のみでサイドバーなし
<block name="onlogin"/>   → ログインレイアウト：中央寄せのカード
```

---

## 9.5 notebar 目次ツリー：side サブカードの詳細

`note.wml` の `side` card は、サブカード内で**2 重のネストしたクエリ**を実行し、展開可能な目次ツリーを動的に組み立てる例です：

```xml
<card id="side" device="sub">
  <block name="notebar.aa"/>        ← 目次コンテナの先頭（分類の見出し $category を含む）

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
      <!-- 子項目あり：展開可能なグループ -->
      <block name="notebar-list.aa"/>
      <while cnd="not(itm.eof)">
        <block name="notebar-item"/>
        <invoke instance="itm" method="next"/>
      </while>
      <block name="notebar-list.zz"/>
    <else/>
      <!-- 子項目なし：葉ノードのリンク -->
      <block name="notebar-mark"/>
    </if>

    <invoke instance="mnu" method="next"/>
  </while>

  <block name="notebar.zz"/>
</card>
```

`wapform.html` での対応する 4 つの目次ブロック：

```html
<!-- notebar.aa -->
<div class="menu menu-column" id="kt_docs_aside_menu" data-kt-menu="true">
    <div class="menu-item">
        <h4 class="menu-content text-muted mb-0 fs-7">$category</h4>
    </div>

    <!-- notebar-mark.aa -->
    <!-- 葉ノード：直接リンク。クリックすると AJAX で記事を読み込む -->
    <div class="menu-item">
        <a class="menu-link py-2"
           href="javascript:loadDoc('note','note-js.wml?pg=$mnu.pno')">
            <span class="menu-title">$mnu.des</span>
        </a>
    </div>
    <!-- notebar-mark.zz -->

    <!-- notebar-list.aa -->
    <!-- グループノード：展開可能で、子項目を含む -->
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

目次の各リンクは `javascript:loadDoc(...)` で、クリックしてもページ遷移せず、AJAX でメインコンテンツ領域の記事を直接差し替えます——これが次の節のポイントです。

---

## 9.6 AJAX のオンデマンド読み込みと `<wap>` タグ

### content サブカードの 2 つの経路

`note.wml` の `content` card は、データの状況に応じて 2 つの経路に分かれます：

```xml
<card id="content" device="sub">
  <dbquery id="pa"><![CDATA[
    select pno, gid, des, typ, topic
    from pa where gid='$gp' and active>0 order by pno
  ]]></dbquery>

  <if cnd="pa.count&gt;0">
    <!-- 経路 A：gp は分類ノードで子項目あり → 記事カード一覧を出力 -->
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
    <!-- 経路 B：gp は葉ノードで記事そのもの → AJAX で本文を読み込む -->
    <![CDATA[
    <div id="note"></div>
    <script>loadDoc('note','note-js.wml?pg=$gp');</script>
    ]]>
  </if>
</card>
```

**経路 A**：`gp` が分類を指し、その下にまだ子記事があるので、記事カードを出力してユーザーに選ばせます。

**経路 B**：`gp` が 1 つの記事を直接指します。メインページの枠が長い記事の読み込みを待たなくて済むよう、AJAX でオンデマンドに取得します。

### `loadDoc()` — テンプレートに組み込まれた AJAX 関数

`wapform.html` は `<head>` であらかじめ宣言しています：

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

2 つの使用場面：

**場面 1**：content card の経路 B で、ページの読み込み完了後すぐに呼び出す：

```html
<div id="note"></div>
<script>loadDoc('note', 'note-js.wml?pg=$gp');</script>
```

**場面 2**：notebar の目次リンクで、ユーザーがクリックしたときに呼び出し、同じ `<div id="note">` を差し替える：

```html
<a href="javascript:loadDoc('note', 'note-js.wml?pg=$itm.pno')">
    $itm.des
</a>
```

どちらも `note-js.wml` を指しており、トリガーのタイミングが違うだけです。ページの枠は一度だけ作られ、記事の本文は何度でも差し替えられます。

### `note-js.wml` と `<wap>` タグ

`note-js.wml` は AJAX の応答専用に設計された最小限の WML です：

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

**`device="wapform-js.html"`** — 軽量テンプレートを使い、完全なページの骨格（header、footer、メニュー）を含まず、純粋な HTML の断片だけを出力します。

**`<wap>` タグ** — Web 環境専用で、「Web モードでのみこの部分を出力する」ことを示します。データベースを検索して `pa.topic`（記事の HTML 本文）を取得し、`<article>` で包んで返します。

AJAX リクエスト `note-js.wml?pg=500120001` の応答は純粋な HTML の断片です：

```html
<article>
  （記事の HTML 本文）
</article>
```

`loadDoc()` はそれを受け取ると `<div id="note">` に直接埋め込み、ページは再読み込みされず、枠の構造（header、目次欄）はそのままです。

### 全体のデータフロー

```
ユーザーが note.wml?gp=500100 にアクセス
        │
        ▼
メイン card：分類を 3 階層さかのぼり、id, category を設定
        │
        ▼
<block name="onnote"/> がトリガー

  ├─ #(breadcrumb) → breadcrumb card
  │    <block name="breadcrumb" one="category"/>
  │    → 「ホーム > 操作マニュアル」を出力
  │
  ├─ #(content) → content card
  │    pa where gid='500100' を検索
  │    if pa.count > 0
  │      → 記事カード一覧を出力（shop-note ブロック）
  │    else
  │      → 空の div + loadDoc('note','note-js.wml?pg=500100') を出力
  │         │  ページ読み込み後に AJAX で呼び出し
  │         └─► note-js.wml?pg=500100
  │               pa where pno='500100' を検索
  │               <wap> が <article>$pa.topic</article> を出力
  │               ↩ 純粋な HTML の断片を返し、<div id="note"> に埋め込む
  │
  └─ #(side) → side card
       mnu where gid='$id' を検索（最上位の分類の子項目）
       while で各第 1 階層の項目について
         itm（第 2 階層の項目）を検索
         if itm.count > 0
           → notebar-list.aa + notebar-item × N + notebar-list.zz
             各 notebar-item のリンク：
             javascript:loadDoc('note','note-js.wml?pg=$itm.pno')
         else
           → notebar-mark（葉ノード、同じく loadDoc を指す）
       → 目次ツリーの完成

ユーザーが目次のリンクをクリック
  → loadDoc('note','note-js.wml?pg=500120001')
  → AJAX で新しい記事の HTML を取得
  → <div id="note"> に埋め込む（ページ全体は再読み込みしない）
```

---

## 9.7 3 種類のコンテンツ注入メカニズム

WapForm のテンプレートには 3 種類の注入方法があり、それぞれに適した場面があります：

### `#(card_id)` — サブカードの同期注入

フレームワークはテンプレートの HTML を出力する際、`#(card_id)` に出会うと対応するサブカードを直ちに実行します：

```html
#(breadcrumb)   ← <card id="breadcrumb" device="sub"> を同期実行
#(content)      ← <card id="content"    device="sub"> を同期実行
#(side)         ← <card id="side"       device="sub"> を同期実行
```

### `$(varname)` — varblock による事前蓄積注入

WML のフロー中で `<varblock>` が HTML を名前付きの変数に少しずつ蓄積し、テンプレート末尾の `$(varname)` で一度に挿入します：

```xml
<report dataset="mnu">
  <varblock name="footer" block="footer.aa"/>
    <varblock name="footer" block="footer-item"/>
  <varblock name="footer" block="footer.zz"/>
</report>
```

```html
$(footer)    ← 蓄積し終えた footer の HTML 全体を挿入
$(footer2)
```

### `loadDoc()` — AJAX による非同期注入

空の div を用意しておき、ページの読み込み後やユーザーのクリック時に、軽量な WML から HTML の断片を非同期に取得して埋め込みます：

```html
<div id="note"></div>
<script>loadDoc('note', 'note-js.wml?pg=$gp');</script>
```

**3 つのメカニズムの比較：**

| メカニズム | トリガーのタイミング | 適した場面 | 宣言方法 |
|---|---|---|---|
| `#(card_id)` | フレームワークがテンプレートを出力するときに同期実行 | メインコンテンツ、パンくず、サイドバー | サブカード + テンプレートの注入ポイント |
| `$(varname)` | WML のフローで事前に蓄積し、一度に出力 | メニュー、フッターなど蓄積型の構造 | `<varblock>` + テンプレート変数 |
| `loadDoc()` | ページの読み込み後またはユーザーのクリック時 | 長い記事、オンデマンドの差し替え | 空の div + JS + 軽量 WML |

---

## 9.8 2 種類の HTML テンプレート

| 特性 | `wapform.html` | `wapform-js.html` |
|---|---|---|
| 用途 | 完全なページの骨格 | AJAX 応答の純粋なコンテンツ断片 |
| 含むもの | CSS/JS/header/footer/メニュー | 最小限の包みだけ |
| WML の `device` の値 | `"wapform.html"` | `"wapform-js.html"` |
| 組み合わせるタグ | `<block>`、サブカード、`<varblock>` | `<wap>` |
| 注入メカニズム | `#(card_id)`、`$(varname)` | `loadDoc()` AJAX |

---

## 9.9 `<block>` 呼び出し時のパラメーター受け渡し

`<block>` でテンプレートのブロックを呼び出すとき、任意の属性を名前付きパラメーターとして付けられ、ブロックの HTML では `$attributename` で取り出します：

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
    <li><a href="index.wml">ホーム</a></li>
    <li>$one</li>       ← 渡された one パラメーター（= category 変数の値）を使う
    <li>$category</li>
</ul>
<!-- breadcrumb.zz -->
```

パラメーターの値には WapForm の式をすべて使え、呼び出し時に評価されてから渡されます。

---

## 9.10 テンプレート内の式と状態関数

`wapform.html` の中では WapForm の式を直接使え、フレームワークがテンプレートを適用するときに一緒に評価されます：

```html
<h6>$(sys.company)</h6>
<a href="$(app).wml?gp=$(itm.pno)">$itm.des</a>
<ins class="$(IF(pa.pricec&gt;0,'text-red',''))">
    特価$(IF(pa.pricea&gt;pa.price1,99999,pa.price1))
</ins>
<section style="background-color:$('#'+COLOR2HEX(color[inc('idx',1) mod 5]));">
```

### `var()` と `inc()` — テンプレートのブロックをまたぐ状態関数

| 関数 | 説明 |
|---|---|
| `var('name', default)` | 状態変数を読む。存在しなければ `default` で初期化して返す |
| `inc('name', step)` | 状態変数を `step` だけ増やして新しい値を返す |

```html
<!-- wapform.aa で初期化 -->
<!-- $(var('idx',-1)) -->

<!-- 出力ブロックごとに自動で増やし、5 色で循環する背景を作る -->
<section style="background-color:$('#'+COLOR2HEX(color[inc('idx',1) mod 5]));">
```

`var()` / `inc()` の状態はページリクエストの期間中ずっと有効で、複数のサブカードの出力をまたいでもカウントを共有できます。

---

## 9.11 完全な対応関係：note.wml ↔ wapform.html

```
note.wml                               wapform.html
─────────────────────────────────────────────────────────────────────
<card id="P" device="wapform.html">    ← テンプレートを指定

分類を 3 階層さかのぼる                （メイン card は純粋なフローで、テンプレートに関わらない）
id, category を設定

<block name="wapform.aa"/>             <!-- wapform.aa -->
                                       <head>CSS/JS</head><body>
                                       <!-- $(var('idx',-1)) -->

<block name="wrapper.aa"/>             <!-- wrapper.aa -->
                                       <div class="d-flex flex-column...">

<include name="header"/>               ← header.wml を実行し、ナビゲーションバーを出力
                                       テンプレートの $(menu) にメニューの varblock の結果を挿入

<block name="onnote"/>                 ← ★ トリガーブロック
                                       <!-- onnote.aa -->
                                       #(breadcrumb)
  <card id="breadcrumb" device="sub">  ├─ breadcrumb card を実行
    <block name="breadcrumb"           │    <!-- breadcrumb.aa -->
           one="category"/>            │    ホーム > $one（= category）
                                       │    <!-- breadcrumb.zz -->
                                       <div class="flex-xl-row">
                                         <div class="flex-lg-row-fluid">
                                           #(content)
  <card id="content" device="sub">     ├─ content card を実行
    if pa.count > 0                    │    経路 A：記事カード一覧を出力
      <block name="shop-note"/> × N    │    経路 B：空の div + loadDoc() を出力
    else                               │            ↓ AJAX
      loadDoc('note','note-js.wml')    │      note-js.wml
                                       │      <wap> <article>$pa.topic
                                         </div>
                                         <div class="mw-lg-300px">
                                           #(side)
  <card id="side" device="sub">        └─ side card を実行
    notebar.aa                              目次ツリーの HTML
    while mnu                               各リンク：loadDoc(...)
      if itm.count > 0
        notebar-list + notebar-item × N
      else
        notebar-mark
    notebar.zz
                                       </div>
                                       <!-- onnote.zz -->

<include name="footer"/>               footer card → varblock → $footer
<include name="footer2"/>              footer2 card → varblock → $footer2
                                       テンプレート末尾の $(footer)$(footer2) に挿入

<block name="wrapper.zz"/>             <!-- wrapper.zz --> </div>
<block name="wapform.zz"/>             <!-- wapform.zz --> JS </body>
```

---

## 9.12 テンプレート機構のまとめ

| 規則 | 説明 |
|---|---|
| `device="wapform.html"` | メイン card がテンプレートを指定し、フレームワークはこの HTML を骨格にする |
| `device="wapform-js.html"` | AJAX 断片専用の軽量テンプレート。`<wap>` と組み合わせて使う |
| `device="sub"` | 注入ポイントに対応するサブカード。HTML の断片だけを出力する |
| `<block name="on..."/>` | レイアウトブロックをトリガーし、1 行ですべての `#(...)` 注入ポイントを自動でつなぐ |
| `<block name="x"/>` | テンプレートの `<!-- x.aa -->` から `<!-- x.zz -->` までの HTML を呼び出す |
| `#(card_id)` | テンプレートの注入ポイント。フレームワークが対応するサブカードを同期実行する |
| `$(varname)` | WapForm の変数または varblock の蓄積結果を挿入する |
| `<varblock>` | ループの中で HTML を名前付きの変数に少しずつ蓄積する |
| `loadDoc(id, url)` | AJAX でオンデマンドに読み込み、指定した div に埋め込む |
| `<wap>` | AJAX 応答用の WML で、この部分の HTML だけを出力することを示す |
| ブロックのパラメーター | `<block name="x" param="val"/>` で渡し、ブロック内では `$param` で取り出す |
| `var()` / `inc()` | テンプレート内でブロックをまたぐカウント状態。循環する色などに使う |

---

## 第 10 章　チャート



🖥️ **Win** ✅ | 🌐 **Web** ✅

---

## 10.1 概観

WapForm の `<chart>` 要素を使えば、開発者は JavaScript を一切書かずに、WML の中で直接宣言して対話型のチャートを作れます。チャートのデータソースには 2 つの方式があります：

- **データセット駆動**：`<dbquery>` のデータセットをバインドし、フィールドが自動的に軸に対応します。
- **プログラム生成**：`<serie>` の中で `<while>` や `<for>` のループと `<point>` を組み合わせ、データポイントを 1 件ずつ注入します。

2 つの方式は混在でき、1 つの `<chart>` で複数の `<serie>`（複数系列）に対応しているため、同じチャートに異なる種類を重ねられます。

---

## 10.2 基本構造

```xml
<chart title="チャートのタイトル" ...チャートの属性...>
  <serie type="種類" ...系列の属性...>
    <!-- データソース：どちらか一方 -->

    <!-- 方式 1：プログラムでデータポイントを生成 -->
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(100,300)"/>
    </while>

    <!-- 方式 2：データセットをバインド（<chart> で dataset を宣言し、ここでは <point> を省略） -->
  </serie>

  <!-- 2 本目の系列を追加できる -->
  <serie type="line" ...>...</serie>
</chart>
```

---

## 10.3 `<chart>` — チャートコンテナの属性

| 属性 | 必須/任意 | 説明 |
|---|---|---|
| `title` | 任意 | チャートのタイトル |
| `dataset` | 任意 | バインドするデータセット名（データセット駆動モード） |
| `rangeto` | 任意 | X 軸の最大目盛り値（データセットモードの軸範囲に使う） |
| `legend` | 任意 | `"yes"` で凡例を表示 |
| `autocolor` | 任意 | `"yes"` で各データポイントに自動で異なる色を適用（円系のチャートでよく使う） |
| `xaxisposition` | 任意 | X 軸の位置。`"none"` で X 軸を非表示 |
| `yaxisposition` | 任意 | Y 軸の位置。`"none"` で Y 軸を非表示 |
| `titlefontsize` | 任意 | タイトルのフォントサイズ（ポイント） |
| `xresult` | 任意 | チャートの出力結果を指定した変数（`"s"` など）に格納 |

---

## 10.4 `<serie>` — 系列の属性

### 共通属性（すべての種類）

| 属性 | 必須/任意 | 説明 |
|---|---|---|
| `type` | 必須 | チャートの種類（10.6 節の完全一覧参照） |
| `color` | 任意 | 塗りつぶし色（`#RRGGBB`）。bar、area、pie など面積を持つ種類に使う |
| `linecolor` | 任意 | 線の色（`#RRGGBB`）。line、digitalline に使う |
| `linewidth` | 任意 | 線の太さ（ピクセル） |
| `opacity` | 任意 | 不透明度（0–255、area 系に使う） |
| `marker` | 任意 | `"yes"` でデータポイントにマーカーを表示（line に使う） |
| `valuewidth` | 任意 | データポイントの幅（ピクセル、bar に使う） |
| `title` | 任意 | 系列名（凡例に表示） |

### データセットのバインド属性

| 属性 | 必須/任意 | 説明 |
|---|---|---|
| `fieldnamevalue` | 任意 | 値のフィールド名（データセット駆動モード） |
| `fieldnamexaxis` | 任意 | X 軸ラベルのフィールド名。`"no"` で自動の連番を使う |

### 円 / ドーナツ系専用の属性

| 属性 | 必須/任意 | 説明 |
|---|---|---|
| `pielegend` | 任意 | `"yes"` で円グラフの凡例を表示 |
| `pieposition` | 任意 | `"custom"` で円の位置を自分で指定 |
| `pieleft` | 任意 | 円の中心の X 座標（ピクセル） |
| `pietop` | 任意 | 円の中心の Y 座標（ピクセル） |
| `piesize` | 任意 | 円の半径（ピクセル） |
| `pieshowvalues` | 任意 | `"yes"` で扇形に値を表示 |
| `pieshowlegendonslice` | 任意 | `"yes"` で扇形にラベルを表示 |
| `pievalueposition` | 任意 | `"outside"` で値のラベルを扇形の外側に表示 |

---

## 10.5 `<point>` — データポイント

```xml
<point label="ラベル" value="値" color="C[I mod 5]"/>
```

| 属性 | 必須/任意 | 説明 |
|---|---|---|
| `label` | 必須 | X 軸のラベルまたは凡例名。式を使える |
| `value` | 必須 | Y 軸の値。式（関数、変数を含む）を使える |
| `color` | 任意 | 個々のデータポイントの色（配列のインデックスまたは `#RRGGBB`） |

`<point>` は通常 `<while>` や `<for>` ループの中で動的に生成しますが、静的に 1 件ずつ並べることもできます。

---

## 10.6 チャート種類の完全一覧

WapForm は 12 種類のチャートに対応しており、分類ごとにまとめると次のとおりです：

### 折れ線系

#### `line` — 折れ線グラフ

連続した値の傾向を表し、複数系列の重ね合わせに対応します。

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

- `dataset="xy"` でクエリ結果をバインドし、`fieldnamevalue` で値のフィールドを指定します。
- `marker="yes"` で各データポイントに丸いマーカーを付けます。
- 複数の `<serie>` は自動的に同じチャートに重ねられます。

#### `digitalline` — デジタル折れ線グラフ

階段状の折れ線で、離散的な状態の切り替え（オン/オフ、0/1 の値など）を表すのに適しています。負の値に対応します。

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

### 棒系

#### `bar` — グループ棒グラフ

棒を並べて表示し、複数カテゴリーの比較に適しています。

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

- `valuewidth` で各棒の幅を制御します。
- 複数の `<serie>` は並べて表示されます（グループモード）。

#### `stackedbar` — 積み上げ棒グラフ

複数系列の値を縦に積み上げ、構成比と総量を示すのに適しています。

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

#### `histogram` — ヒストグラム

単一系列の棒で、負の値に対応し（棒が下向きに伸びる）、度数分布に適しています。

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

### 面系

#### `area` — 面グラフ

折れ線の下を塗りつぶし、`opacity` で不透明度を制御します。傾向と量の可視化に適しています。

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

- `opacity="150"` で塗りつぶしの不透明度を設定します（0=完全に透明、255=不透明）。複数系列が重なっても下の層が見えます。

#### `stackedarea` — 積み上げ面グラフ

複数系列の面を縦に積み上げ、個別の量と合計の傾向を同時に示すのに適しています。

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

### 円系

円系のチャートは通常 X/Y 軸を非表示にし（`xaxisposition="none" yaxisposition="none"`）、一連の `pie*` 属性で外観を制御します。

#### `pie` — 円グラフ

各扇形の面積が比率に比例し、構成比の表示に適しています。各 `<point>` に個別の色を指定できます。

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

- 色の配列 `C[]` をチャートの外であらかじめ宣言し、`<point color="C[I mod 5]">` で順に適用します。
- `pievalueposition="outside"` で値のラベルを扇形の外側に表示します。

#### `donut` — ドーナツグラフ

円の中央をくり抜いたもので、中央に説明文を置くのに適しています。`autocolor="yes"` でフレームワークが自動で配色します。

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

#### `sizedpie` — 比例円グラフ

扇形の面積を（角度ではなく）円の大きさで表し、絶対量の差を強調するのに適しています。

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

#### `sizeddonut` — 比例ドーナツグラフ

`sizedpie` のドーナツ版です。

```xml
<chart title="sizeddonut" autocolor="yes" xaxisposition="none" yaxisposition="none">
  <serie type="sizeddonut" ...>
    ...
  </serie>
</chart>
```

---

### レーダー系

#### `spider` — スパイダーチャート（レーダーチャート）

多次元の指標を比較し、各軸が中心から外へ放射状に伸びます。同じく `pie*` 属性群でレイアウトを制御します。

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

## 10.7 チャート種類早見表

| 種類 `type` | 日本語名 | 負の値 | 複数系列 | 自動配色 | 適した場面 |
|---|---|---|---|---|---|
| `line` | 折れ線グラフ | ✅ | ✅ | ❌ | 傾向、時系列 |
| `digitalline` | デジタル折れ線グラフ | ✅ | ✅ | ❌ | 状態の切り替え、0/1 信号 |
| `bar` | グループ棒グラフ | ❌ | ✅ | ❌ | カテゴリーの比較 |
| `stackedbar` | 積み上げ棒グラフ | ❌ | ✅ | ❌ | 構成比 + 総量 |
| `histogram` | ヒストグラム | ✅ | ❌ | ❌ | 度数分布、正負の値 |
| `area` | 面グラフ | ❌ | ✅ | ❌ | 傾向 + 量感 |
| `stackedarea` | 積み上げ面グラフ | ❌ | ✅ | ❌ | 構成の傾向 |
| `pie` | 円グラフ | ❌ | ❌ | ⚠️ 手動 | 構成比（個別の配色） |
| `donut` | ドーナツグラフ | ❌ | ❌ | ✅ | 構成比（自動配色） |
| `sizedpie` | 比例円グラフ | ❌ | ❌ | ✅ | 絶対量の差 |
| `sizeddonut` | 比例ドーナツグラフ | ❌ | ❌ | ✅ | 絶対量の差（ドーナツ） |
| `spider` | スパイダーチャート | ❌ | ❌ | ❌ | 多次元のレーダー |

---

## 10.8 データソース：2 つのモード

### モード 1：データセット駆動

`<chart>` に `<dbquery>` のデータセットをバインドし、`<serie>` で `fieldnamevalue` / `fieldnamexaxis` によりフィールドを指定します。`<point>` は不要です：

```xml
<dbquery id="xy"><![CDATA[
  SELECT TOP 12 no, a, b FROM zp
]]></dbquery>

<chart title="月別売上の推移" rangeto="11" dataset="xy" legend="yes">
  <serie type="line" linecolor="#f37735" linewidth="2"
         fieldnamevalue="a" fieldnamexaxis="no">
  </serie>
  <serie type="line" linecolor="#00aedb" linewidth="2"
         fieldnamevalue="b" fieldnamexaxis="no" marker="yes">
  </serie>
</chart>
```

- `fieldnamexaxis="no"` で自動の整数連番を X 軸ラベルに使います。フィールド名を指定するとそのフィールドの値を使います。
- `rangeto="11"` で X 軸の最大表示目盛りを指定します。

### モード 2：プログラムでデータポイントを生成

`<serie>` の中で `<while>` / `<for>` ループ + `<point>` により動的に注入します。その場で計算が必要な場合や、決まったクエリ形式に依存しない場合に適しています：

```xml
<chart title="ランダム分布" rangeto="11">
  <serie type="bar" color="#f37735" valuewidth="60">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(100,300)"/>
    </while>
  </serie>
</chart>
```

- `RandomRange(min, max)` は範囲内のランダムな整数を生成します（🌐 **Web** 環境の関数）。
- `label` と `value` はどちらも WapForm の式をすべて使えます。

### 混在の例：データベース + 動的計算

```xml
<dbquery id="sales"><![CDATA[
  SELECT month, amount FROM monthly_sales WHERE year=$year
]]></dbquery>

<chart title="売上 vs 目標" dataset="sales" legend="yes">
  <!-- 系列 1：データセットから実際の売上を読む -->
  <serie type="bar" color="#00aedb"
         fieldnamevalue="amount" fieldnamexaxis="month">
  </serie>
  <!-- 系列 2：目標値（固定の定数をループで注入） -->
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

## 10.9 色配列のテクニック

円グラフの個々のデータポイントの配色は、あらかじめ色の配列を宣言してインデックスで参照します：

```xml
<!-- card の最上位で色の配列を宣言 -->
<setvar name="C" value="[0..9]"/>
<setvar name="C[0]" value="#00aedb"/>
<setvar name="C[1]" value="#a200ff"/>
<setvar name="C[2]" value="#f47835"/>
<setvar name="C[3]" value="#d41243"/>
<setvar name="C[4]" value="#8ec127"/>

<!-- <point> で mod を使って循環的に色を取る -->
<while cnd="I&lt;5">
  <point label="$('カテゴリー'+STR(I))"
         value="RandomRange(100,300)"
         color="C[I mod 5]"/>
  <setvar name="I" value="I+1"/>
</while>
```

`color="C[I mod 5]"` は配列の要素（文字列 `"#RRGGBB"`）を渡し、`mod 5` により色が配列の範囲を超えずに循環します。

`autocolor="yes`（`<chart>` で宣言）にすれば、フレームワークが自動で配色するので、配列を手動で管理する必要はありません。

---

## 10.10 複数チャートの並列表示：`<table>` レイアウト

`<table columns="N">` を使って複数のチャートをグリッド状に並べます：

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

`columns="4"` はこの表が 4 列であることをエンジンに伝え、`align="LLLL"` で各列を左揃えにします。

---

## 10.11 プラットフォームの違い

| 機能 | 🖥️ Win | 🌐 Web |
|---|---|---|
| 全 12 種類のチャート | ✅ | ✅ |
| データセット駆動（`dataset=`） | ✅ | ✅ |
| プログラム生成（`<point>`） | ✅ | ✅ |
| `RandomRange(min,max)` | ❌ | ✅ |
| レポート card（`device="prv"`）への埋め込み | ✅ | ❌ |
| Web のサブカードへの埋め込み | ❌ | ✅ |
| `autocolor="yes"` | ✅ | ✅ |
| `<table columns="N">` による並列表示 | ✅ | ✅ |

Windows 環境ではチャートは通常 `device="prv"`（印刷プレビュー）の出力 card の中に現れ、Web 環境では `device="sub"` のコンテンツ card に置いて HTML を直接出力します。

---

## 10.12 よく使うパターン早見

```xml
<!-- 折れ線グラフ：データベースのクエリで駆動、2 系列 -->
<dbquery id="xy"><![CDATA[SELECT TOP 12 no, a, b FROM zp]]></dbquery>
<chart title="推移" rangeto="11" dataset="xy" legend="yes">
  <serie type="line" linecolor="#f37735" linewidth="2"
         fieldnamevalue="a" fieldnamexaxis="no"/>
  <serie type="line" linecolor="#00aedb" linewidth="2"
         fieldnamevalue="b" fieldnamexaxis="no" marker="yes"/>
</chart>

<!-- 棒グラフ：プログラムで生成、2 系列を並べる -->
<chart title="比較" rangeto="11">
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

<!-- 円グラフ：手動の色配列 -->
<setvar name="C" value="[0..4]"/>
<setvar name="C[0]" value="#00aedb"/>
<setvar name="C[1]" value="#a200ff"/>
<setvar name="C[2]" value="#f47835"/>
<setvar name="C[3]" value="#d41243"/>
<setvar name="C[4]" value="#8ec127"/>
<chart title="構成比" xaxisposition="none" yaxisposition="none">
  <serie type="pie" pielegend="yes" pieposition="custom"
         pieleft="120" pietop="100" piesize="90"
         pieshowvalues="yes" pievalueposition="outside">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;5">
      <point label="$('項目'+STR(I))"
             value="RandomRange(100,300)"
             color="C[I mod 5]"/>
      <setvar name="I" value="I+1"/>
    </while>
  </serie>
</chart>

<!-- ドーナツグラフ：自動配色 -->
<chart title="分布" autocolor="yes" xaxisposition="none" yaxisposition="none">
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

## 第 11 章　Web ファイルアップロード実践：`<upload>` と `<multiupload>`

——形のまったく異なる 2 種類のアップロード要求。受け取りのロジックはそれぞれ独立

🌐 **Web 専用**

ブラウザーがサーバーにファイルを送る HTTP リクエストには、実はまったく異なる 2 つの形があります。WapForm for Web はそれぞれに別のタグで対応しており、互いに置き換えることはできません：

| | `<multiupload>` | `<upload>` |
|---|---|---|
| 対応するリクエスト形式 | `multipart/form-data`（`<form>` フォームから送信） | 生の PUT（ボディ全体がファイルそのもの） |
| 1 回のファイル数 | 複数可 | 1 つ |
| ファイル名の出どころ | リクエスト自体に元のファイル名が含まれる | リクエストにファイル名がなく、サーバー側で決める必要がある |
| 典型的な場面 | ユーザーが Web ページで「ファイルを選択」してアップロード | プログラム（Windows クライアント、curl）がファイルのバイト列をボディとして直接送る。従来の `upload.php` の受け取り方と互換 |

どちらも、拡張子のホワイトリストによるフィルター、`.wml` の一律ブロック（アップロード先がサイトのルート配下にある場合に、エンジンにテンプレートとして実行されるのを防ぐ）、そして「認識できる形式」に対するファイル先頭のマジックバイト検証を備えており、拡張子を変えただけの偽装ファイルの侵入を防ぎます。

---

### 11.1 `<multiupload>`：複数ファイルの multipart アップロード

`<multiupload>` はブラウザーの `<form enctype="multipart/form-data">` から送られるリクエストに対応します。これは**コンテナ要素**で、ファイルを 1 つ保存するたびに子ノードの内容を 1 回実行するため、ページでファイルごとにサムネイルを表示したり、データベースのレコードを書き込んだりできます。

#### 属性

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `filefield` | (必須) | `<input type="file" name="...">` に対応するフィールド名 |
| `destination` | (必須) | 保存先ディレクトリ。末尾にパス区切り文字が必要 |
| `filename` | (必須) | 保存後のファイル名を書き込む変数（ループ内でファイルごとに更新） |
| `srcname` | (任意) | ユーザー側の元のファイル名を書き込む変数 |
| `index` | (任意) | 現在何番目のファイルか（1 から数える）を書き込む変数 |
| `count` | (任意) | アップロード終了後、保存に成功したファイルの総数を書き込む変数 |
| `result` | (任意) | エラーメッセージを書き込む変数。すべて成功なら空文字列 |
| `accept` | (任意) | 許可する拡張子のホワイトリスト（カンマ区切り）。空なら制限なし |
| `nameconflict` | (任意) | 名前が重なったときの方針。`unique` はタイムスタンプと連番を自動で付けて上書きを防ぐ |

子ノードの中では `filename`／`srcname`／`index` に対応する変数を直接参照でき、ファイルごとに描画できます。

#### 完全な例：`multiupload.wml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<wml>

  <card id="upload" title="ファイルアップロード">

    <div class="narrow">

    <div class="wf-head">
      <div class="wf-badge">WapForm for Web · サンプル</div>
      <div class="wf-title">ファイルアップロード</div>
      <div class="wf-sub">一度に複数のファイルを選べます。サーバー側で重複しない名前に自動で付け直し、結果を報告します。</div>
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
          ファイルごとにデータベースへ書き込むには、下の行のコメントを外し、自分のデータセットに書き換えてください。

        <dbquery id="q" sql="insert into upfile (fname, oname, utime) values ('$(fn)', '$(src)', now())"/>
        -->

      </multiupload>

      <if cnd="n > 0">
        <div class="res-bar">
          <span>✓</span>
          <span>合計 <b>$(n)</b> 個のファイルをアップロード<if cnd="memo &lt;> ''">、説明：$(memo)</if></span>
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

      <div class="card-title">アップロードするファイルを選択</div>
      <div class="card-note">複数選択に対応。同じ名前のファイルにはタイムスタンプと連番が自動で付き、互いに上書きされません。jpg / png / gif / pdf / txt / csv / xlsx / docx / zip を受け付けます。</div>

      <form action="multiupload.wml" method="post" enctype="multipart/form-data">

        <input type="hidden" name="card" value="upload"/>

        <div class="drop">
          <div class="drop-ic">⬆</div>
          <div class="drop-main">ここをクリックしてファイルを選択</div>
          <div class="drop-hint">Ctrl または Shift を押しながら複数選択できます</div>
          <operator><![CDATA[<input type="file" name="myfile" multiple="multiple"/>]]></operator>
        </div>

        <operator><![CDATA[<div class="picked" id="picked"></div>]]></operator>

        <div class="field" style="margin-top:1.25rem;">
          <span class="field-label">説明文（任意）</span>
          <input type="text" name="memo" size="40"/>
        </div>

        <div class="actions">
          <input type="submit" value="アップロード開始"/>
          <span class="actions-note">アップロード後、各ファイルの保存名を一覧表示します</span>
        </div>

      </form>

    </div>

    <div class="foot">
      レイアウトは <code>wapform.htm</code> が、フローとデータは <code>multiupload.wml</code> が定義します。<br/>
      デザイナーは wml に触れずにレイアウトを、エンジニアは htm に触れずにロジックを直せます。
    </div>

    </div>

  </card>

</wml>
```

#### つまずきやすいエンジンの規則

| # | 規則 |
|---|---|
| 1 | `<form>` / `<div>` はエンジンのタグではないので、そのまま出力され、属性（`class` を含む）も保持されます。 |
| 2 | ファイル欄には `<input>` を使えません。エンジンの `_input` は `multiple` を出力しないためです。代わりに `<operator>` で生の HTML を直接書き出します（内容は引き続き `$()` 展開されます）。 |
| 3 | `_input` は `class` を出力しないので、外側を `<div class="field">` で包み、CSS では子孫セレクター（`.field input`）で適用します。 |
| 4 | `<multiupload>` の子ノードは、ファイルを 1 つ保存するたびに 1 回実行されます。 |
| 5 | `cnd=` と `value=` は式を受け取るので、文字列リテラルは自分で単一引用符で包みます。 |
| 6 | 変数表に存在するのは、今回のリクエストで送られてきたフィールドだけです。例の `memo` は最初の `GET` では存在しないため、参照するなら `POST` が確実に発生したブロックに置く必要があります。`filename`／`srcname`／`index`／`count`／`result` に対応する 5 つの変数は `<multiupload>` 自身が作るので、いつでも参照できます。 |
| 7 | 子ノードのない要素は `<div/>` として出力され、HTML では閉じられていない開始タグになり、後続の内容が飲み込まれます。空のコンテナ（中身をフロントエンドの JS で埋める場合）は、必ず `<operator>` で生の HTML を直接書いてください。 |
| 8 | `destination` がサイトのルート配下にある場合（例の `C:\Wapform\wap\` がそう）、アップロードしたファイルは URL で直接アクセスでき、ダウンロード用の wml を別に書く必要はありません。`.wml` はエンジンが一律にブロックし、それ以外の種類は `accept` のホワイトリストで絞ります。アクセスを完全に隔離したい場合は、`destination` をルートの外に向け、ダウンロード用の wml を別に書いて制御します。 |
| 9 | 画像のプレビュー：エンジン組み込みの式関数 `ExtractFileExt`／`LOWER` で拡張子が画像の種類かどうかを判定し、そうであれば `<img src="upload/$(fn)">` でそのまま表示します。 |

---

### 11.2 `<upload>`：生の PUT による単一ファイルアップロード

`<upload>` が受け取るのはまったく形の異なるリクエストです。リクエストボディ全体がファイルそのもののバイト列で、multipart の包みも、フィールド名も、ファイル名もありません。このタグは、従来の `upload.php`（`fopen('php://input')` でボディを直接読み、そのままファイルに書く）の受け取り方と互換になるよう設計されています。**空要素**です。

#### 属性

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `destination` | (必須) | 保存先ディレクトリ |
| `filename` | (任意) | 固定の保存ファイル名。空なら `Content-Disposition` ヘッダーまたはタイムスタンプで決める（下記参照） |
| `accept` | (任意) | 許可する拡張子のホワイトリスト（カンマ区切り）。空なら制限なし |
| `unique` | (任意) | `yes` のとき、ディレクトリに同名のファイルがあれば自動で `_01`、`_02`……を付けて上書きを防ぐ（`nameconflict="unique"` と同じ意味で、どちらの書き方も認識される） |
| `result` | (任意) | エラーメッセージ／状態を書き込む変数。ボディがないと `'empty body'` を受け取る |
| `size` | (任意) | 受信したバイト数を書き込む変数 |
| `savedname` | (任意) | 実際に保存されたファイル名を書き込む変数（動的なファイル名はタグ自身しか知らないため、画面でプレビュー画像を表示するにはこれが必要） |

#### ファイル名の決定順序

生の PUT リクエストには使えるファイル名がないため、`<upload>` は次の順で実際の保存ファイル名を決めます：

1. **`filename` が書かれている** → そのファイル名に固定します（`upload.php` と同じ動作で、再アップロードすると同じファイルを上書きします。`unique="yes"` も併用した場合は、名前が重なったときだけ後ろに連番を付けます）。
2. **`filename` はないが、リクエストに `Content-Disposition: attachment; filename="..."` がある** → そのファイル名をそのまま使います（`<webcopy>` の `httpupload` はこのヘッダーを自動で付けます。第 12 章参照）。
3. **どちらもない** → タイムスタンプ（`yymmddhhnnsszzz`）でファイル名を作り、拡張子はリクエストの `Content-Type` から推定します（下表参照）。認識できない種類は一律 `.jpg` とみなします。

`filename` には外部からの入力も使えます。たとえば `filename="$(name)"` と URL の `?name=...` を組み合わせます。タグの内部でパスを取り除き、`..` とドライブ文字をブロックしてから拡張子のホワイトリストと照合するので、パストラバーサル攻撃を防げます。

`unique="yes"` が担当するのは名前の衝突です。ディレクトリに同名のファイルがあれば、重ならなくなるまで後ろに `_01`、`_02`……を付け、互いに上書きしません。これは「ファイル名をどう決めるか」とは独立した仕組みです。

#### Content-Type → 拡張子の推定表

| Content-Type | 拡張子 |
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
| その他 | `.jpg`（既定） |

送信時の `Content-Type` は実際のファイルの種類と必ず一致させてください——たとえば PDF を送るのに `image/jpeg` と宣言すると `.jpg` と推定され、続くファイル先頭の検証で中身が実は PDF で `.jpg` と合わないことが判明し、保存を拒否されます。推定に頼りたくなければ、`filename` 属性で拡張子を直接指定するのが最も確実です。

#### ★ 最もはまりやすい落とし穴：正しい Content-Type を必ず指定する

送信側が `<upload>` を呼ぶときは、**必ず `Content-Type` を指定し、しかも `application/x-www-form-urlencoded` であってはなりません**（多くの HTTP ライブラリの既定値で、curl の `--data-binary` や ICS の `THttpCli` も含みます）。

この落とし穴は症状がわかりにくいのが厄介です。サーバーは「何かを受け取り」、長さもまったく正しいのに、ファイル先頭のバイトがこっそり書き換えられ、保存された画像が開けません。原因は、サーバー側の HTTP コンポーネントが `application/x-www-form-urlencoded` を見るとボディをフォームのテキストだと判断し、どの処理ロジックに渡すよりも前に文字列として一度処理してしまうことです。その過程で Windows の best-fit 文字変換が行われます。バイトを Latin-1 の文字とみなして ANSI のコードページに変換し、対応できないバイトは「最も見た目が近い」ASCII の文字に置き換えます（たとえば `FF` → `y`、`D8` → `O`、`E0` → `a`）。JPEG の先頭の `FF D8 FF E0` はこうして別のバイトに置き換えられ、`< 0x80` のバイトは影響を受けないので、「先頭の数バイトだけ壊れた」ように見えます。この処理はサーバー側の読み取りより前に起こるため、`<upload>` タグ自体ではまったく救えず、送信側が最初から正しい `Content-Type`（`image/jpeg`、`image/png`、`application/octet-stream` などいずれでも可）を指定するしかありません。

#### 完全な例：`upload.wml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<wml>

  <card id="upload" title="生の PUT による単一ファイルアップロード">

    <div class="narrow">
      <div class="wf-head">
        <div class="wf-badge">WapForm for Web · サンプル</div>
        <div class="wf-title">生の PUT による単一ファイルアップロード</div>
        <div class="wf-sub">リクエストボディ全体が 1 つのファイルで、multipart の包みはありません。upload.php の受け取り方と互換です。</div>
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
          <span><b>$(up_name)</b> を保存しました。合計 $(up_size) バイトです。</span>
        </div>
        <div class="card">
          <div class="card-title">保存結果</div>
          <img class="up-preview" src="upload/$(up_name)" alt="$(up_name)"/>
        </div>
      </if>

      <if cnd="up_err &lt;> ''">
        <div class="alert">
          <span>!</span>
          <span>今回は保存しませんでした：$(up_err)</span>
        </div>
      </if>

      <div class="card">
        <div class="card-title">テスト方法</div>
        <div class="card-note">
          このページはフォームではなく、ファイルを選ぶボタンもありません——生の PUT はブラウザーの通常のフォームでは送れないため、
          プログラム（または curl）でファイルの内容をリクエストボディとして直接送ってください。
        </div>

        <div class="alert">
          <span>!</span>
          <span>
            送信時は<b>必ず Content-Type を指定</b>してください（例 <code>image/jpeg</code>）。
            既定の <code>application/x-www-form-urlencoded</code> は使えません。
          </span>
        </div>

        <div class="card-note">
          <b>Windows クライアント（Unit2.pas の UploadFile）を使う場合：</b>
        </div>
        <div class="code-block">
          HttpCli.URL := 'http://localhost:8080/wap/upload.wml';<br/>
          HttpCli.ContentTypePost := 'image/jpeg';<br/>
          HttpCli.SendStream := Stream;<br/>
          HttpCli.RequestVer := '1.1';<br/>
          HttpCli.Put;
        </div>

        <div class="card-note">
          <b>curl を使う場合：</b>
        </div>
        <div class="code-block">
          curl -X PUT --data-binary "@C:\Wapform\a02.jpg" -H "Content-Type: image/jpeg" http://localhost:8080/wap/upload.wml<br/>
          <br/>
          PDF を送るなら対応する種類に変える必要があり、image/jpeg のままでは使えません：<br/>
          curl -X PUT --data-binary "@C:\Wapform\aaa.pdf" -H "Content-Type: application/pdf" http://localhost:8080/wap/upload.wml<br/>
          <br/>
          保存ファイル名を指定したい場合は、Content-Disposition ヘッダーを付けます：<br/>
          curl -X PUT --data-binary "@C:\Wapform\a02.jpg" -H "Content-Type: image/jpeg" -H "Content-Disposition: attachment; filename=\"a02.jpg\"" http://localhost:8080/wap/upload.wml
        </div>
      </div>

    </div>

    <div class="narrow">
      <div class="foot">
        レイアウトは <code>wapform.htm</code> が、受け取りのロジックは <code>&lt;upload&gt;</code> タグが提供します。<br/>
        <code>multiupload.wml</code> とは別の形のアップロードです——あちらはブラウザーのフォームの
        multipart、こちらは生の PUT で、両者のタグは入れ替えられません。
      </div>
    </div>

  </card>

</wml>
```

このページをブラウザーで直接開いても（`GET`）エラーにはなりません。ボディがないので `result` に `'empty body'` が入り、画面には使い方の説明ブロックが表示されるだけです。

---

### 11.3 セキュリティ機構のまとめ

`<upload>` でも `<multiupload>` でも、3 層の防御が組み込まれています：

| 層 | 仕組み |
|---|---|
| 拡張子のホワイトリスト | `accept` 属性に許可する拡張子をカンマ区切りで列挙。空なら制限なし |
| テンプレートの一律ブロック | `.wml` は `accept` の制御を受けず、常に拒否——アップロード先がサイトのルート配下にあると `.wml` はエンジンに「実行」されてしまい、アップロードできる人なら誰でも任意のテンプレートを動かせることになる |
| ファイル先頭のマジックバイト検証 | 「認識できる形式」については実際の内容をもう一度検証：`jpg/jpeg`、`png`、`gif`、`bmp`、`pdf`、`zip`（`docx`/`xlsx`/`pptx` は中身が zip なので先頭はどれも `PK`）、`doc/xls/ppt`（Office 97-2003 の OLE2 複合文書で、先頭はどれも `D0 CF 11 E0`）。決まった先頭を持たない形式（`txt`、`csv` など）はこの検査をせずにそのまま通す |

これは「別の種類のものを拡張子だけ変えて送り込む」ことを防ぐためです——たとえば PDF の名前を `.jpg` に変えると保存を拒否されます。

---

### 11.4 本章のまとめ

| 場面 | 使うタグ |
|---|---|
| Web ページの「ファイルを選択」フォーム。複数選択の可能性あり | `<multiupload>`（`multipart/form-data`） |
| プログラムや curl がファイルのバイト列をボディとして直接 PUT する。`upload.php` と互換 | `<upload>`（生の PUT） |
| Windows 側からローカルのファイルをこの 2 つの受け取りページに送る | 第 12 章の `<webcopy protocol="httpupload">` を参照——それが送るリクエストは `<upload>` の形に合っており、`Content-Disposition` と正しい `Content-Type` も自動で付ける |

---

## 第 12 章　Windows ファイル転送実践：`<open>` と `<webcopy>`

——ローカルファイルの選択、移動、アップロード、ダウンロード

🖥️ **Win 専用**

Windows 側にはブラウザーの `<form>` がないため、ローカルファイルの出し入れには 2 つのタグを組み合わせます。`<open>` がシステムのファイル選択ダイアログを表示し、`<webcopy>` が `protocol` 属性に応じてファイルシステム、HTTP、FTP の間でファイルを転送します。2 つはよくペアで使われます：ユーザーがファイルを選ぶ → 目的地へアップロードまたは移動する。

---

### 12.1 `<open/>`：システムのファイル選択ダイアログ

空要素で、OS ネイティブの「ファイルを開く」ダイアログを表示し、ユーザーにローカルファイルを選ばせます。

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `filename` | (必須) | ユーザーが選んだフルパスを書き込む変数 |
| `result` | (必須) | ユーザーが確定を押したかを書き込む変数。`1` は確定、それ以外はキャンセル |

```xml
<setvar name="I" value="0"/>
<setvar name="F" value="''"/>
<open filename="F" result="I"/>
<if cnd="I=1">
  <!-- ユーザーがファイルを選び終えた。F はフルパス -->
</if>
```

必ず先に `result`（例の `I=1`）を判定してから `filename` の変数の内容を使ってください。そうしないと、ユーザーがキャンセルを押したとき、変数に以前の値が残っている可能性があります。

---

### 12.2 `<webcopy/>`：5 種類のプロトコルによるファイル転送

空要素で、`protocol` 属性によって動作が決まり、「ローカルのファイルシステム」「HTTP」「FTP」の間でファイルを転送します。Windows 側で唯一の組み込みファイル転送手段です（Web 側には対応するタグがなく、第 11 章の `<upload>` / `<multiupload>` でサーバー側が受け取ります）。

#### 属性一覧

| 属性 | 必須／任意 | 説明 |
|---|---|---|
| `protocol` | (任意、既定 `file`) | `file`／`httpupload`／`httpdownload`／`ftpupload`／`ftpdownload` のいずれか |
| `host` | プロトコルによる | 意味は `protocol` によって変わる。下表参照 |
| `url` | プロトコルによる | 意味は `protocol` によって変わる。下表参照 |
| `dir` | プロトコルによる | 意味は `protocol` によって変わる。下表参照 |
| `username` / `password` | FTP プロトコルでは必須 | FTP のログインアカウントとパスワード |
| `unique` | (任意) | この属性があれば `true` を意味する：タイムスタンプ（`yyyymmddhhnnsszzz`）でファイル名を作り、`dir` のディレクトリでなお重なれば、重ならなくなるまで `_01`、`_02`……を付ける（最大 999 回試行） |
| `result` | (任意) | 成功時は実際に保存／アップロードされたファイル名、失敗時はエラーメッセージを書き込む |
| `errmsg` | (任意) | 失敗時はエラーメッセージを書き込み、成功時は空文字列にする |
| `response` | (任意、`httpupload` のみ有効) | サーバー応答の生の内容（HTTP response body）を書き込む |

#### 5 種類のプロトコルの `host` / `url` / `dir` 対照表

| `protocol` | `host` | `url` | `dir` |
|---|---|---|---|
| `file` | 保存先ディレクトリ（末尾に `\` が必要） | 取得元のフルパス | — |
| `httpupload` | アップロード先 URL | ローカルファイルのパス | — |
| `httpdownload` | 取得元 URL | — | 保存先ディレクトリ |
| `ftpupload` | FTP ホスト | ローカルファイルのパス | FTP 上のディレクトリ |
| `ftpdownload` | FTP ホスト | FTP 上のファイル名 | ローカルの保存先ディレクトリ |

各プロトコルの動作の詳細：

- **`file`**：ローカルのファイルシステム内でコピーします。取得元（`url`）がなければエラーを返します。保存先（`host` + ファイル名）に同名のファイルがすでにある場合は**上書きせず**、そのまま飛ばして「ファイルは既に存在します」と報告します。
- **`httpupload`**：HTTP `PUT` でローカルファイル（`url`）を `host` にアップロードします。拡張子に応じて正しい `Content-Type` を自動で設定し（`.jpg/.png/.gif/.bmp/.pdf/.zip/.txt/.csv/.doc/.xls/.ppt/.docx/.xlsx/.pptx` に対応し、それ以外の種類は一律 `application/octet-stream` で送る）、`Content-Disposition: attachment; filename="..."` ヘッダーを自動で付け、さらに URL に `?name=` または `&name=` を付加します——第 11 章の `<upload>` タグと組み合わせたときに相手が元のファイル名を得られるのはこのためです。HTTP ステータスコードが `200` 以外なら失敗とみなします。
- **`httpdownload`**：HTTP `GET` で `host` から `dir` ディレクトリにダウンロードします。ファイル名が指定されていないか推定できない場合は、取得元 URL のファイル名、さらにタイムスタンプへとフォールバックします。HTTP ステータスコードが `200` 以外なら失敗とみなします。
- **`ftpupload`** / **`ftpdownload`**：FTP プロトコルで転送します。`username`／`password` はログインに必要な情報です。

#### 完全な例：`webcopy.wml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<wml>

  <card id="webcopy" title="ファイル転送テスト" width="960">

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
        <td width="900"><label name="R">（未実行）</label></td>
      </tr>
      <tr>
        <td>errmsg: </td>
        <td><label name="E">（未実行）</label></td>
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

    <do type="prev" label="閉じる">
      <prev/>
    </do>

  </card>

</wml>
```

このページは 6 種類のプロトコルをそれぞれボタンにしたもので、押すとすぐに `result` / `errmsg` の 2 つのラベルに結果が表示されます。新しいプロジェクトを引き受けたときのプロトコル動作の検証ページに向いています——`host`／`url`／`dir` の 3 つの属性の意味はプロトコルごとに違うので、表を覚えるより一通り実際に試すほうが確実です。

---

### 12.3 実践での組み合わせ：`<open>` + `<webcopy httpupload>` による画像アップロードとプレビュー

`app002.wml`（商品マスター）は、Windows 側で最もよくある画像管理の組み合わせを示しています。ユーザーが「開く」を押して画像を選ぶ → `<webcopy protocol="httpupload">` で Web 側の `upload.wml` にすぐアップロード → アップロードに成功したら返されたファイル名で画像の URL を組み立て、画面上のプレビュー画像をその場で更新します。

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
      <log message="アップロード失敗: $R"/>
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

画面上のトリガーと `afterscroll` イベントの組み合わせ：

```xml
<td>アイコン：<a href="@A0">開く</a>|<a href="@B0">消去</a><br/><br/>
    <img id="g0" width="300" height="300" src="$('http://localhost:8080/wap/upload/'+paicon)"/>
</td>
```

```xml
<onevent type="afterscroll">
  <log message="$(paicon)"/>
  <setprop name="g0" prop="img" value="'$('http://localhost:8080/wap/upload/'+paicon)'"/>
</onevent>
```

**フローの分解：**

| 手順 | 説明 |
|---|---|
| 1. `<open filename="F" result="I"/>` | ファイル選択ダイアログを表示する。`I=1` はユーザーが選択を確定したことを表し、`F` はローカルのフルパス |
| 2. `<webcopy protocol="httpupload" ...>` | `F` が指すローカルファイルを `httpupload` で Web 側の `upload.wml`（第 11 章の `<upload>` タグがあるページ）にアップロードする。`R` には成功時は保存ファイル名、失敗時は `failed` を含むエラーメッセージが入る |
| 3. `Pos('failed', R)=0` | 文字列検索でアップロードの成否を判定する——`SetErr` 系のエラーメッセージはどれもプロトコル名で始まり `failed` を含むので、これが `<webcopy>` の定番の判定方法 |
| 4. 成功：`paicon` にファイル名を保存し、`<setprop img>` で画像の URL を設定し直す | Web 側のアップロード先がサイトのルート配下にあれば（第 11 章 11.1 節参照）、保存したファイルはもともと URL で直接アクセスでき、ダウンロード用の wml を別に書く必要はない |
| 5. `B0`／消去 | `paicon` を固定の既定画像のファイル名に戻し、「既定の画像に戻す」効果を得る |
| 6. `afterscroll` | ページ移動（`navigator`／レコードカーソルのスクロール）のたびに `paicon` に対応する URL を適用し直し、別のレコードに切り替えたときも画像が同期して更新されるようにする |

> この組み合わせこそ、第 11 章と第 12 章がつながる部分です。`<webcopy protocol="httpupload">` が送るリクエスト（拡張子から自動設定される `Content-Type`、元のファイル名を持つ `Content-Disposition`、URL に付く `?name=`）は、第 11 章の `<upload>` タグが受け取る際に想定している形式と完全に一致しており、両者の間に追加の変換は必要ありません。

**📱 Flutter**

`<open>` と `<webcopy>` には WapForm for Flutter での対応タグがありません。同じ `.wml` で Flutter でも画像をアップロードしたい場合は、`<platform>` で Windows の書き方と Flutter の Dart の書き方を分けます。完全な例（`app002.wml`）は 4.5 節の `<platform>` を参照してください。

---

### 12.4 本章のまとめ

| 技術 | 用途 |
|---|---|
| `<open filename result/>` | システムのファイル選択ダイアログを表示し、ローカルファイルのパスを得る |
| `<webcopy protocol="file">` | ローカルのファイルシステム内でコピーする。保存先に同名ファイルがあれば上書きしない |
| `<webcopy protocol="httpupload">` | HTTP PUT でローカルファイルをアップロードし、`Content-Type` と `Content-Disposition` を自動で付ける。第 11 章の `<upload>` タグと直接つながる |
| `<webcopy protocol="httpdownload">` | HTTP GET でファイルをローカルのディレクトリにダウンロードする |
| `<webcopy protocol="ftpupload">` / `protocol="ftpdownload">` | FTP でアップロード／ダウンロードする |
| `unique="yes"` | 5 種類のプロトコルに共通の名前衝突対策：タイムスタンプと連番を付け、既存ファイルを上書きしない |
| `result` / `errmsg` | 成功ならファイル名、失敗ならエラーメッセージを返す定番のペア |
| `Pos('failed', R)=0` | `<webcopy>` の実行成否を判定する定番の書き方 |

---

## 第 13 章　クロス集計実践

——営業の販売分析の実践

🌐 **Web 版**

---

## 13.1 WapForm クロス集計の本質

WapForm のクロス集計（Crosstab）は、開発者が純粋な宣言型の XML でピボット分析を記述できるようにします——行グループ、列グループ、交差セルの集計、小計行、総計列のすべてを、`<crosstab>`、`<row change>`、`<col change>`、`<setvar>` の組み合わせで実現します。

`<crosstab>` は内部で `<report>`（第 4 章 4.7 節参照）と同じ行／列グループの仕組みを共有していますが、次元が 1 つ増えます。`<report>` には「行」（グループ＋明細）しかありませんが、`<crosstab>` は「行 x 列」の 2 次元の行列で、交差セルの 1 つ 1 つが集計値です。

本章の出力対象は**ブラウザーで描画される HTML の `<table>`** で、`card` タグに `device=` 属性を指定しない場合の既定の経路です。WapForm は `device="prv"`（印刷プレビュー）、`device="prn"`（直接印刷）などの出力モードにも対応していますが、それらは別のコード分岐を通るため本章では扱いません——それらの経路は実際にテストしておらず、不確かなことは書かないほうがよいと判断しました。内容がいかにも完全に見えて実は間違っている、という事態を避けるためです。

本章では、営業の販売分析の「販売クロス集計表」（`crosstab.wml`）を例にします。横軸は年度と年月の 2 階層のグループ、縦軸は営業担当者と顧客の 2 階層のグループ、交差セルは売上金額で、各行・各列の小計と総計を自動で生成します。この例は現在 WapForm for Web のオンラインサンプルサイト（`example.wml` のトップページにある「クロス分析」カード）で実際に動いており、机上の空論の見本ではありません。

> **本章の信頼性について**：クロス集計は WapForm のエンジン全体の中で最もロジックが複雑で、最も書き間違えやすい機能です。本書のコードの 1 つ 1 つ、変数の役割の 1 つ 1 つは、実際にデプロイし、実際にクラッシュさせ、実際に修正し、実際にスクリーンショットで検証した結果であり、ソースコードから推測したものではありません。その過程ではまった落とし穴（特に 13.8 節の変数の選び方）は、同じ失敗を繰り返しやすいところなので、特に紙幅を割いて説明しています。

---

## 13.2 システム概観

```
販売クロス集計表（crosstab.wml）

実行フロー：
  card crosstab — メインレポート（ブラウザーで描画、device= 属性なし）
    ↓
  dbquery xy — sh（売上伝票ヘッダー）+ cu（顧客）から販売明細を検索。SQL 側で先に group by で集計
    ↓
  <crosstab> — クロス集計エンジン

データ構造：
  行軸（Row、<row change> を 2 階層ネスト）：
    eno   — 営業担当者コード（第 1 階層のグループ）
    cno   — 顧客コード（第 2 階層のグループ）
  列軸（Column、<col change> を 2 階層ネスト）：
    yy    — 年度（第 1 階層のグループ）
    ym    — 年度＋月（第 2 階層のグループ、例 202006）
  値フィールド：
    amount — 売上金額。SQL 側で group by により集計済みで、交差セルは 1 回埋めるだけでよい

制御変数：
  I, J, K     — ループと列のカウンター
  N           — 現在のセルの値（VAL 変換後）
  T           — 予約フィールド、現在は未使用
  C, R        — 現在の列見出しの値、現在の行グループ名
  A, B        — 行の小計（年度小計）、行全体の横方向の合計
  X[1..999]   — 現在の営業担当者グループの列合計の配列
  Y[1..999]   — 全営業担当者の列総計の配列（Grand Total）
```

---

## 13.3 データ検索：SQL 側で先に集計する

クロス集計のデータセットは、**行軸のフィールド**、**列軸のフィールド**、**値のフィールド**を同時に提供する必要があります。この例ではさらにひと手間かけ、明細を 1 件ずつエンジンに渡して `<crosstab>` 自身の累計ロジックに重複処理を任せるのではなく、**`group by` で SQL 側で金額を先に集計**しています：

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

**なぜ先に group by するのか**：`(年月, 営業担当者, 顧客)` の組み合わせごとに SQL の集計で 1 件しか返らないため、クロス集計内部の累計ロジック（`Cell()` 関数）は「そのセルに初めて書き込む」場合だけを扱えばよく、同じセルに何度も書き込まれる累計を正しく処理してくれることに頼らずに済みます——動作がより予測しやすく、速くもなります。

**`order by` は省略できない**：`<row change="...">` / `<col change="...">` は「前の行と比べて変わったか」でグループの境界を判定するため、データがグループのキー順に並んでいないと、同じグループがいくつにも分断され、見出しが重複して印刷されます。ここでの `order by` の順序（`yy, ym, eno, cno`）は、意図的にグループ階層のネストの順序と一致させています。外側の列キーが先、内側の列キーが後、外側の行キーが先、内側の行キーが後です。

**日付の範囲はわざと年度をまたいでいる**：`2020-06-01` から `2021-04-01` は 2020 年と 2021 年の 2 つの年度にまたがっており、`yy`（外側の列、年）→`ym`（内側の列、年月）の 2 階層の列グループが年をまたいでも正しいことを検証するためです。1 年度だけだと外側の `yy` グループは常に 1 つの値しかなく、年をまたぐグループ境界が正しいかを確かめられません。

---

## 13.4 `<crosstab>` ルート要素の属性

```xml
<crosstab dataset="xy" dialog="cno;sdate" field="amount" autospan="yes">
```

| 属性 | 値 | 実際の状態 |
|---|---|---|
| `dataset` | `xy` | **効果あり**。データソース（`<dbquery>` の id）を指定 |
| `field` | `amount` | **効果あり**。交差セルの値フィールド名 |
| `dialog` | `cno;sdate` | **現行のエンジンでは解析するだけで使わない**。書いてもダイアログは表示されない |
| `autospan` | `yes` | **効果あり**。見出し領域で隣接する同じ内容のセルを結合する（`colspan`/`rowspan`） |

`dialog=` という属性名は「実行前にポップアップで絞り込む」もののように聞こえますが、`_report`／`_crosstab` のソースコードを実際に追うと、`Dlg` はローカル変数で、読み込んだ後はどこからもその値を読んでいません——事実上の死んだコードで、書いてもダイアログは表示されず、絞り込みは自分で SQL の `where` 条件に書く必要があります。

**一方 `autospan=` は本当に効果があります**。ただしそれは `_crosstab` 自身のコードにはなく、`TCard` のフィールドです——`_crosstab` は属性値に応じてそれを設定するだけで、実際に読み取って適用するのはセルを描画する `_td` です。動作は標準的な「先に測って後で結合する」2 段階です：

1. **測定段階**（`Printable=0`）：隣接するセルの内容が同じかを 1 つずつ比較し、同じなら「連続して同じセルの数」を内部の配列に累計します。
2. **描画段階**（`Printable=1`）：その累計値を読み戻し、1 より大きければ `<th>`／`<td>` に `colspan="N"` または `rowspan="N"` を出力して、それらのセルを 1 つに結合します。

この仕組みは**見出し領域でのみ有効**で（営業担当者／顧客／年／年月の列または行。判定基準は 13.8 節で触れる同じ `Row.Count`／`Col.Count` のしきい値）、データセルには影響しません。実際の効果としては、同じ営業担当者の下に複数の顧客がいるとき、営業担当者コードは結合されたセルに 1 回だけ縦方向中央揃えで表示され、行ごとに重複して印刷されることはありません——これはブラウザーによる `rowspan` セルの既定の表示であり、追加のスタイル設定ではありません。

---

## 13.5 状態変数の初期化

`<crosstab>` ルート要素の下の `<setvar>` で、レポート全体の期間を通じて共有する状態変数を宣言します：

```xml
<setvar name="I" value="0"/>    <!-- 汎用のループカウンター -->
<setvar name="J" value="0"/>    <!-- 予約、現在は未使用 -->
<setvar name="K" value="0"/>    <!-- 現在の列セルの数（小計列を含む）。小計／総計行の位置合わせに使う -->
<setvar name="N" value="0"/>    <!-- 現在のセルの値（VAL 変換後） -->
<setvar name="T" value="0"/>    <!-- 予約、現在は未使用 -->
<setvar name="C" value="''"/>   <!-- 現在の列グループの見出し（年度の値） -->
<setvar name="R" value="''"/>   <!-- 現在の行グループの見出し（営業担当者コード） -->
<setvar name="A" value="0"/>    <!-- 現在の行の、現在の年の小計 -->
<setvar name="B" value="0"/>    <!-- 現在の行（1 顧客）の全期間の合計 -->
<setvar name="X" value="[1..999]"/>  <!-- 現在の営業担当者の列合計の配列 -->
<setvar name="Y" value="[1..999]"/>  <!-- 全営業担当者の列総計の配列 -->
```

`X`、`Y` を `[1..999]` の配列として宣言しているので、最大 999 列（TOTAL/AMOUNT の小計列を含む）まで扱え、実務上は十分すぎる量です。`I`、`K` はインデックス用の整数、`C`、`R` は文字列、`A`、`B`、`N` は数値です——これらの型は**最初の `<setvar>` で与えた値**で決まり、以後同じ変数には同じ型のものしか入れられません。違う型の値を入れるとフレームワークは強制変換を試み、変換できなければサーバーが例外を投げます（詳しくは 13.8 節のデバッグの話を参照）。

---

## 13.6 表コンテナと改ページの設定

```xml
<page>
  <table class="xtab-table" rows="20" cols="15">
```

`rows=`／`cols=` は**本当に効果がある** 2 つの属性で、フレームワーク内部の `Wap.LinesPerPage`／`CrossRow`／`CrossCol` を駆動し、データの行数または列数がこの数を超えると自動で改ページ（`NewPage()`）が起こります。

> **既知の問題：Web ブラウザーでの閲覧時、改ページによって HTML の構造が不正になる。**
>
> `NewPage()` は改ページ時に 2 つのことをします。まず `<p class="newpage"></p>` を出力し、次に**前の `<table>` を閉じないまま `<table>` タグをもう一度開きます**。ブラウザーは「表の中にまた表を開く」という不正な HTML を受け取ると独自に補正しようとし、その結果、見出しがなぜかデータの途中に移動したり、前後 2 つの表が見た目上くっついたりして、きれいに改ページされません。
>
> これはエンジン自体の動作で、CSS で完全に解決できる問題ではありません。Web 版にはもともと横／縦のスクロールがあるので、自動改ページは必ずしも必要ありません。改ページの効果が不要なら、**`rows=`／`cols=` の 2 つの属性を書かない**（または決してトリガーされないほど大きな数を指定する）のが最も簡単で、クロス集計表全体が 1 つの連続したきれいな `<table>` になります。この 2 つの属性は、`device="prn"`／`device="prv"` のようにプリンターや印刷プレビューに出力する場面に向いています。そこでは「改ページ」が意味のある物理的な概念ですが、ブラウザーでは通常必要ありません。

---

## 13.7 行軸の定義：`<row change>`

行軸の構造は、外側（営業担当者）から内側（顧客）へ、2 階層の `<row change>` のネストで定義します：

```xml
<row change="xy.eno">
  <setvar name="I" value="1"/>
  <while cnd="I&lt;=99">
    <setvar name="X[I]" value="0"/>    <!-- 新しい営業担当者グループのたびに列合計を消去 -->
    <setvar name="I" value="I+1"/>
  </while>

  <row change="xy.cno">
    <setvar name="K" value="0"/>       <!-- この行のセルカウンターをリセット -->
    <setvar name="B" value="0"/>       <!-- この行の横方向の合計をリセット -->
    <tr>
      ...
    </tr>
  </row>
</row>
```

`<row change="xy.eno">` は営業担当者コードが変わったときにトリガーされ、列合計の配列 `X[1]`～`X[99]` をリセットして、次の営業担当者グループの値を累計し直す準備をします。`<row change="xy.cno">` は顧客コードが変わったとき（つまりレポートの各行を出力するとき）にトリガーされ、ここで `K`、`B` をゼロに戻してこの行の累計の起点にします。

---

## 13.8 セルの描画：`row`／`col` ではなく `cellrow`／`cellcol`／`cell`

これはクロス集計の仕組み全体の中で**最も書き間違えやすく、私たちが実際にはまった落とし穴**であり、詳しく説明する価値があります。

エンジンは各セルを描画するとき、**まったく異なる 2 組の位置変数**を同時に管理しています：

| 変数 | 開始値 | 出どころ | 用途 |
|---|---|---|---|
| `AROW` / `ACOL` | 0 から数える | crosstab 内部のグリッドのインデックス（`ARow`/`ACol` 変数） | エンジン内部用。**テンプレートで直接参照するのは推奨しない** |
| `cellrow` / `cellcol` | 1 から数える | `Wap.RowNumber` / `Wap.ColNumber`。`<tr>`／`<td>` の描画時に自然に増えるカウンターで、通常の表と共通 | **テンプレートではこちらを使う** |

2 組はそれぞれ独立したまったく無関係な変数で、大文字・小文字の問題ではありません——`cell`（小文字）がエンジン内部の `CELL`（大文字）に対応するのは、フレームワークの `SetVar`/`GetVar` が内部で識別子を大文字に変換してから検索するためで、識別子はもともと大文字・小文字を区別しないからです。しかし `cellrow`/`cellcol` と `AROW`/`ACOL` は名前がまったく異なる 2 つの変数で、このような大文字・小文字の等価関係はありません。

テンプレートで誤って `AROW`/`ACOL` を見出し／データの境界の判定に使うと、軽ければ画面の見出しとデータがずれ、重ければ交差セルの文字ラベル（たとえば年度の見出し `'2020'`）をデータセルと誤判定して数値変換関数に渡し、サーバーが直接例外を投げてクラッシュします。これはまさに、この例を実際にデプロイしたときに本当に起きたエラーです——`EConvertError`（`'Q1' is not a valid integer value`）と `EVariantInvalidArgError`（`Invalid argument`）という 2 種類の異なる例外は、根本原因がどちらも同じ、位置変数の使い間違いでした。

正しい書き方（実際にデプロイした版で、追加のスタイル判定を 1 つ含む）：

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

**しきい値「3」の由来**：`cellrow`／`cellcol` は 1 から数え、見出しの行数は列グループの階層数（この例では `YY`、`YM` の 2 階層）、見出しの列数は行グループの階層数（この例では `eno`、`cno` の 2 階層）に等しくなります——どちらも 2 階層なので、見出し領域は第 1、2 行と第 1、2 列を占め、`cellrow<3`／`cellcol<3` がちょうどこの範囲をカバーし、データは第 3 行、第 3 列から始まります。グループの階層数が 2 でない場合は、このしきい値も階層数に合わせて調整します（しきい値＝階層数＋1）。

**`(cellrow<3) or (cellcol<3)` のような複合条件は使えます**：実際にテストしたところ、`Condiction()` は `or`／`and` のキーワードによる条件の組み合わせに対応しており、`<elseif>` のネストに分ける必要はありません。

**ネストした `(cellrow=2) and (cellcol<3)` は追加のスタイル判定です**：見出し領域をさらに 1 段細分し、第 2 行かつ行見出しの列（`cellcol<3`）にあるセルは `<i>` の斜体、固定幅 120px で表示し、それ以外の見出しセルは通常のスタイルにしています。これは必須のロジックではなく、この例が特定位置の見出しの文字に対して行ったレイアウトの微調整にすぎないので、必要に応じて外したり変更したりできます。

**`<debug message="...">` は現在何も出力しません**：このタグはフレームワークの `_log` 関数に対応しており、その関数は現在 `message=` 属性を解析するだけで、内容をどこにも書き出しません（Echo もファイル書き込みもしない）。この例に `<log message="$cellrow $cellcol $cell"/>` が残っているのは、出力に一切影響しないからで、外しても残しても同じです。開発時に `cellrow`/`cellcol`/`cell` の現在値を本当に確かめたい場合は、実際に内容を出力するタグを使ってください。たとえば一時的に `<label>[$(cellrow),$(cellcol),$(cell)]</label>` を差し込みます。

---

## 13.9 列末の小計列（TOTAL 列）

各年度グループの右端には小計列が自動的に追加され、`<if cnd="cellcol>3">` によって出力がトリガーされます：

```xml
<if cnd="cellcol&gt;3">
  <if cnd="cellrow=1">
    <th width="60" align="center">$C</th>       <!-- 見出しの 1 行目：年度の値を表示 -->
  </if>
  <if cnd="cellrow=2">
    <th width="60" align="center">TOTAL</th>    <!-- 見出しの 2 行目：固定で "TOTAL" を表示 -->
  </if>
  <if cnd="cellrow&gt;2">
    <td align="right">$(FORMAT('%d',A))</td>    <!-- データ行：この年度の横方向の小計を出力 -->
  </if>
  <setvar name="K" value="K+1"/>
  <setvar name="X[K]" value="X[K]+A"/>          <!-- 小計列も列合計の配列に含める -->
  <setvar name="Y[K]" value="Y[K]+A"/>
</if>
```

この部分は**外側の** `<col change="xy.YY">` の中、内側の `<col change="xy.YM">` の後に置きます——エンジンのネストした `<col>` タグの内容のうち、ネストした子階層より後ろの部分は、外側のグループキーが変わろうとするときに 1 回だけトリガーされ、ちょうど「1 年度分のすべての月を処理し終えたら、その年度の小計を 1 回印刷する」タイミングに対応します。

---

## 13.10 行末の AMOUNT 列（横方向の総合計）

各行の右端には行全体の横方向の総合計を出力します。位置は `<col change="xy.YY">` の外、`</tr>` の前です：

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

`B` はこの行を走査する間にセルごとに累計され（各データセルで `B := B+N` を行う）、ここでは最終値をそのまま出力します。`K` はさらに進めてこの列の配列内の位置を記録し、後の小計行／総計行でもこの列を正しく揃えて出力できるようにします。

---

## 13.11 グループ末の小計行（TOTAL 行）

内側の `<row change="xy.cno">` が終わった後、すでにデータ行に入っていれば（`cellrow>3`）、営業担当者をグループとする横方向の小計行を出力します：

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

`R` には各行の `cellcol=1` のときに現在の行グループの名前を格納しており（`<setvar name="R" value="cell" cnd="cellcol=1"/>`）、ここではそれを直接参照して出力します。`X[1]`～`X[K]` のループにより、小計行の各列は対応するデータ列と揃い、年度グループの TOTAL 列と右端の AMOUNT 列も含まれます。

**しきい値 `cellrow>3` の意味**：13.8 節と照らし合わせると、データは `cellrow=3` から始まります。この判定式は最初のトリガー（`cellrow=3`、まだ何も累計されていない初期状態）を除外し、本当に「次の営業担当者に切り替わる直前」にだけ小計を印刷します——これはコントロールブレイク型レポートの標準的な書き方で、適当に選んだ数字ではありません。

---

## 13.12 最終の総計行（Grand Total）

すべての `<row change>` が終わった後、レポート全体の縦方向の総計行を出力します：

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

`Y[1]`～`Y[K]` はすべての行のすべてのセルから累計され、最初に一度ゼロにするだけなので、ここで出力されるのはレポート全体の Grand Total で、営業担当者グループが切り替わってもリセットされません。

---

## 13.13 WML ソースコード全体

```xml
<?xml version="1.0" encoding="utf-8"?>
<wml>

  <card id="crosstab" title="販売クロス分析">

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
                      <td width="120" align="center"><i>$(IF(cell='',' ',cell))</i></td>
                      <else/>
                      <td align="center">$(IF(cell='',' ',cell))</td>
                      </if>
                      <else/>
                      <setvar name="N" value="VAL(cell)"/>
                      <td width="60" align="right">$(IF(N=0,' ',FORMAT('%d',N)))</td>
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
                  <th width="60" align="center"> </th>
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
            <th width="60"> </th>
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

`class="xtab-table"`、`class="xtab-total-row"`、`class="xtab-grand-row"` は WapForm for Web のサンプルサイト独自の CSS スタイル（共通の `wapform.htm` レイアウトの外殻で定義）で、`<crosstab>` エンジン自体とは無関係です。自分のスタイルシートに替えてもクロス集計の計算ロジックにはまったく影響しません——レイアウトとロジックは別物であり、これがサンプルサイト全体の設計原則でもあります。

---

## 13.14 設計パターンのまとめ

| 技術 | 実際の状態 | この例での使い方 |
|---|---|---|
| `<crosstab dataset= field=>` | 効果あり | データセットと交差セルの値フィールドを指定 |
| `dialog=` | **現行のエンジンでは使われない** | 書いてもエラーにはならないが効果もない。頼らないこと |
| `autospan=` | **効果あり** | 見出し領域の同じ内容の隣接セルを `colspan`/`rowspan` に自動結合。13.4 節参照 |
| 2 階層の `<row change>` | 効果あり | eno（営業担当者、外側）→ cno（顧客、内側） |
| 2 階層の `<col change>` | 効果あり | yy（年度、外側）→ ym（年月、内側） |
| `cellrow` / `cellcol` / `cell` | **こちらを使う。AROW/ACOL/CELL ではない** | 見出し／データの境界判定、ラベルの取得。13.8 節参照 |
| 複合条件 `(A) or (B)` | 効果あり | `Condiction()` は `or`／`and` キーワードに対応し、`<elseif>` に分ける必要はない |
| `<debug message="...">` | **現在は何も出力しない** | `_log` に対応し、その関数は現在空の関数 |
| SQL 側で先に `group by` 集計 | 推奨 | 交差セルの累計ロジックがより予測しやすく、速くなる |
| `order by` をグループ階層に合わせる | **必須** | 並べ替えないと同じグループがいくつにも分断され、見出しが重複して印刷される |
| `rows=` / `cols=` による自動改ページ | 効果はあるが、Web の場面では既知の HTML 構造の問題がある | 13.6 節参照。改ページ不要なら 2 つの属性は書かないことを推奨 |
| 動的な列合計の配列 `X[]` | 効果あり | 営業担当者グループごとに消去して累計し直す |
| グループをまたぐ総計の配列 `Y[]` | 効果あり | リセットせず、最終的に Grand Total 行として出力 |
| グループ末の小計行 | 効果あり | `<if cnd="cellrow>3">`。コントロールブレイク型レポートの標準的な書き方 |
| ゼロ値の空白化 | 効果あり | `$(IF(N=0,' ',FORMAT('%d',N)))` で空のセルを読みやすくする |

---

## 第 14 章　販売管理システムの構築

*（文房具店の販売／入金 ERP システムを例に、WapForm for Windows のアーキテクチャと重要なコードを解説）*

本章では、本番環境で稼働している実際の Windows デスクトップ ERP を分解します。基本データの入力、出荷伝票のマスター・ディテール構造、動的検索、2 枚複写の連続帳票の印刷、グループ集計の明細書、アカウントと権限の管理を含む、全 12 本の `.wml` ファイルです。

### 14.1 システム概観

| ファイル | 役割 | 形態 |
|---|---|---|
| `app001.wml` | システムパラメーター入力 | 単一レコードのフォーム |
| `app002.wml` | 商品データ入力 | 一覧＋入力＋説明の 3 タブ、動的検索付き |
| `app003.wml` | ブランドデータ入力 | 一覧＋簡易フィルター |
| `app004.wml` | 顧客データ入力 | 一覧＋簡易フィルター＋一括印刷 |
| `app005.wml` | 社員データ入力 | 一覧＋簡易フィルター |
| `app006.wml` | 出荷伝票入力 | **マスター・ディテール構造＋動的検索＋連続帳票印刷**（本章の中心） |
| `app007.wml` | 顧客データ表の印刷 | 一括のグループ化レポート |
| `app012.wml` | 売掛金明細書の印刷 | 多階層のグループ集計＋期首残高の繰越 |
| `app023.wml` | 入金伝票の照会 | 動的検索（読み取り専用の一覧） |
| `app037.wml` | 運送業者データ入力 | 最も簡単な一覧 CRUD |
| `app901.wml` | アカウント管理 | マスター表＋子テーブルの自動展開 |
| `app902.wml` | パスワード（権限）データ入力 | ネストしたマスター・ディテール＋埋め込みの子グリッド |

テーブルの関連は出荷伝票を中心に放射状に広がります：

```
sys（システムパラメーター） ─┐
cu（顧客） ─────────────────┼── sh（出荷伝票ヘッダー）── sn（出荷伝票明細）
em（社員） ─────────────────┤         │
fm（運送業者） ─────────────┤         └── num（日付ごとの連番カウンター）
ve（ブランド） ─────────────┘
pa（商品、マスター・ディテール sn.pno → pa.pno）

users（アカウント） ── login（権限、マスター・ディテール mnu.id → login.id）
```

### 14.2 単一テーブル CRUD の 3 つの書き方

同じ「1 つのテーブルを保守する」でも、このシステムはデータ量と使用場面に応じて 3 つの異なる書き方を採用しており、同じテンプレートを一律に当てはめてはいません：

**(1) 単一レコードのフォーム**（`app001.wml`、システムパラメーター、システム全体で 1 行しかない）——`<dbquery>` を `<datasource>` と直接組み合わせてフィールドを出力します。レコードを切り替える必要がないので、`<dbgrid>` も `<navigator>` もありません：

```xml
<dbquery id="sys">
  <![CDATA[select * from sys]]>
  <field fieldname="Company" displaylabel="会社名"/>
  ...
</dbquery>
<datasource dataset="sys">
  <p><fieldset>
    会社名:<input field="Company" size="30"/><br/>
    ...
  </fieldset></p>
</datasource>
```

**(2) 一覧＋簡易フィルター**（`app003`/`app004`/`app005`/`app037`、マスターのデータ量が中程度）——`<dbgrid>` の一覧に `<dbfilter>` を組み合わせます。フィルター条件の入力欄はフレームワークが自動生成し、`onfilter` イベントがユーザーの入力した条件を `$R` にまとめてクエリに渡します：

```xml
<dbfilter result="R">
  <item field="cno" size="20" />
  <item field="cname" size="20" />
  <onevent type="onfilter">
    <dbquery id="cu"><![CDATA[select * from cu where $R order by cno]]></dbquery>
  </onevent>
</dbfilter>
```

これは WapForm 組み込みの宣言型フィルターで、簡単な条件検索の 8 割をまかなえ、開発者は文字列の連結を一切手書きせずに済みます。

**(3) 動的 WHERE の 3 関数**（`app002`／`app006`／`app023`、フィールドが多く条件の組み合わせが複雑）——フィルター条件が `<dbfilter>` で表現できる範囲を超えると（たとえば「未入金」のチェックボックス、「税込金額が等しい」の完全一致、複数組の開始～終了の範囲など）、`xyz`／`clr`／`set` の 3 つの `<function>` を手書きする必要があります。詳しくは次の節で説明します。

### 14.3 動的検索の三銃士：`xyz` / `clr` / `set`

`app002`、`app006`、`app023` の 3 つのファイルには、同じ手書きのパターンがそれぞれ繰り返し現れます。これはこのシステムで最も代表的な「重量級の検索」の書き方です。`app006.wml` の出荷照会タブを例にします：

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

3 つの関数はそれぞれ役割を担います：

| 関数 | 働き |
|---|---|
| `xyz` | 現在の条件入力欄の値に基づき、`cnd` で 1 つずつ入力済みかを判定し、入力されていれば `SQL_WHERE` に連結し、最後に再検索する |
| `clr` | すべての条件入力欄を消去してから `@xyz` を呼び出して再検索する（「消去して再検索」と同じ） |
| `set` | 検索実行後、現在の条件値を `_` で始まるシャドー変数に別途保存し、画面の再描画時にシャドー変数で入力欄を書き戻す。ユーザーがタブを切り替えたり一覧をダブルクリックしたりしても条件が消えないようにする |

**このコードで最も注目すべき細部は `QUERYGUARD` です**：`xyz` の冒頭でまず `QUERYGUARD` に 1 を足し、1 に等しいときだけ実際に検索を実行し、終わったらゼロに戻します。これは「検索中に発生したイベントが逆に `xyz` を呼び出す」ことで無限再帰や重複検索が起こるのを防ぐ再入防止ロック（re-entrancy guard）です——同じ手法は `app002.wml` の商品検索でも一字一句違わず繰り返し現れており、1 ページだけの偶然ではなくこのシステムの決まった慣例です。

`CUSTNO_TO` が空かどうかで、検索ロジックは「単一の前方一致」から「開始～終了の範囲比較」に切り替わります。これもよくある実務上の柔軟さです。ユーザーが「開始」欄だけを入力した場合は `LIKE '前方%'` として扱い、開始と終了の両方を入力したときに本当の範囲検索に切り替えます。

**📱 Flutter**（`wapform_filter.dart`：`WapFilter`）

`xyz`（検索）と `clr`（消去）は、`WapFilter` の **Search**／**Clear** の 2 つのボタンでそのまま置き換えられます（4.2 節 `<dbfilter>`）。独自の条件が必要な場合は、手書きの関数を残します：

```dart
Future<void> xyz(String cnoFilter) async {          // 検索
  _ev.setVar("cno_f", cnoFilter.trim());
  setvar("S", "'1=1'");
  if (condition("cno_f<>''")) setvar("S", "S+' AND cno LIKE `'+AsSqlStr(cno_f)+'%`'");
  await db.query("sh", r"select * from sh where $S order by sno");
}

Future<void> clr() async {                          // 消去
  setvar("cno_f", "''");                            // varChangeHooks に通知するので、画面も同時に消去できる
  await xyz('');
}
```

### 14.4 出荷伝票のマスター・ディテール構造：連番と明細合計の連動

`app006.wml` の「出荷入力」タブは本章で最も重量級の例です。`sh`（ヘッダー）／`sn`（明細）の 2 階層の `<datasource masterfields="sno">` をネストし、同じ画面でヘッダーと行ごとの明細を同時に保守します。

**日付に基づく連番の生成**（`onnewrecord`）：

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

`num` テーブルは民国暦の年月日（`DOCDATE`）をキーとし、毎日 0 から連番を数え直します。ヘッダーを追加するときは、まずその日のカウンター行があることを確かめ（なければ `insert`）、次に `UPDATE ... SET sno=sno+1` で番号を取り、最後に「日付＋4 桁の連番」で伝票番号を組み立てます。たとえば `1150817` の日の 3 枚目の伝票は `1150817` + `0003` になります。**先に `UPDATE` で加算し、次に `SELECT` で値を取るのは、単一マシン／小規模なマルチユーザー環境でよくある採番パターン**です——複数人が同時に追加すると衝突の危険はまだあり、本格的な高並行の本番環境では通常データベース層のロックやシーケンス（sequence）の仕組みで補強する必要がありますが、店舗規模の出荷頻度であれば、この簡略化した書き方で 20 年以上安定して動いてきました。

**明細の変更で合計金額をその場で書き戻す**：

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

`sn`（明細）データセットの `afterpost` と `afterdelete` イベントはどちらも `@UpdateTotal` を呼び出します。明細を 1 件追加／変更／削除するたびに、明細データセット全体を走査し直して `Total` 列を合計し、ヘッダーの `shAmount` に書き戻します。ここでは `GetBookmark`／`DisableControls`／`GoToBookmark` の三点セットの標準的な使い方を示しています——バックグラウンドでデータセットを走査し直すときは、**まず現在のカーソル位置を記憶して画面の再描画を止め、ループが終わったらカーソルを元に戻して再描画を再開する**ことで、ユーザーの目の前でカーソルが飛び回るのを防ぎ、1 件ずつの更新による画面のちらつきも防ぎます。

`beforeedit`／`beforeinsert`／`beforedelete` の 3 つの明細イベントはどれも `<invoke instance="sh" method="Edit"/>` を呼び出します。これは**明細を変更する前にヘッダーのデータセットを強制的に編集状態に切り替える**連鎖ロックで、ヘッダーと明細が同じトランザクションの文脈で変更されることを保証し、「明細は保存済みなのにヘッダーの合計フィールドが古い値のまま」という不整合な状態を防ぎます。

### 14.5 動的な連動：バーコードスキャンと顧客別販売履歴価格の自動入力

明細行の「品番」フィールド（`sn.pno`）は、2 段階の連鎖した `onchange` ロジックを示しています：

```xml
<field fieldname="PNo" displaylabel="品番">
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

第 1 段階：ユーザーはバーコードスキャナーで品番欄にバーコードを直接入力できます。システムはまず `pa.barcode` に一致するかを検索し、一致すればフィールドの値を**本当の品番に書き換えます**——しかしフィールドの値を書き換えること自体が同じ `onchange` イベントを再びトリガーするため、保護しなければ無限再帰になります。`BARCODEGUARD` を書き換えの前に 1 にし、書き換えた直後にゼロに戻すことで、再帰で入ってきた回は `BARCODEGUARD=0` の判定に失敗してバーコード照合のロジックを飛ばします。これは 14.3 節の `QUERYGUARD` と同じ「イベント再入防止ロック」の手法を、別の場面に使ったものです。

第 2 段階：品番が確定すると、システムは「この顧客が過去にこの商品を買った直近の成約価格」を検索し直し（`vp` クエリ、`ORDER BY sdate DESC` で最新の 1 件だけを取る）、履歴価格があればそれを入れ、なければ商品マスターの希望販売価格 `price1` にフォールバックします。これはかなり実用的な業務ロジックです。お得意様の価格は自動的に引き継がれ、新規顧客には定価が適用されるので、営業担当者が毎回手で価格を調べる必要はありません。

### 14.6 ポップアップ式のデータ選択：4 種類の lookup ダイアログカード

入力欄に組み込まれた `lookup="テーブル;キー;表示列"` の文法に加えて、このシステムは**独立したサブカードをポップアップの選択ウィンドウ**として多用しており、`accept`／`prev` で「確定して持ち帰る」か「キャンセル」かを決めます：

| カード | 用途 | 戻し方 |
|---|---|---|
| `#PC`（`app006.wml`） | 顧客一覧の選択ウィンドウ。`cu1`（`cno<'D'` で絞り込んだ顧客の部分集合）から展開 | `<prev><setvar name="shcno" value="cu1.cno"/></prev>` |
| `#PRICE`（`app006.wml`） | 同じ顧客・同じ商品の販売価格の履歴一覧を表示し、人が比較して手で価格を入力するために使う | 読み取り専用の表示。`<prev/>` で直接閉じる |
| `#mysub` / `#mygrp`（`app002.wml`） | 商品の分類／細分類の 2 段階選択。`invoke ... method="locate"` で現在の値に位置づけてから一覧を表示 | `<prev><setvar name="SUBCAT_ID" value="su.id"/></prev>` |

`#mygrp` を例にします：

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
  <do type="accept" label="キャンセル"><prev/></do>
</card>
```

`invoke ... method="locate"` は、ポップアップウィンドウが開いた瞬間にカーソルを「現在のフィールド値に対応する行」へ位置づけるので、ユーザーは今どれが選ばれているかがひと目でわかり、毎回一覧の先頭から探す必要がありません——使い勝手を高める小さな工夫ですが、頻繁に操作するデータ入力画面では大きな違いになります。

### 14.7 2 枚複写の連続帳票：出荷伝票／入荷伝票の印刷

`app006.wml` の `P1`（出荷伝票）と `P2`（入荷伝票）の 2 つの印刷カードは、従来のドットマトリクス式連続帳票で最も典型的な「行数固定の改ページ」の書き方を示しています。`P1` を例にすると、5 つの `<function>` で分担します：

| 関数 | 役割 |
|---|---|
| `header` | 各ページのヘッダー：会社名、顧客情報、表の列名 |
| `normal` | 通常の明細行 |
| `space` | 固定の行数に満たない分を埋める空白行（連続帳票の位置合わせを保つ） |
| `footer` | 改ページ時のフッター（まだ印刷し終えていないので、表を閉じて改ページ） |
| `summary` | 最終ページのフッター（金額合計、税額、総計を含む） |

メインフローで改ページを手動制御します：

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

「1 ページ 9 行」の固定は、連続帳票用紙の実際の印刷グリッドに対応しています。10 行目を印刷する前に締めくくり（`@footer`）、`<newpage/>` で改ページし、ヘッダーを再印刷し（`@header`）、ページ番号 `PAGENO` を増やします。最後の明細を印刷し終えて行数が 9 行に満たなければ、`@space` で空白行を埋め、表の下線が常に用紙の同じ位置に揃うようにしてから `@summary`（金額合計を含む）を出力して締めくくります。**このように行数を手動で制御する書き方は、特定の連続帳票用紙の規格に合わせるための正当なやり方**で、現代の A4 の自由なレイアウトのレポート（本章 14.8 節の売掛金明細書で `<group>` と組み合わせる動的な改ページなど）と目的は同じで手段が違うだけです——行間が固定の用紙は正確な位置合わせが必要で、動的なレイアウトはフレームワークの自動改ページに頼ります。

注目すべきは、`P1`／`P2` に入る際、どちらもまずデータが保存済みであることを確かめている点です：

```xml
<if cnd="sn.state&lt;&gt;'BROWSE'"><invoke instance="sn" method="post"/></if>
<if cnd="sh.state&lt;&gt;'BROWSE'"><invoke instance="sh" method="post"/></if>
```

明細がまだ保存されていない状態でユーザーが「出荷伝票」を印刷し、印刷内容とデータベースが食い違うことを防ぎます。

**📱 Flutter**（`wapform_report.dart`：`WapReport`、`WapPage(paper: "8.5x5.5")`）

半分の高さの連続帳票用紙（8.5 × 5.5 インチ）はカスタムの用紙サイズを使います。1 枚あたりの固定行数は `wap.wapLpp` で制御し、いっぱいになると自動で改ページして `PAGEPREFIX` のヘッダーを再印刷します：

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
        emit(expandText(r'<p>出荷伝票 $(sn.sno)　顧客：$(sn.cname)</p><table class="wap">'));
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
            r"<tr><td colspan='3' align='right'>合計 $(FORMAT('%.0n',SLIP_SUM))</td></tr>"),
            isFooter: true);
        forcePageBreak();                           // 伝票ごとに新しいページから始める
        break;
      case 'PAGESUFFIX':
        emit('</table>');
        break;
    }
  }
}

Widget slipPage() => WapPage(title: "出荷伝票", report: ShipmentSlip(), paper: "8.5x5.5");
```

### 14.8 グループ集計レポート：売掛金明細書と期首残高の繰越

`app012.wml`（売掛金明細書）は本章で最もロジックの深いレポートです。3 階層にネストした `<group>`（顧客 → 日付 → 伝票番号）に「期首残高の繰越」を重ねたもので、典型的な財務の明細書の書き方です。

```xml
<report dataset="sh" dialog="cno;sno">
  <group change="sh.cno">
    <setvar name="AMOUNT_SUM" value="0"/>
    <setvar name="TAX_SUM" value="0"/>
    <setvar name="PAID_SUM" value="0"/>
    <page>
      ... ヘッダー：顧客情報 ...
      <group change="datetostr(sh.sdate)">
        <group change="datetostr(sh.sdate)+sh.sno">
          <group>
            <tr>... 1 件ごとの明細行 ...</tr>
          </group>
          <setvar name="AMOUNT_SUM" value="AMOUNT_SUM+sh.amount"/>
          <setvar name="TAX_SUM" value="TAX_SUM+sh.tax"/>
          <setvar name="PAID_SUM" value="PAID_SUM+sh.paid"/>
        </group>
      </group>
    </page>
    <!-- 顧客グループごとの終了後、「当期より前」の過去の残高を別に検索 -->
    <dbquery id="R"><![CDATA[
      select cno, SUM(Amount) as A, SUM(Tax) as B, SUM(Paid) as C
      from sh where sh.sdate < '$(SHIPDATE_FROM)' and cno='$sh.cno' group by cno
    ]]></dbquery>
    <setvar name="BAL_BEGIN" value="R.A+R.B-R.C"/>
    <setvar name="BAL_END" value="BAL_BEGIN+AMOUNT_SUM+TAX_SUM-PAID_SUM"/>
    ... フッター：前期未収 + 当期売上 + 当期税額 - 当期入金 = 当期売掛金 ...
  </group>
</report>
```

外側の `<group change="sh.cno">` は顧客が変わるたびに 3 つの累計変数をリセットして新しいページを始め（顧客ブロック全体を `<page>` で包む）、中間の階層は日付で、内側の階層は伝票番号でグループ化します。これは第 13 章のクロス集計で使った「多階層の `group change` による累計」の手法をレポート出力にそのまま応用したものです。**本当の鍵は、顧客グループの終了後にある独立した `<dbquery id="R">` です**。これは「検索期間の開始日より前」のその顧客の過去の合計を別に検索して `BAL_BEGIN`（期首残高）を求め、当期に合計した `AMOUNT_SUM`／`TAX_SUM`／`PAID_SUM` と合わせて `BAL_END`（期末の売掛金）を計算します。これはまさに明細書の「前期未収＋当期売上＋当期税額－当期入金＝当期売掛金」という標準的な会計の式で、すべての過去データをメインクエリに取り込んでから絞り込むのではなく、メインクエリとは独立した補助クエリの組で実現しています——データ量の多い本番環境では、この「グループ内でのオンデマンド検索」により 1 回のクエリのデータ量を大幅に減らせます。

`app007.wml`（顧客データ表）は `app012.wml` と同じ一括印刷の骨格を共有しますが、グループは 1 階層だけです。違いは、`app007` が「縦／横」と「画面プレビュー／直接印刷」の 2 組のドロップダウンを追加で提供し、`device="$(IF(SP='S','PRV','PRN'))"` で出力デバイスを動的に決めている点です——**同じレポートカードが、1 つの式だけで「印刷プレビュー」と「プリンターへ直接印刷」を切り替えられる**ので、2 種類の出力のためにそれぞれカードを書く必要はありません。

**📱 Flutter**（`wapform_report.dart`：`onGroupPrepare()`）

`parseBlock()` は同期的なので、その中でクエリを待つことはできません。各顧客の期首残高は `onGroupPrepare()`（グループが切り替わる前で、`await` が使える）で先に検索しておきます：

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
        setvar("BAL", "VAL(ob.bal)");                 // 期首残高を繰り越す
        emitRow(expandText(r"<tr><th colspan='3'>$(sh.cname)　期首 $(FORMAT('%.0n',BAL))</th></tr>"),
            isHeader: true);
        break;
      case 'RECORD':
        setvar("BAL", "BAL+sh.amount-sh.paid");
        emitRow(expandText(r"<tr><td>$(sh.sdate)</td><td>$(sh.sno)</td>"
            r"<td align='right'>$(FORMAT('%.0n',BAL))</td></tr>"));
        break;
      case 'G1_SUFFIX':
        emitRow(expandText(r"<tr><td colspan='3' align='right'>期末 $(FORMAT('%.0n',BAL))</td></tr>"),
            isFooter: true);
        break;
    }
  }
}
```

使い方：`WapPage(title: "売掛金明細書", report: ArStatement(db))`。

### 14.9 メール連携：ワンクリックで顧客に出荷を通知

出荷伝票入力ページの「メール送信」ボタンは、OS の既定のメールソフトを直接呼び出します：

```xml
<do type="accept" label="メール送信">
  <setvar name="SQL_WHERE" value="
'ご注文 ['+sh.sno+'] の商品を発送しました。配送には 1~3 営業日ほどかかる見込みです。%0A'+
...
'%0A'"/>
  <shellexecute operation="open" file="mailto:$(sh.email)?subject=文房具店 出荷のお知らせ&amp;body=$(trim(SQL_WHERE))"/>
</do>
```

`shellexecute` は OS レベルの `mailto:` プロトコルを呼び出し、宛先（顧客の email）、件名、本文を付けて、ユーザーのローカルにインストールされたメールソフトを内容を入力済みの状態で開き、営業担当者が送信ボタンを押す形にします——**WapForm が自分で SMTP 接続を処理する必要はありません**（第 15 章の Web 環境で `<mail>` タグを使って直接メールを送るのと比べると、サーバー側とクライアント側というまったく異なる、しかしどちらも実用的な連携方法です）。本文は文字列変数で手作業で組み立て、`%0A` は mailto の URL での改行のエンコードです。

### 14.10 アカウントと権限の管理：ネストしたマスター・ディテール＋子テーブルの自動展開

`app901.wml`（アカウント管理）と `app902.wml`（権限管理）は互いに補い合う管理機能の組です。

**アカウント追加時に全メニューの権限レコードを自動展開する**（`app901.wml`）：

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

新しいアカウントを作るとき、まずそのアカウントに権限レコードがまだないことを確かめ、それから**全メニューのテーブル `mnu` を 1 件ずつ走査し、`<report>...<group>` のループでメニュー項目ごとに権限レコードを 1 件ずつ `INSERT` します**（既定は読み取り可・書き込み不可）。これは「マスターを追加するときに、対応する明細を一括で自動展開する」一括作成のパターンで、第 6 章 6.6 節の「バックグラウンドでの発注書の一括展開」と同じ設計思想です。ここでは注文の展開ではなく権限の初期化に使っています。

**ネストしたマスター・ディテールに子グリッドを直接埋め込む**（`app902.wml`）：

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
      <item field="itm" title="No" size="10"/>
      <item field="uid" size="30" lookup="users;userid"/>
      <item field="w" title="有効" type="checkbox" range="1;0" size="10"/>
    </dbgrid>
  </datasource>
</datasource>
```

外側の `<dbgrid>` はメニューの一覧で、内側の `<datasource mastersource="mnu" masterfields="id">` は外側の `<datasource>` の中に直接ネストされており、2 つの `<dbgrid>` が同時に画面に表示されます——左のメニューをクリックすると、右の子グリッドにはそのメニュー項目のユーザー権限の一覧だけが自動的に表示されます。`onselect` イベントを別に書いて手動で再検索する必要はなく、マスター・ディテールの関連は完全に `masterfields` の宣言で駆動されます。第 3 章 3.2 節「パターン：マスター・ディテール構造」の 1 階層の書き方と比べると、違いはここでは子テーブルを `<dbgrid>` で直接表示し、その場で `w`（有効）列をチェックできる点だけです。これにより管理者は、1 つの機能に対する複数ユーザーの読み書き権限を同じ画面ですばやく調整できます。

### 14.11 本章のまとめ

| 手法 | 対応する節 | 実際の用途 |
|---|---|---|
| 単一テーブル CRUD の 3 つの書き方をデータの性質で使い分ける | 14.2 | 単一レコードのフォーム／一覧と簡易フィルター／重量級の動的検索を共存させ、テンプレートの統一を無理強いしない |
| `QUERYGUARD` 再入防止ロック | 14.3 | 動的検索の関数がイベントの連鎖で重複してトリガーされるのを防ぐ |
| 日付ごとの連番テーブル `num` による採番 | 14.4 | `UPDATE...SET sno=sno+1` の後に `SELECT`。簡易版の連番生成 |
| `GetBookmark`/`DisableControls` の三点セット | 14.4 | バックグラウンドでデータセットを走査し直すときの画面のちらつきとカーソルの飛び回りを防ぐ |
| `BARCODEGUARD` 再帰防止 | 14.5 | `onchange` でフィールド値を書き換えるときのイベントの無限再帰を防ぐ |
| 顧客の過去の成約価格の自動入力 | 14.5 | `ORDER BY sdate DESC` で最新の 1 件を取り、履歴価格がなければ定価にフォールバック |
| ポップアップ式 lookup カード＋`locate` による位置づけ | 14.6 | 選択ウィンドウが開いたとき、カーソルが現在の値に自動で止まる |
| 固定行数での手動改ページ | 14.7 | 連続帳票用紙の規格に合わせた、ヘッダーとフッターを含む 5 段構成の印刷関数 |
| グループ内でのオンデマンドな期首残高の検索 | 14.8 | 明細書の「期首＋当期－入金＝売掛金」という標準的な会計の式の実装 |
| `shellexecute mailto:` | 14.9 | SMTP を書かずに、ローカルのメールソフトを直接呼び出す |
| マスター追加時の明細の一括展開 | 14.10 | 新しいアカウントに全メニューの既定の権限レコードを自動生成 |
| ネストした `datasource` への子グリッドの直接埋め込み | 14.10 | マスター・ディテールの関連は完全に宣言型で、`onselect` を書く必要がない |

この 12 本のファイルは、典型的な製造業／小売業の販売システムの骨格を描き出しています。基本データの入力から、業務伝票のマスター・ディテール構造と連番の生成、印刷出力と権限の管理まで、どのコードも実際の業務の問題を解決するために書かれたもので、だからこそバーコードスキャン、価格履歴の比較、mailto による通知といった「教科書の例には出てこないが、本番のシステムには欠かせない」細部が残っています。

---

---

## 第 15 章　動的な Web 取引プラットフォームの構築（WapForm for Web）

本章では架空の例は使わず、**本番環境で稼働している実際のサイト**を直接分解します。WapForm 公式サイトそのものの「ショップ＋操作マニュアル」サイトです。このサイトは 2 つの役割を兼ねています——外向けには分類での閲覧、検索、ショッピングカートを備えたオンラインショップであり、内向けには本書の読者が今読んでいる操作マニュアルのシステムでもあります——WapForm で WapForm 自身を作る（dogfooding）実践例で、全 11 本の `.wml` ファイルが協調して動きます。

### 15.1 システム概観

典型的な EC の教材と違い、このサイトには**独立した「商品テーブル」も「マニュアル目次テーブル」もありません**。分類、商品、操作マニュアルのトピック、ご利用案内は、すべて同じ `pa` テーブルに混在して格納され、`mnu`、`typ`、`gid` の 3 つのフィールドで互いの役割を区別しています：

| フィールド | 役割 |
|---|---|
| `mnu='m'` | このデータがサイト全体のメニューツリーにも現れることを示す |
| `typ` | このメニュー項目をクリックしたときにどの種類のページへ移動するかを決める：`b`=マニュアル（book）、`n`=案内（note）、`p`=静的ページ（page）、`s`=ショップ（shop）、それ以外=分類のグリッドナビゲーション（grid） |
| `gid` | 親分類のコード。メニューの親子階層を組み立てるのに使う |

この設計の利点は、商品の分類を 1 件追加すれば、それがそのままメニューのノードを 1 つ追加したことになり、メニューテーブルを別に保守する必要がない点です。代償として、検索ロジックでは `mnu`/`typ`/`gid` で細心の注意を払って絞り込まなければならず、そうしないとマニュアルのトピックがショップの一覧に紛れ込みます。

サイトは 5 種類のページ形態＋3 つの共通部品で構成されています：

```
┌───────────────────────────────────────────────────────────┐
│  header.wml / footer.wml / asider.wml   ← サイト全体の共通部品  │
│  ├── index.wml (= shop.wml)   ショップのトップ／一覧／検索／ページ送り │
│  ├── grid.wml                 分類のグリッドナビゲーション     │
│  ├── book.wml + book-js.wml   操作マニュアル（AJAX 部分読み込み） │
│  ├── note.wml + note-js.wml   ご利用案内（AJAX 部分読み込み）   │
│  └── page.wml                 純粋な静的コンテンツページ       │
└───────────────────────────────────────────────────────────┘
```

ファイルの依存関係の一覧：

| ファイル | 役割 | include する部品 | 主なテーブル |
|---|---|---|---|
| `header.wml` | サイト全体のメニュー構築＋ショッピングカートの集計 | なし（すべてのページから include される） | `pa`（`mnu='m'`）、`rn`、`cu` |
| `footer.wml` | フッターの売れ筋ショートカット | なし（すべてのページから include される） | `pa`（`mnu='m'`、`qty>8600`） |
| `asider.wml` | サイドのフローティングメニュー（header が作った配列を再利用） | 自身の `dbquery` はなし | なし |
| `index.wml`（= shop.wml） | ショップのトップ／一覧／検索 | header、footer、asider | `sys`、`counter`、`pa`、`web`、`sn` |
| `grid.wml` | 分類のグリッドナビゲーション | header、footer、asider | `sys`、`pa` |
| `book.wml` | 操作マニュアルのメニューページ | header、footer、asider。AJAX → `book-js.wml` | `sys`、`pa` |
| `book-js.wml` | マニュアル本文（AJAX 部分読み込み） | `book.wml` から呼ばれる（`loadDoc`） | `pa`（1 件の `topic`） |
| `note.wml` | ご利用案内のメニューページ | header、footer、asider。AJAX → `note-js.wml` | `sys`、`pa` |
| `note-js.wml` | 案内本文（AJAX 部分読み込み） | `note.wml` から呼ばれる（`loadDoc`） | `pa`（1 件の `topic`） |
| `page.wml` | 静的コンテンツページ | header、footer（**asider は含まない**） | `sys`、`pa` |

`page.wml` は `asider` を include しない唯一のページです——純粋なコンテンツページで、サイドのフローティングメニューにレイアウトを奪われる必要がないからです。これは意図的な設計上の取捨選択で、漏れではありません。

### 15.2 1 回のクエリでサイト全体が共有するメニューツリー

5 つのページはどれも同じ分類メニューを表示する必要があり、それぞれが検索すると、同じデータを 5 回検索することになります。`header.wml` のやり方は、**`header` というサブカードの中で 1 回だけ検索し、結果を配列に平坦化して保存する**ことです。他の部品（`asider.wml`、`index.wml` のサイドバー）は配列を直接読み、データベースにはまったく触れません。

```xml
<card id="menu" device="sub">
  <setvar name="mnu_id" value="[0..1023]" />
  <setvar name="mnu_typ" value="[0..1023]" />
  <setvar name="mnu_title" value="[0..1023]" />
  <setvar name="mnu_icon" value="[0..1023]" />
  <setvar name="mnu_count" value="[0..1023]" />

  <!-- 第 1 階層：最上位の分類（gid='0000'） -->
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

    <!-- 第 2 階層：第 1 階層の pno を gid として子項目を検索 -->
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
    <setvar name="mnu_count[p]" value="i" />   <!-- この親ノードの子項目の数を記録 -->
    <invoke instance="mnu" method="next" />
  </while>
  <setvar name="mnu_count[k]" value="999999" /> <!-- 番兵の値：配列の終端マーク -->
```

これは「親子 2 階層の `mnu_count[]` インデックス配列」による手作業の平坦化です。`mnu_id[]`/`mnu_typ[]`/`mnu_title[]` は親ノードと子ノードを**順番に**同じ 1 次元配列に続けて入れ、`mnu_count[p]` は親ノードのインデックス位置にだけ「この親ノードの直後に子項目がいくつ続くか」を記録します。以後どの部品も、この配列さえ手に入れれば `while cnd="not(mnu_count[k]=999999)"` の 1 つのループでツリー全体を再構築でき、データベースを再検索する必要も、再帰を使う必要もありません——これは「1 回の検索と配列の共有」と引き換えに「後続の部品の検索ゼロ」を得る、意図的な性能上の戦略です（詳しくは第 5 章のルックアップ表としての配列を参照）。

### 15.3 コンポーネントの再利用：asider.wml はデータベースに一切アクセスしない

`asider.wml` は、共通部品どうしが検索を繰り返すのではなく、配列でデータを受け渡す方法を示しています：

```xml
<card id="asider" device="sub">
  <setvar name="i" value="0"/>
  <setvar name="k" value="0"/>
  <block name="asider.aa"/>
  <while cnd="not(mnu_count[k]=999999)">
    <!-- header.wml が作った mnu_id[]/mnu_typ[]/mnu_count[] を直接読む。自身の dbquery はない -->
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

前提として、`<include name="header"/>` は `<include name="asider"/>` より前に置き、`mnu_id[]` などの配列が先に作られている必要があります——これは「include の順序がデータの依存順序である」ことの実例であり、本節の依存関係一覧で `asider.wml` の行が「自身の `dbquery` はなし」となっている理由でもあります。

### 15.4 コンテンツの種類に応じてリンク先を動的に決める

メニュー項目をクリックしたときにどのページへ移動するかは固定ではなく、`pa.typ` によって動的に判定されます。`header.wml`、`asider.wml`、`grid.wml`、`index.wml` の 4 つのファイルには、それぞれほぼ同じ `switch` が書かれています：

```xml
<switch exp="mnu_typ[k]">
  <case value="b"><setvar name="app" value="'book'" /></case>
  <case value="n"><setvar name="app" value="'note'" /></case>
  <case value="p"><setvar name="app" value="'page'" /></case>
  <case value="s"><setvar name="app" value="'shop'" /></case>
  <default>       <setvar name="app" value="'grid'" /></default>
</switch>
```

`app` が求まれば、テンプレートのリンクは `href="$(app).wml?gp=$(mnu_id[k])"` と書けます。この `switch` は 4 つのファイルで 6 回以上繰り返されています——これは実際の本番コードでよくあるトレードオフです。外部へのリンク規則は単純で安定しているので、共通の `block` に切り出すより重複して埋め込むほうが直感的で修正のリスクも低い一方、将来 6 種類目のコンテンツ（たとえば動画ページ `typ='v'`）を追加する場合は、6 か所を同時に直すことを忘れてはなりません。**これは本章が意図的に残した実際の欠点であり、教材としての手本ではありません**。自分のプロジェクトで同じ `switch` が 3 回以上現れたら、それは通常、共通の `block` に切り出すべき合図です。

### 15.5 AJAX による部分読み込み：マニュアルと案内の 2 ファイル構成

`book.wml`／`note.wml` はメニューの枠を描くだけで、実際の本文は `book-js.wml`／`note-js.wml` が AJAX で部分的に読み込みます。両者の構造は完全に対称です。マニュアルを例にします：

```xml
<!-- book.wml：content サブカードはコンテナ 1 つ + JS の呼び出しだけを出力 -->
<card id="content" device="sub">
  <![CDATA[
    <div id="xyz"></div>
    <script>loadDoc('book-js.wml?pg=$id');</script>
  ]]>
</card>
```

```xml
<!-- book-js.wml：独立した 1 本の wml、device="wapform-js.html" -->
<card id="P" title="文房具店" device="wapform-js.html">
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

`loadDoc()` は共通の `wapform.html` テンプレートで定義されている、標準的な `XMLHttpRequest` です：

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

`book.wml` のサイドバーの各メニュー項目は `<a href="javascript:loadDoc('book-js.wml?pg=$itm.pno')">` で、クリックすると `book-js.wml`（1 つの `topic` フィールド）だけを再リクエストし、**ページ全体を再読み込みすることも、メニュー構築のロジックを再実行することもありません**。これが「メニューの枠のページ」と「コンテンツページ」を 2 本の `.wml` に分ける核心的な価値です。コンテンツページは独立してキャッシュでき、独立してテストでき、将来は別の言語の実装に替えても外側の枠に影響しません。`device="wapform-js.html"` はこの種の部分的な断片のために用意された簡素なテンプレートで、`<head>`／メニュー／フッターを含まず、内容そのものだけを出力します。

### 15.6 ショップのトップページ：3 つの操作モードと安全な動的クエリの組み立て

`index.wml` は `op` パラメーターを使い、同じ 1 本のファイルの中で意味のまったく異なる 3 つのモードを切り替えます：

| `op` の値 | 意味 | 対応する `content` card のクエリ |
|---|---|---|
| `s` | 検索 | キーワードに応じて `WHERE` を動的に組み立てる |
| `g` | 今期の特売商品 | `web` テーブルと `pa` を JOIN |
| `i` | 分類の一覧 | `pa.gid = 指定した分類` |

中でも `op='s'` の検索は最も分解する価値があります。**文字列関数で複数のキーワードを手作業で解析し、決まった引用符のエスケープ方法で安全な SQL 条件を組み立てる**例だからです：

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

`gp='猫 缶詰'` のように空白や `+` で区切った複数キーワードの入力は、1 文字ずつ走査して断片に分けられ、各断片が `pno LIKE '%...%' OR des LIKE '%...%'` の組に組み立てられ、最後に連結されて完全な `WHERE` 句の断片 `s` になり、下の `dbquery` に渡されます。**SQL の文字列では連続する 2 つの単一引用符 `''` がエスケープ後の 1 つの単一引用符であることに注意してください**——これは手作業で文字列を連結してクエリを組み立てるときに最も間違えやすく、インジェクションのリスクに最も注意すべきところです。本番環境では、フィールドのホワイトリストやパラメーター化クエリと組み合わせてリスクをさらに抑えることを推奨します。

`az` パラメーターは並べ替えの方針を決めます。`az`／`za` は `pno` の昇順／降順、`aa` は販売実績（`LEFT JOIN sn` で `qty` を合計した後 `ORDER BY amount DESC`）で売れ筋から順に並べ、`zz` は管理者（`session.usr='admin'`）専用のデータ確認モードで、`active>1` の異常な商品を確認するのに使います。この「同じクエリの入口で、1 つのモードパラメーターによってまったく異なる並べ替え／絞り込みのロジックを切り替える」書き方の利点は、ページ送り、検索ボックス、並べ替えボタンがすべて同じ `content` card を共有でき、並べ替えごとにページを書く必要がない点です。

### 15.7 ページ送りバーの生成：`navigator` サブカード

ページ送りボタン自体も独立したサブカードで、`PG`（現在のページ番号）と `PAGES`（総ページ数、`CEIL(総件数/20)`）だけに依存し、「現在のページの前後 5 ページずつ」を表示するウィンドウを動的に計算します：

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

`navigator` は `content` card と同じクエリ条件の組み立てロジックを丸ごともう一度実行します（ただしフィールドは取得せず `count` だけを取る）。これは「クエリ条件のロジックを 2 つのカードでそれぞれ保守しなければならない」という現実のコストです——データの件数と内容の一覧は 2 つの独立したクエリに分かれているので、検索条件の書き方を変えたら両方を同時に直す必要があります。15.4 節で述べた「重複したロジック」の判断基準がここにも当てはまるのはこのためです。

### 15.8 ショッピングカートの集計：`header.wml` に組み込まれた決済試算

興味深いことに、ショッピングカートの小計は独立したページではなく、**すべてのページで include される `header.wml`** に組み込まれており、どのページのヘッダーのカートアイコンでも品目数と金額をその場で表示できます：

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

ショッピングカートに中身があるかどうかは、完全に `session.ord`（注文の連番が作られているか）で決まります。1000 元未満なら送料 90 元を加算し、税は一律 5% とする——この 2 つの業務ルールは `header.wml` に直接書かれているため、どのページでも「カートに入れた後、合計金額が送料無料の基準を超えたか」を反映できます——これは第 3 章 3.8 節の「Web 会員ログインと Session 管理」パターンを実際のサイトに落とし込んだ版です。

### 15.9 Session の有効期間：3 層の寿命と変数ごとの期限

ショッピングサイトには、ページをまたいで保持しなければならない状態が 2 つあります。ログインした身元（`session.usr`）と、ショッピングカートの連番（`session.ord`）です。両者がどれだけ生きるべきかの答えは同じではありません——身元はセキュリティに関わるので長く置きすぎると危険で、カートの連番は長く置きすぎると決済されていない一時データを占有し続けます。この節では、どこまで制御できるかを説明します。

**まず、状態の寿命が層になっていることを理解する**

| 層 | 制御方法 | 現在の動作 |
|---|---|---|
| session 変数 | `<session expire="分"/>` | 指定しない＝自分では期限切れにならない |
| ブラウザーの cookie | サーバー設定 | 発行から 1 日 |
| サーバーの session | サーバー設定 | 最後のリクエストから 7 日間アイドルで回収 |
| サーバープロセス | なし | 再起動するとすべて消える |

**最も早く期限が来る層が決め手です**。現状では cookie の 1 日が最も短いので、実際には「ログイン後、最長 1 日まで記憶される」ことになります——`expire` を 7 日と書いても効果はなく、ユーザーが 2 日目に戻ってきたときにはブラウザーにもう session ID がなく、サーバーは対応する session を見つけられません。

設計の際はこの点を最も短い層から逆算し、自分が書いた数字が最終的な動作になると思い込まないでください。

**変数ごとの期限**

同じ session 内の変数は、それぞれ独自の寿命を持てます：

```xml
<!-- ログインした身元は 8 時間 -->
<session name="usr" value="A" expire="480"/>

<!-- ショッピングカートの連番は 2 時間だけ残し、期限が来たら自動で解放 -->
<session name="ord" value="S" expire="120"/>
```

エンジンは各リクエストでカードを解析する前に期限切れの変数を消去するので、読み取り側でタイムアウトを自分で判定する必要はありません：

```xml
<!-- session.usr が期限切れになると、このガードが自然にユーザーをログインページへ導く -->
<if cnd="NOT(DEFINE(session.usr))">
  <redirect href="login.wml"/>
  <exit/>
</if>
```

延長が必要なら同じ変数に書き込み直せばよく、期限はその時点から計算し直されます：

```xml
<session name="usr" value="session.usr" expire="480"/>
```

**`expire` を指定しない場合**

`expire` を省略しても「保存しない」という意味ではなく、「自分の期限を設定しない」という意味です——変数は session 全体が消えるまでずっと存在します。既存の WML はまったく書き換える必要がありません。

**重要な状態を session だけに置かない**

上の表の最後の行には注意が必要です。session のデータはサーバーのメモリにあり、プロセスが再起動するとすべて消えます。これは WML では制御できません。したがって、決済前のショッピングカートの内容はデータベースに書き込むべきで（本サイトでは `rn` テーブルに書き込み、`session.ord` は連番だけを保持する）、session にはデータそのものではなく「データを指すキー」だけを置きます。こうすれば session が消えても、ユーザーが再ログインした後に注文は残っています。

**ついでに：session にパスワードを保存しない**

本サイトの `login.wml` は、認証に成功した後に 2 つの変数を書き込んでいます：

```xml
<session name="usr" value="A"/>
<session name="pwd" value="B"/>
```

このうち `pwd` にはパスワードの原文が入っていますが、サイト全体のどのページも `session.pwd` を読んでおらず、認証には `MD5(B)` の比較を使っています。このように書くだけで読まれない機密の値は、直接取り除くべきです——何の役にも立たず、パスワードのコピーをメモリにもう 1 つ残すだけだからです。

### 15.10 本章のまとめ

| 手法 | 対応する節 | 実際の用途 |
|---|---|---|
| 1 回の検索で配列を作り、複数の部品で共有 | 15.2 / 15.3 | メニューツリーはデータベースを 1 回だけ検索し、`asider.wml` は検索ゼロ |
| `typ` フィールドによるルーティング | 15.4 | 1 つのテーブルが分類、商品、マニュアル、案内を兼ね、種類のフィールドで振り分ける |
| 枠のページ／コンテンツページの 2 ファイルによる AJAX | 15.5 | マニュアルや案内の本文を独立して更新でき、ページ全体の再描画を起こさない |
| 文字列の手作業での解析による動的 WHERE の組み立て | 15.6 | 複数キーワード検索。単一引用符のエスケープとインジェクションのリスクに注意が必要 |
| 独立したページ送りのサブカード | 15.7 | ページ送りのロジックとコンテンツのクエリを分離。ただしクエリ条件は 2 か所で同期が必要 |
| Session に基づくヘッダーのショッピングカート集計 | 15.8 | サイト全体の共通部品に業務ルール（送料の基準、税率）を組み込む |
| Session の 3 層の寿命と変数ごとの期限 | 15.9 | ログインした身元とショッピングカートの連番にそれぞれ有効期間を設定 |

これらの手法はどれも「教科書どおりの書き方」ではなく、すべて実際にサービスを提供している同じファイル群から来たもので、その重複、取捨選択、既知の保守コストも含んでいます。本章で節ごとに分解した元のファイルは `header.wml`、`footer.wml`、`asider.wml`、`index.wml`、`grid.wml`、`book.wml`、`book-js.wml`、`note.wml`、`note-js.wml`、`page.wml`、`wapform.html` の計 11 本で、読者は全体の文脈と照らし合わせることができます。

---

---

## 第 16 章　同じ定義を Flutter へ展開する（WapForm for Flutter）

*（第 14 章の文房具店の販売管理システムの `app001`～`app902` の 12 本の `.wml` を使い、同じ定義が Flutter へどう展開されるかを解説）*

第 14 章で見た 12 本の `.wml` ファイルは、Windows デスクトッププログラムにしかならないわけではありません。WapForm for Flutter を使えば、**同じ WML 定義**を 1 行も変えずに、WapForm Toolkit のジェネレーターで Flutter のページ一式に展開できます。生成された Dart コードが呼び出すのは、本書の各節の 📱 Flutter セクションで紹介した `wapform_flutter` のモジュールです。

### 16.1 なぜ別の Runtime が必要なのか

マルチプラットフォーム開発で本当に高くつくのは、決して「コンポーネントの見た目」ではなく、**プラットフォームを変えるたびにアプリケーションロジックを作り直さなければならないこと**です。WapForm が解決するのはコンポーネントの移植ではなく、**アプリケーションの定義方法**の移植です。データソース、フィールド、ルックアップ、イベント、フォーム、レポートはすべて WML で記述され、どのプラットフォームの文法にも縛られません。

> **一度定義し、何度でも展開する。**

`wapform_flutter` は WML を Flutter へ展開するのに必要な Runtime です。同時に通常の Dart パッケージでもあり、ジェネレーターを使わずに手で書いて直接使うこともできます。

### 16.2 パッケージ構成：WapForm モジュール

| モジュール | 役割 | 対応する WML |
|---|---|---|
| `wapform_expression.dart` | 式エンジン `WapEvaluator`：600 近い組み込み関数、独自関数を登録可能。データベースに依存しない | 第 6 章、付録 B、付録 C |
| `wapform_lazarus.dart` | タグエンジン：`useEngine()`、`setvar()`、`expression()`、`condition()`、`expand*()`、`invoke()`、`varChangeHooks`。データセットのレジストリ `DataSetRegistry`、クエリ `DbQuery` | `<setvar>`、`<if>`、`<while>`、`<invoke>`、`<dbquery>`、`$(...)` |
| `wapform_lookup_box.dart` | ルックアップ・ドロップダウン `WapLookupBox` | `<input lookup>`、`<item lookup>` |
| `wapform_filter.dart` | フィルターバー `WapFilter`／`FilterItem` | `<dbfilter>` |
| `wapform_report.dart` | グループ化レポートエンジン `WapReport`、レポートプレビューページ `WapPage`、用紙と向きのツール | `<report>`、`<group>`、`<page>`、`<newpage>`、`device="PRV"` |
| `wapform_report_style.dart` | レポートの CSS：`reportCssScreen`、`reportCssPrint`、`reportCssSrc` | レポートの `class="wap"` などのスタイル |
| `report_web.dart` | プラットフォームに応じて自動で切り替わる印刷の実装（Web：新しいタブで印刷） | Web での印刷 |
| `wapform_colors.dart` | `WapColors`：`assets/wapform.htm` から共通の色を読む | `class="row1"`／`"row2"` の交互の行の色 |

### 16.3 WML タグを Dart クラスへ 1 対 1 で対応づける方法

| WML | Dart |
|---|---|
| `<dbquery id="em">` | `await db.query("em", sql)` |
| `<setvar name= value=>` | `setvar(name, value)` |
| `<if cnd=>`／`<while cnd=>` | `if (condition(...))`／`while (condition(...))` |
| `<invoke instance= method=>` | `invoke(instance, method)` |
| `$(...)` | `expandText()`。SQL では `expandSql()` |
| `<input lookup=>` | `WapLookupBox` |
| `<dbfilter>` | `WapFilter` |
| `<report>`／`<group change=>` | `WapReport` サブクラス、`expression(idx)` |
| `device="PRV"` | `WapPage` |
| `<platform name="flutter">` | CDATA の内容がそのまま Dart コードになる |

各タグの完全な対応は、第 4 章の各タグの 📱 Flutter セクションと 4.13 節の対照表を参照してください。この 1 対 1 の対応により、ジェネレーターの出力は完全に機械的にできます。

### 16.4 マスター・ディテール構造の対応：出荷伝票と明細

宣言型のマスター・ディテール関連 `masterfields="sno"` は、Flutter では「ヘッダーのカーソル移動 → ヘッダーの伝票番号で明細を再検索」に展開され、明細を追加するときはヘッダーの伝票番号を引き継ぎます：

```dart
Future<void> onShipmentScroll() =>
    db.query("sn", r"select * from sn where sno=$(AsQuoted(sh.sno)) order by itm");

void onNewItem() => setvar("sn.sno", "sh.sno");
```

これは 3.2 節「パターン：マスター・ディテール構造」の Windows 側の動作と同じで、イベントのフックポイントが違うだけです。`<item lookup="pa;pno;des">` は `WapLookupBox(forGrid: true)` がグリッドのセル内でルックアップのリストを提供します。

### 16.5 レポートエンジンの対応：グループ小計が `parseBlock`/`emitRow` になるまで

`<group change="sh.cno">` の 3 部構成（グループ開始、1 行ずつの出力、グループ終了）は、`WapReport.parseBlock()` の `G1_PREFIX`、`RECORD`、`G1_SUFFIX` に展開されます。`change=` の式は `expression(0)` の戻り値です（完全なコードは 4.7 節 `<group>` の 📱 Flutter セクション参照）。

`emitRow()` は 1 行出力するたびに行数を確かめ、`wap.wapLpp` 行に達すると `PAGESUFFIX` → `PAGEBREAK` → `PAGEPREFIX` を出力します——その行が WML の `<group>` から生成されたものでも手書きでも、呼び出し側は何行印刷したかを追跡する必要はありません。サブレポート（`device="sub"`）が出力した行も同じページの流れに数えられるので、何階層ネストしてもレイアウトが崩れることはありません。

`WapPage` のパラメーター：

| パラメーター | 説明 |
|---|---|
| `title` | タイトル |
| `report` | `WapReport` オブジェクト（`src` とどちらか一方） |
| `src` | HTML を直接渡す。先に `expandText()` を通る（`report` とどちらか一方） |
| `paper` | `A4`（既定）、`A3`、`A5`、`B5`、`letter`、`legal`、またはインチ単位のカスタム `"8.5x5.5"` |
| `orient` | `P`（既定）。`L`、`landscape`、`1`、`橫`、`水平` は横向き |
| `showPrint` | 印刷ボタンを表示するかどうか |
| `fontAsset` | PDF を生成するときの CJK フォント（既定 `assets/fonts/NotoSansTC-Regular.ttf`） |
| `padding`、`htmlStyle` | レイアウトの余白と独自の HTML スタイル |

用紙のツール関数：`isLandscape(orient)`、`normalizePaper(paper)`、`customPaperSizeInches(paper)`（`"8.5x5.5"` → `(8.5, 5.5)`）、`pageSizeOf(paper, orient)`（CSS の `@page size` の値）。

### 16.6 ファイル構成：1 ファイル 1 独立ユニット

`wapform_flutter.dart` はバレルファイルで、`import 'package:wapform_flutter/wapform_flutter.dart'` ですべてのファイルを一度に取り込めます。各ファイルは単独でもインポートでき、たとえば式エンジンだけが必要なら `package:wapform_flutter/wapform_expression.dart` をインポートすれば済みます。ファイルを `lib/src/` に隠さず `lib/` の直下にフラットに置いているのは、単独でインポートする道を残すためです。

| ファイル | 依存先 |
|---|---|
| `wapform_expression.dart` | `crypto` のみに依存し、単独で使える |
| `wapform_lazarus.dart` | 式エンジン ＋ パッケージのデータセット |
| `wapform_lookup_box.dart`、`wapform_filter.dart` | Flutter |
| `wapform_report.dart` | タグエンジン ＋ `wapform_report_style.dart` ＋ `report_web.dart` |
| `wapform_colors.dart` | Flutter（asset を読む） |

### 16.7 実例による検証：`app001`～`app902` を一括変換

`example/lib/pages/` の下の 12 本の `.dart` ファイルは、WapForm Toolkit が第 14 章の `app001.wml`～`app902.wml` から自動生成したものです：

| Flutter ページ | 対応する第 14 章の節 | テーブル |
|---|---|---|
| `app001.dart` | 14.2　システムパラメーター入力 | `sys` |
| `app002.dart` | 14.2／14.6　商品データ入力（`<platform>` による画像アップロード付き） | `pa`（`web`／`ve` はルックアップの取得元テーブル） |
| `app003.dart` | 14.2　ブランドデータ入力 | `ve` |
| `app004.dart` | 14.2　顧客データ入力 | `cu` |
| `app005.dart` | 14.2　社員データ入力 | `em` |
| `app006.dart` | 14.4～14.7、14.9　出荷伝票入力 | `sh`／`sn`／`cu`／`em` |
| `app007.dart` | 14.8　顧客データ表の印刷 | `cu` |
| `app012.dart` | 14.8　売掛金明細書（グループ化レポート） | `sh`（`sys` がレターヘッドの設定値を提供） |
| `app023.dart` | 14.3　入金伝票の照会 | `sh`／`cu`／`fm` |
| `app037.dart` | 14.2　運送業者データ入力 | `fm` |
| `app901.dart` | 14.10　アカウント管理 | `users` |
| `app902.dart` | 14.10　パスワード（権限）データ入力 | `mnu`／`login`／`users` |

`example/` には対応する `*.wml` も含まれているので、各タグが何を生成したかを 1 つずつ比較できます。

### 16.8 プラットフォームの現状と既知の制限

- **対応プラットフォーム**：Web と Android。
- **データベースには常に HTTP ゲートウェイ経由で接続**：ブラウザーはデータベースに直接接続できないため、パッケージの `example/server/` に Node.js のゲートウェイを同梱しています。
- **印刷**：Web はブラウザーの印刷に任せ、Android はシステムの WebView でレイアウトしてからベクター PDF を生成します。
- **対応モジュールのない WML の機能**：クロス集計、チャート、Web テンプレートと Session、`<open>`／`<webcopy>`、メール送信など。必要なら `<platform name="flutter">` で Dart コードを埋め込みます（4.5 節）。
- **式エンジンの違い**：付録 C を参照してください。

### 16.9 インストールとライセンス

```yaml
dependencies:
  wapform_flutter: ^1.6.7
```

```dart
import 'package:wapform_flutter/wapform_flutter.dart';
```

ライセンスは **LGPL-2.1 に静的リンク例外を付けたもの**（「Modified LGPL」）です。クローズドソースの App でこのパッケージを使えます。「パッケージ自身のソースファイル」の変更版を再配布する場合にのみ、その変更を同じライセンスで公開する必要があります。これは WapForm Toolkit（ジェネレーター）の商用ライセンスとは別の話です。

### 16.10 本章のまとめ

| 手法 | 対応する節 | 用途 |
|---|---|---|
| WapForm のモジュール構成 | 16.2、16.6 | 式、タグエンジン、ルックアップ、フィルターバー、レポートがそれぞれ独立し、個別にインポートできる |
| WML タグから Dart への 1 対 1 の対応 | 16.3 | ジェネレーターの出力を完全に機械的にする |
| `masterfields` → ヘッダー移動時に明細を再検索 | 16.4 | 宣言型のマスター・ディテール関連を、親側のイベント連動に展開 |
| `<group change>` → `parseBlock`／`emitRow` | 16.5 | Windows／Flutter の 2 つの Runtime にまたがる同一設計のグループ化レポートエンジン |
| `<platform>` | 4.5 | Flutter に対応タグがまだない機能を Dart コードで補う |
| 同じ 12 本の `.wml` から 12 本の `.dart` を生成 | 16.7 | 販売管理システムの Windows と Flutter の 2 つのプラットフォームでの具体的な対照 |

第 14 章と本章を合わせて見ると、同じ一文を 2 回示したことになります：**WapForm はアプリケーションの Source of Truth であり、Runtime は着地層にすぎない**。

---

## 付録 A　クイックリファレンスカード

### Card の `device` の値

| `device` | Windows | Web | ウィンドウ／描画の種類 |
|---|---|---|---|
| *(省略)* / `wap` | ✅ | ❌ | 入力フォーム |
| `MDI` | ✅ | ❌ | MDI 親ウィンドウ |
| `prv` | ✅ | ❌ | 印刷プレビュー |
| `prn` | ✅ | ❌ | 直接印刷 |
| `SUB` / `sub` | ✅ | ✅ | バックグラウンド実行——UI なし |
| `XYZ` | ✅ | ❌ | 副作用モデル付きのバックグラウンド実行 |
| `wapform.html` | ❌ | ✅ | Web のメインページ card。HTML テンプレートを適用 |
| `wapform-js.html` | ❌ | ✅ | Web のメインページ card。JS 付きのテンプレートを適用 |

### ナビゲーション

| 要素 | Win | Web | 動作 |
|---|---|---|---|
| `&lt;go href="#id"/&gt;` | ✅ | ✅ | card へ移動 |
| `&lt;go href="@id"/&gt;` | ✅ | ✅ | 関数を呼び出す |
| `&lt;prev/&gt;` | ✅ | ❌ | 前の card に戻る |
| `&lt;exit/&gt;` | ✅ | ✅ | 現在の SUB またはフローを抜ける |
| `&lt;redirect href="url"/&gt;` | ❌ | ✅ | HTTP リダイレクト |

### Web 専用オブジェクト

| 式 | 説明 |
|---|---|
| `request.param` | HTTP GET/POST パラメーターの値 |
| `session.var` | サーバーサイドの session 変数 |
| `DEFINE(request.foo)` | request パラメーターが存在するかを確認 |
| `DEFINE(session.foo)` | session 変数が存在するかを確認 |

### Session の書き込みと有効期間

| 書き方 | 働き |
|---|---|
| `&lt;session name="usr" value="A"/&gt;` | 書き込み。session 全体の寿命に従う |
| `&lt;session name="usr" value="A" expire="480"/&gt;` | 書き込み。480 分後に自動で失効（2026-09 以降のエンジンが必要） |
| `&lt;session name="usr" value="''"/&gt;` | 削除（期限のタイムスタンプも含む） |
| `&lt;session name="usr" value="A" expire="0"/&gt;` | 値を残し、期限の設定を解除 |
| `&lt;session name="k" value="'1'" cnd="式"/&gt;` | 条件が成立したときだけ書き込む |

`expire` のよく使う換算：`60`＝1 時間、`480`＝8 時間、`1440`＝1 日、`10080`＝7 日、`43200`＝30 日。

| 寿命の層 | 制御方法 | 既定 |
|---|---|---|
| session 変数 | `expire` 属性 | 期限なし |
| ブラウザーの cookie | サーバー設定 | ブラウザーを閉じると失効 |
| サーバーの session | サーバー設定 | 7 日間アイドル |

session のデータはサーバーのメモリにあり、再起動するとすべて失効します。詳しくは 4.11、7.4、15.9 節を参照してください。

### データセットのメソッド

| `&lt;call name="ds" method="..."/&gt;` | Win | Web | 動作 |
|---|---|---|---|
| `first` / `last` / `next` / `prior` | ✅ | ✅ | カーソル移動 |
| `locate` params=`"'field';value"` | ✅ | ✅ | キー値で探す |
| `post` / `cancel` | ✅ | ⚠️ | 保存 / 破棄 |
| `refresh` | ✅ | ⚠️ | データベースから読み込み直す |
| `edit` / `insert` / `delete` | ✅ | ❌ | 状態の切り替え |
| `DisableControls` / `EnableControls` | ✅ | ❌ | 反復中に UI を凍結 |
| `GetBookmark` / `GoToBookmark` / `FreeBookmark` | ✅ | ❌ | ブックマーク操作 |

### 式の中のデータセットのプロパティ

| 式 | 値 |
|---|---|
| `ds.field_name` | 現在の行のフィールド値 |
| `ds.COUNT` | 総行数 |
| `ds.EOF` / `ds.BOF` | カーソル位置のフラグ |
| `ds.state` | `'BROWSE'` / `'EDIT'` / `'INSERT'`（Win）|

### イベントのクイックリファレンス（Windows 専用）

| イベント | 宣言する場所 | 発生タイミング |
|---|---|---|
| `onnewrecord` | `&lt;dbquery&gt;` / `&lt;dbtable&gt;` | レコード追加時 |
| `beforedelete` | `&lt;dbquery&gt;` / `&lt;dbtable&gt;` | 削除前 |
| `afterpost` | `&lt;dbquery&gt;` / `&lt;dbtable&gt;` | 保存後 |
| `afterscroll` | `&lt;dbquery&gt;` / `&lt;dbtable&gt;` | カーソル移動後 |
| `onchange` | `&lt;input&gt;` | 値の変更時 |
| `oncloseup` | lookup 付きの `&lt;input&gt;` | Lookup の選択後 |
| `onexit` | `&lt;input&gt;` | フォーカスを失ったとき |
| `ondblclick` | `&lt;dbgrid&gt;` | 行のダブルクリック時 |
| `oncalccellcolors` | `&lt;dbgrid&gt;` | セルの描画時 |

### 関数早見表

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

**📱 Flutter 早見表**

| やりたいこと | Dart |
|---|---|
| 現在の card のエンジンを指定 | `useEngine(_ev, _reg)` |
| クエリを開く（`<dbquery id>`） | `await db.query("x", r"select ... where a='$v'")` |
| パラメーター付きのクエリ | `await db.query("x", "... where a=:a", params: {"a": v})` |
| 行を返さない SQL | `await db.exec(r"update ...")` |
| 変数やフィールドを設定 | `setvar("TOTAL", "pa.qty*pa.price")`、`setvar("pa.icon", "'a.jpg'")` |
| Dart の値をそのまま格納 | `_ev.setVar("NAME", userInput)` |
| 計算／条件 | `expression("TOTAL*1.05")`、`condition("(qty>0) AND (price<100)")` |
| テキスト／SQL の補間 | `expandText(r"$(pa.des)")`、`expandSql(r"where $S")`、`expandSqlAuto(r"where a=$v")` |
| データセットのメソッド | `invoke("pa", "first")` |
| ルックアップ | `WapLookupBox(dataSet:, keyField:, displayFields:, value:, onPicked:)` |
| フィルターバー | `WapFilter(items: [FilterItem(...)], sqlTemplate: r"... where $R", onQuery:)` |
| レポート | `WapReport` サブクラス ＋ `WapPage(title:, report:, paper:, orient:)` |
| 改ページ | `forcePageBreak()` |
| 独自関数 | `_ev.addFunction1Param("TAXED", (v) => (v as num) * 1.05)` |

### よく使うパターン早見

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

## 付録 B　関数完全リファレンス

> この付録は WapForm の式の中核（`TmyParser`）の標準関数ライブラリをすべて収録しており、計 **398 個の関数**です。
WapForm 言語の最も基礎となる層で、Windows、Web、Flutter、COBOL の各プラットフォームで共通に対応しています。

> 呼び出し方：WapForm の式の中で関数名をそのまま呼び出します。プレフィックスは不要です。例：`$(ABS(v1))`、`$(UPPER(name))`。

---

### 目次

1. 数学演算（55 個）
2. 統計集計（12 個）
3. 文字列処理（86 個）
4. 数値変換（55 個）
5. 日付と時刻（62 個）
6. 条件と論理（21 個）
7. ローカライズ（9 個）
8. 乱数（1 個）
9. 暗号化とセキュリティ（5 個）
10. システムと環境（27 個）
11. パス処理（6 個）
12. 動的変数と配列（14 個）
13. 財務関数（8 個）
14. その他の組み込み関数（今回の追加テストでカバー）（34 個）
15. その他の組み込み関数（自動テストに不向き）（10 個）

---

### B.1　数学演算

| 関数 | 説明 | 例 |
|---|---|---|
| `ABS(x)` | 絶対値 | `ABS(-5)=5` |
| `ACOS(x)` | 逆余弦 | `ACOS(0)=1.5708` |
| `ASIN(x)` | 逆正弦 | `ASIN(1)=1.5708` |
| `ATAN(x)` | 逆正接 | `ATAN(1)=0.7854` |
| `COS(x)` | 余弦 | `COS(0)=1` |
| `SIN(x)` | 正弦 | `SIN(0)=0` |
| `TAN(x)` | 正接 | `TAN(0)=0` |
| `SQRT(x)` | 平方根 | `SQRT(16)=4.0` |
| `EXP(x)` | e のべき乗 | `EXP(1)=2.71828` |
| `LN(x)` | 自然対数 | `LN(2.71828)=1` |
| `LOG(x)` | 10 を底とする対数 | `LOG(100)=2` |
| `POWER(x,n)` | x の n 乗 | `POWER(2,10)=1024` |
| `PI` | 円周率の定数 | `PI=3.14159` |
| `INT(x)` | 整数部分を取る（ゼロ方向へ切り捨て） | `INT(9.8)=9` |
| `FIX(x)` | 整数を取る（負の無限大方向へ丸める） | `FIX(-9.8)=-10` |
| `CEIL(x)` | 切り上げ | `CEIL(2.1)=3` |
| `TRUNC(x)` | 小数部分を切り捨て、正負にかかわらずゼロ方向へ整数化 | `TRUNC(3.9)=3` |
| `FLOOR(x)` | 切り捨て | `FLOOR(2.9)=2` |
| `ROUND(x,d)` | 小数点以下 d 桁に四捨五入（標準の四捨五入） | `ROUND(3.456, 2)=3.46` |
| `FRAC(x)` | 小数部分を取る | `FRAC(3.75)=0.75` |
| `MAX(a,b)` | 2 つのうち大きい値を返す | `MAX(3,7)=7` |
| `MIN(a,b)` | 2 つのうち小さい値を返す | `MIN(3,7)=3` |
| `MOD(a,b)`（演算子） | 剰余の演算子 | `MOD(7,3)=1` |
| `GreatestCommonDivisor(a, b)` | 最大公約数（ユークリッドの互除法） | `GreatestCommonDivisor(12,18)=6` |
| `ClampValue(value, lo, hi)` | 値を [lo, hi] の範囲に制限 | `ClampValue(15,0,10)=10` |
| `LerpValue(a, b, t)` | 線形補間 a + (b-a)*t | `LerpValue(0,10,0.5)=5` |
| `IsBetween(value, lo, hi)` | 値が [lo, hi] の範囲にあるかを判定 | `IsBetween(5,1,10)=True` |
| `PercentOf(part, total)` | 百分率の計算。total=0 のときは 0 を返す | `PercentOf(25,200)=12.5` |
| `RoundBankers(value, decimals)` | 銀行型丸め（偶数丸め） | `RoundBankers(2.5,0)=2` |
| `IsPrimeNumber(n)` | 素数かどうかを判定 | `IsPrimeNumber(7)=True` |
| `Fibonacci(n)` | n 番目のフィボナッチ数（0 始まり：F(0)=0, F(1)=1） | `Fibonacci(10)=55` |
| `Log2Value(x)` | 2 を底とする対数 | `Log2Value(8)=3` |
| `LogNValue(base, x)` | base を底とする対数 | `LogNValue(3,9)=2` |
| `HypotOf(a, b)` | 直角三角形の斜辺 sqrt(a²+b²) | `HypotOf(3,4)=5` |
| `DegreeToRad(deg)` | 度 → ラジアン | `DegreeToRad(180)=3.14159` |
| `RadToDegree(rad)` | ラジアン → 度 | `RadToDegree(3.14159)=180` |
| `CubeRoot(x)` | 立方根（cube root） | `CubeRoot(27)=3` |
| `EvenCeil(n)` | n 以上の最小の偶数 | `EvenCeil(3)=4` |
| `SumOfSquares(values)` | 各項の平方和 Σ(xᵢ²) | `SumOfSquares([1,2,3])=14` |
| `ProductOf(values)` | 各項の積 Π(xᵢ) | `ProductOf([2,3,4])=24` |
| `HarmMeanValue(values)` | 調和平均 n / Σ(1/xᵢ) | `HarmMeanValue([1,2,4])=1.71428571428571` |
| `GeoMeanValue(values)` | 幾何平均 (Πxᵢ)^(1/n) | `GeoMeanValue([1,3,9])=3` |
| `QuartileOf(values, q)` | 四分位数。q=1 で Q1、q=2 で中央値、q=3 で Q3 | `QuartileOf([1,2,3,4,5,6,7,8,2])=4.5` |
| `NetPresentValue(rate, values)` | 正味現在価値 NPV。最初の引数が割引率、残りが各期のキャッシュフロー | `NetPresentValue([0.1,-1000,400,500,600])=206.953076975616` |
| `InternalRateOfReturn(values, guess)` | 内部収益率（ニュートン・ラフソン法、最大 100 回反復）。最後の引数が初期推定値 | `InternalRateOfReturn([-1000,400,500,600,0.1])=0.216477854184290` |
| `Exp10Value(n)` | 10 の引数乗 | `Exp10Value(2)=100` |
| `Log10Value(n)` | 10 を底とする対数 | `Log10Value(100)=2` |
| `RemainderValue(n, d)` | 浮動小数点の剰余。結果の符号は被除数と同じ（MOD とは意味が異なる） | `RemainderValue(-7,3)=-1` |
| `ToIntegerValue(n)` | 引数を超えない最大の整数（切り捨て） | `ToIntegerValue(-3.5)=-4` |
| `IntegerPart(n)` | 小数部分を切り捨て（ゼロ方向へ整数化） | `IntegerPart(-3.5)=-3` |
| `FractionPart(n)` | 引数の小数部分を返す | `FractionPart(3.75)=0.75` |
| `Factorial(n)` | 階乗 n! | `Factorial(5)=120` |
| `EulerNumber` | ネイピア数 e ≈ 2.71828…（引数なし） | `EulerNumber=2.71828` |
| `SignOf(n)` | 引数の正負またはゼロを表す -1、0、1 を返す | `SignOf(-8)=-1` |
| `Annuity(rate, periods)` | 各期の年金現価係数 ANNUITY(rate, periods) | `Annuity(0.05,10)=0.1295` |
| `PresentValue(rate, amounts…)` | 現在価値の計算。最初の引数が割引率、残りが各期の金額 | `PresentValue([0.1,100,200,300])=481.592787377911` |

---

### B.2　統計集計

| 関数 | 説明 | 例 |
|---|---|---|
| `COUNT(v1, v2, …)` | 個数（配列の要素数） | `COUNT([1,2,3,4])=4` |
| `MeanValue(v1, v2, …)` | 算術平均 | `MeanValue([2,4,6])=4` |
| `MedianValue(v1, v2, …)` | 中央値 | `MedianValue([1,3,2])=2` |
| `MidRangeValue(v1, v2, …)` | (最大値 + 最小値) / 2 | `MidRangeValue([2,10])=6` |
| `RangeValue(v1, v2, …)` | 範囲（最大値 − 最小値） | `RangeValue([2,10,5])=8` |
| `SumOfValues(v1, v2, …)` | すべての引数の合計 | `SumOfValues([1,2,3])=6` |
| `VarianceValue(v1, v2, …)` | 分散 | `VarianceValue([2,4,6])=2.6667` |
| `StandardDeviation(v1, v2, …)` | 標準偏差 | `StandardDeviation([2,4,6])=1.6330` |
| `OrdMax(v1, v2, …)` | 最大値の引数リスト内での位置（1 始まり）を返す | `OrdMax([3,7,2])=2` |
| `OrdMin(v1, v2, …)` | 最小値の引数リスト内での位置（1 始まり）を返す | `OrdMin([3,7,2])=3` |
| `HighestAlgebraic(n)` | 引数のデータ型で表せる最大値を返す（実際の型で判定）。引数の値とは無関係 | `HighestAlgebraic(123)=2147483647` |
| `LowestAlgebraic(n)` | 引数のデータ型で表せる最小値を返す（実際の型で判定）。引数の値とは無関係 | `LowestAlgebraic(123)=(-2147483647-1)` |

---

### B.3　文字列処理

| 関数 | 説明 | 例 |
|---|---|---|
| `LEN(s)` | 文字列の長さ（文字数） | `LEN('Hello')=5` |
| `LENA(s)` | バイト長 | `LENA('中文')=6（UTF-8 では 1 文字 3 byte）` |
| `AnsiLength(s)` | ANSI のバイト長 | `AnsiLength('中文')=4（Big5 では 1 文字 2 byte）` |
| `LOWER(s)` | 小文字に変換 | `LOWER('ABC')=abc` |
| `UPPER(s)` | 大文字に変換 | `UPPER('abc')=ABC` |
| `AnsiLowerCase(s)` | ANSI で小文字に変換 | `AnsiLowerCase('ABC')=abc` |
| `AnsiUpperCase(s)` | ANSI で大文字に変換 | `AnsiUpperCase('abc')=ABC` |
| `TRIM(s)` | 前後の空白を除去 | `TRIM('  Hi  ')=Hi` |
| `LTRIM(s)` | 左側の空白を除去 | `LTRIM('  Hi')=Hi` |
| `RTRIM(s)` | 右側の空白を除去 | `RTRIM('Hi  ')=Hi` |
| `MID(s,p,n)` | 部分文字列を取る（byte 単位） | `MID('Wapform', 2, 3)='apf'` |
| `MIDA(s,p,n)` | 部分文字列を取る（ANSI の文字単位） | `MIDA('Hello',2,3)=ell` |
| `AnsiMid(s,p,n)` | 部分文字列を取る（ANSI 単位） | `AnsiMid('Hello',2,3)=ell` |
| `POS(sub,s)` | 部分文字列の位置を探す（byte 単位） | `POS('lo','Hello')=4` |
| `FINDA(sub,s)` | 部分文字列の位置を探す（ANSI 単位） | `FINDA('lo','Hello')=4` |
| `AnsiPos(sub,s)` | 部分文字列の位置を探す（ANSI 単位） | `AnsiPos('lo','Hello')=4` |
| `INSTR(s,sub)` | 文字列の位置を探す | `INSTR('Hello','lo')=4` |
| `REPLACE(s,old,new)` | 文字列を置換 | `REPLACE('hello', 'l', 'm')='hemmo'` |
| `REPLACEA(s,old,new)` | 文字列を置換（ANSI 版） | `REPLACEA('Hello','l','L')=HeLLo` |
| `REPLACEAT(s,p,new)` | 指定位置で置換 | `REPLACEAT('Hello',1,'J')=Jello` |
| `INSERT(s,p,n,new)` | 文字列を挿入（byte） | `INSERT('Hllo',2,0,'e')=Hello` |
| `INSA(s,p,new)` | 文字列を挿入（ANSI 単位） | `INSA('Hllo',2,'e')=Hello` |
| `AnsiInsert(s,p,new)` | 文字列を挿入（ANSI 単位） | `AnsiInsert('Hllo',2,'e')=Hello` |
| `DELETE(s,p,n)` | 部分文字列を削除（byte） | `DELETE('Hello',1,1)=ello` |
| `DELA(s,p,n)` | 部分文字列を削除（ANSI 単位） | `DELA('Hello',1,1)=ello` |
| `AnsiDelete(s,p,n)` | 部分文字列を削除（ANSI 単位） | `AnsiDelete('Hello',1,1)=ello` |
| `CHR(n)` | コードポイントを文字に変換 | `CHR(65)=A` |
| `ASC(c)` | 文字をコードポイントに変換 | `ASC('A')=65` |
| `ORD(c)` | 文字の序数（ASC と同じ） | `ORD('A')=65` |
| `CODE(s)` | コード欄の解析 | `CODE('001-ABC')=001（データ形式による）` |
| `NAME(s)` | 名称欄の解析 | `NAME('001-ABC')=ABC（データ形式による）` |
| `REPT(s,n)` | 文字列を n 回繰り返す | `REPT('*', 5)='*****'` |
| `FORMAT(fmt,x)` | 書式付き出力 | `FORMAT('0.00',3.5)=3.50` |
| `FormatDateTime(fmt,d)` | 独自の書式文字列で日付時刻を整形 | `FormatDateTime('yyyy/mm/dd','2026-08-03')=2026/08/03` |
| `FormatFloat(fmt,n)` | 独自の書式文字列で浮動小数点数を整形 | `FormatFloat('#,##0.00',12345.6)=12,345.60` |
| `LIKE(s,pat)` | ワイルドカードによる照合 | `LIKE('Hello','H*o')=True` |
| `AnsiCompareStr(a,b)` | ANSI で大文字・小文字を区別して比較 | `AnsiCompareStr('abc','abd')=-1` |
| `AnsiCompareText(a,b)` | ANSI で大文字・小文字を区別せずに比較 | `AnsiCompareText('ABC','abc')=0` |
| `CompareStr(a,b)` | 文字列の比較（大文字・小文字を区別） | `CompareStr('abc','abd')=-1` |
| `CompareText(a,b)` | ローカライズされた文字列比較 | `CompareText('ABC','abc')=0` |
| `HEX(n,d)` | 整数を 16 進文字列に変換 | `HEX(255,4)=00FF` |
| `ANSI(s)` | UTF-8 を ANSI に変換 | `ANSI('中文')=中文（Big5 エンコードのバイト列に変換）` |
| `UTF8(s)` | ANSI を UTF-8 に変換 | `UTF8('中文')=中文（UTF-8 エンコードのバイト列に変換）` |
| `HTML(s)` | HTML の特殊文字をエスケープ | `HTML('<b>')=&lt;b&gt;` |
| `FillChar(s,c)` | 文字で埋める | `FillChar(5,'*')=*****` |
| `LeftPad2(str, len)` | 左側を空白で埋めて len 幅にする | `LeftPad2('5',3)='  5'` |
| `RightPad2(str, len)` | 右側を空白で埋めて len 幅にする | `RightPad2('5',3)='5  '` |
| `CenterPad(str, len)` | 空白で埋めて len 幅の中央に揃える | `CenterPad('5',5)='  5  '` |
| `LeftPad(str, len, ch)` | 左側を指定文字で埋めて len 幅にする | `LeftPad('5',3,'0')='005'` |
| `RightPad(str, len, ch)` | 右側を指定文字で埋めて len 幅にする | `RightPad('5',3,'0')='500'` |
| `RepeatStr(str, n)` | 文字列を n 回繰り返す | `RepeatStr('ab',3)='ababab'` |
| `CountStrOccur(substr, str)` | 部分文字列の出現回数を数える | `CountStrOccur('a','banana')=3` |
| `StartsWithStr(str, prefix)` | 文字列が prefix で始まるか | `StartsWithStr('Hello','He')=True` |
| `EndsWithStr(str, suffix)` | 文字列が suffix で終わるか | `EndsWithStr('Hello','lo')=True` |
| `ContainsStr2(str, substr)` | 文字列が部分文字列を含むか | `ContainsStr2('Hello','ell')=True` |
| `WrapStr(str, width)` | width 文字ごとに改行（CRLF）を挿入 | `WrapStr('HelloWorld',5)='Hello\nWorld'` |
| `SplitStr(str, delim, n)` | delim で文字列を分割し、n 番目のトークンを取る（1 始まり） | `SplitStr('a,b,c',',',2)='b'` |
| `SplitCount(str, delim)` | delim で文字列を分割し、トークン数を数える | `SplitCount('a,b,c',',')=3` |
| `JoinStr(str, delim)` | str 内の空白区切りの複数の語（空白が連続してもよい）を delim でつなぎ直す。例：`JoinStr('A  B  C', ' ')` → `'A B C'` | `JoinStr('A  B  C',' ')='A B C'` |
| `TokenAt(str, delim, n)` | n 番目のトークンを取る（1 始まり）。複数文字の区切りも可 | `TokenAt('a-b-c','-',2)='b'` |
| `EllipsisStr(str, maxLen)` | maxLen を超えたら切り詰めて '...' を付ける | `EllipsisStr('HelloWorld',5)='Hello...'` |
| `CapWords(str)` | 各単語の先頭を大文字にする（英語） | `CapWords('hello world')='Hello World'` |
| `CharAt(str, n)` | n 番目の文字を取る（1 始まり）。範囲外なら '' を返す | `CharAt('Hello',2)='e'` |
| `IndexOfStr(substr, str, start)` | start の位置（1 始まり）から部分文字列を探す | `IndexOfStr('l','Hello',1)=3` |
| `LastIndexOfStr(substr, str)` | 右側から部分文字列を探し、最後に現れる位置（1 始まり）を返す | `LastIndexOfStr('l','Hello')=4` |
| `RemoveChars(str, chars)` | 文字列から chars に含まれる文字をすべて取り除く | `RemoveChars('Hello123','0123456789')='Hello'` |
| `KeepChars(str, chars)` | 文字列のうち chars に含まれる文字だけを残す | `KeepChars('Hello123','0123456789')='123'` |
| `OnlyDigits(str)` | 数字以外の文字をすべて取り除く | `OnlyDigits('A1B2C3')='123'` |
| `OnlyAlpha(str)` | 英字以外の文字をすべて取り除く | `OnlyAlpha('A1B2C3')='ABC'` |
| `MaskStr(str, mask, placeholder)` | マスクのひな形を 1 文字ずつ適用する。マスク中で placeholder に等しい位置には str の文字を順に入れ、それ以外の位置はマスクの文字をそのまま残す（電話番号や ID の整形など）。placeholder の既定は '#' | `MaskStr('123456','##-##-##','#')='12-34-56'` |
| `UnmaskStr(str, mask, ch)` | マスクを取り除き、'#' の位置の文字だけを残す | `UnmaskStr('12-34-56','##-##-##','#')='123456'` |
| `SlugifyStr(str)` | URL スラッグに変換（小文字化、空白→ハイフン、特殊文字の除去） | `SlugifyStr('Hello World!')='hello-world'` |
| `TruncWords(str, n)` | 先頭 n 語までに切り詰め、超えた分は '...' を付ける | `TruncWords('The quick brown fox',2)='The quick...'` |
| `CrLfToBr(str)` | 改行記号（CRLF/LF）を HTML の <br/> に変換 | `CrLfToBr('A'+CRLF+'B')='A<br/>B'` |
| `BrToCrLf(str)` | HTML の <br/> / <br> を CRLF に変換 | `BrToCrLf('A<br/>B')='A'+CRLF+'B'` |
| `HtmlEncodeStr(str)` | HTML の特殊文字をエンコード | `HtmlEncodeStr('<b>')='&lt;b&gt;'` |
| `HtmlDecodeStr(str)` | HTML の特殊文字をデコード | `HtmlDecodeStr('&lt;b&gt;')='<b>'` |
| `UrlEncodeStr(str)` | URL のパーセントエンコード（ASCII の範囲） | `UrlEncodeStr('a b')='a%20b'` |
| `ConcatenateStr(v1, v2, …)` | 複数の文字列を連結 | `ConcatenateStr(['Hello',' ','World'])='Hello World'` |
| `ByteLength(n)` | 文字列のバイト数 | `ByteLength('中文')=6` |
| `StoredCharLength(n)` | 末尾の空白を除いた有効な長さ | `StoredCharLength('Hi   ')=2` |
| `LowerCaseValue(n)` | 小文字に変換 | `LowerCaseValue('ABC')='abc'` |
| `UpperCaseValue(n)` | 大文字に変換 | `UpperCaseValue('abc')='ABC'` |
| `ReverseStr(n)` | 文字列を反転 | `ReverseStr('Hello')='olleH'` |
| `SubstituteStr(s, from1, to1, …)` | 部分文字列を置換（大文字・小文字を区別）。引数は (文字列, 置換前1, 置換後1, 置換前2, 置換後2, …) の順にペアで処理 | `SubstituteStr(['Hello','l','L'])='HeLLo'` |
| `SubstituteCaseStr(s, from1, to1, …)` | 部分文字列を置換（大文字・小文字を区別しない）。引数の形式は SUBSTITUTE と同じ | `SubstituteCaseStr(['HeLlo','l','L'])='HeLLo'` |

---

### B.4　数値変換

| 関数 | 説明 | 例 |
|---|---|---|
| `VAL(s)` | 文字列を数値に変換（内容から整数か浮動小数点数かを自動判定） | `VAL('3.14')=3.14` |
| `STR(n)` | 数値を文字列に変換 | `STR(3.14)='3.14'` |
| `FloatToStr(n)` | 浮動小数点数を文字列に変換 | `FloatToStr(3.14)=3.14` |
| `IntToStr(n)` | 整数を文字列に変換 | `IntToStr(42)=42` |
| `StrToFloat(s)` | 文字列を浮動小数点数に変換 | `StrToFloat('3.14')=3.14` |
| `StrToInt(s)` | 文字列を整数に変換 | `StrToInt('42')=42` |
| `FLOAT(x)` | 浮動小数点型に強制変換 | `FLOAT(42)=42.0` |
| `IntToHex(n,d)` | 整数を 16 進文字列に変換 | `IntToHex(255,4)=00FF` |
| `HexToInt(s)` | 16 進文字列を整数に変換 | `HexToInt('FF')=255` |
| `HexToStr(s)` | 16 進エンコードを文字列に変換 | `HexToStr('48656C6C6F')=Hello` |
| `StrToHex(s)` | 文字列を 16 進エンコードに変換 | `StrToHex('Hello')=48656C6C6F` |
| `HexToColor(s)` | 16 進を色の値に変換 | `HexToColor('FF0000')=16711680（赤）` |
| `ColorToHex(n)` | 色の値を 16 進に変換 | `ColorToHex(16711680)=FF0000` |
| `VarToStr(v)` | Variant を文字列に変換 | `VarToStr(123)=123` |
| `VarArrayOf(x)` | Variant 配列を作る | `VarArrayOf(1,2,3)=[1,2,3]` |
| `ZeroFill(n, width)` | 整数の先頭をゼロで埋めて width 桁にする | `ZeroFill(7,3)='007'` |
| `NumberFormat(value, decimals)` | 数値の整形。桁区切り + 小数桁 | `NumberFormat(12345.678,2)='12,345.68'` |
| `CommaFormat(value)` | 数値に桁区切りを付ける（整数） | `CommaFormat(12345)='12,345'` |
| `AsStringValue(value)` | Variant を String に変換。Null/Empty なら '' を返す | `AsStringValue(123)='123'` |
| `AsInt(value)` | Variant を整数に変換（Trunc）。失敗すると 0 を返す | `AsInt(3.9)=3` |
| `AsFloat(value)` | Variant を Extended に変換。失敗すると 0 を返す | `AsFloat('3.14')=3.14` |
| `AsBool(value)` | Variant をブール値に変換。Null/Empty は False、数値型は 0 以外かどうかで判定し、文字列は '1'/'T'/'Y'/'TRUE'/'YES'（大文字・小文字を区別しない）を True とし、それ以外は False | `AsBool('Y')=True` |
| `AsDate(value)` | Variant を TDateTime に変換（日付部分のみ、時刻はゼロ） | `AsDate('2026-08-03 14:30:00')=2026-08-03` |
| `AsTimeValue(value)` | Variant を TDateTime に変換（時刻部分のみ、日付はゼロ） | `AsTimeValue('2026-08-03 14:30:00')=14:30:00` |
| `AsDateTime(value)` | Variant を TDateTime に変換（日付＋時刻） | `AsDateTime('2026-08-03 14:30:00')=2026-08-03 14:30:00` |
| `AsFixed(value, decimals)` | 小数桁固定の文字列（桁区切りなし） | `AsFixed(3.14159,2)='3.14'` |
| `AsCurr(value, decimals)` | 桁区切り付きの通貨文字列。decimals の既定は 2 | `AsCurr(12345.6,2)='12,345.60'` |
| `AsPercent(value, decimals)` | パーセント文字列。'12.34%' など | `AsPercent(0.1234,2)='12.34%'` |
| `AsScientific(value, decimals)` | 指数表記。'1.23E+04' など | `AsScientific(12345,2)='1.23E+04'` |
| `AsYesNo(value)` | ブール値 → 'Y' / 'N' | `AsYesNo(True)='Y'` |
| `AsTrueFalse(value)` | ブール値 → 'T' / 'F' | `AsTrueFalse(True)='T'` |
| `AsZeroOne(value)` | ブール値 → '1' / '0' | `AsZeroOne(True)='1'` |
| `AsBit(value)` | 整数 → 1 ビットのブール文字列（0 以外→'1'、0→'0'） | `AsBit(5)='1'` |
| `AsHex(value, width)` | 整数 → 16 進文字列（width 桁までゼロ埋め） | `AsHex(255,4)='00FF'` |
| `AsOctal(value)` | 整数 → 8 進文字列 | `AsOctal(8)='10'` |
| `AsISO8601(datetime)` | TDateTime → ISO 8601 文字列 'YYYY-MM-DDTHH:MM:SS' | `AsISO8601('2026-08-03 14:30:00')='2026-08-03T14:30:00'` |
| `AsRocDate(datetime)` | TDateTime → 民国暦の日付 'YYY/MM/DD' | `AsRocDate('2026-08-03')='115/08/03'` |
| `AsRocDateTime(datetime)` | TDateTime → 民国暦の日付時刻 'YYY/MM/DD HH:MM:SS' | `AsRocDateTime('2026-08-03 14:30:00')='115/08/03 14:30:00'` |
| `AsSlug(str)` | 文字列 → URL スラッグ（小文字化、空白→'-'、特殊文字の除去） | `AsSlug('Hello World!')='hello-world'` |
| `AsUpper(str)` | 文字列 → すべて大文字 | `AsUpper('abc')='ABC'` |
| `AsLower(str)` | 文字列 → すべて小文字 | `AsLower('ABC')='abc'` |
| `AsTrimmed(str)` | 文字列 → 両端の空白を除去 | `AsTrimmed('  Hi  ')='Hi'` |
| `AsQuoted(str)` | 文字列 → 単一引用符で包む（先に内部の単一引用符をエスケープ） | `AsQuoted("O'Brien")="'O''Brien'"` |
| `AsDQuoted(str)` | 文字列 → 二重引用符で包む（内部の二重引用符はバックスラッシュでエスケープ） | `AsDQuoted('Say "Hi"')='"Say \"Hi\""'` |
| `AsSqlStr(str)` | SQL で安全な文字列（単一引用符をエスケープし、外側の引用符は付けない） | `AsSqlStr("O'Brien")="O''Brien"` |
| `AsNullable(value)` | Null/Empty/空白除去後に空 のときは文字列 'NULL' を返し、それ以外は単一引用符で包んで内部の単一引用符をエスケープした SQL リテラル文字列を返す | `AsNullable(NULL)='NULL'` |
| `AsDefault(value, default)` | Value が Null/Empty/空白 のとき default を返す | `AsDefault(NULL,'N/A')='N/A'` |
| `AsJson(value)` | Variant の型に応じて JSON の値に変換——ブール値は true/false、数値はそのまま、日付は ISO 形式の文字列、Null/Empty は null、それ以外はバックスラッシュ、二重引用符、CR/LF をエスケープした JSON 文字列 | `AsJson('Hi')='"Hi"'` |
| `AsCsv(value1, value2, …)` | 複数の値をカンマでつないで CSV の 1 行にする。値にカンマ、二重引用符、改行が含まれる場合は自動で二重引用符で包み、内部の二重引用符をエスケープ | `AsCsv(['A','B,C','D'])='A,"B,C",D'` |
| `NumVal(n)` | 文字列を数値に変換 | `NumVal('3.14')=3.14` |
| `NumValC(s, symbol)` | 通貨記号と桁区切りのカンマを含む文字列を数値に変換。第 2 引数で通貨記号を指定できる | `NumValC('$1,234.56','$')=1234.56` |
| `NumValF(n)` | 指数表記を含む浮動小数点数の文字列（'1.5E2' など）を数値に変換 | `NumValF('1.5E2')=150` |
| `TestNumVal(n)` | 文字列を安全に数値に変換できるかを検査。0 なら可能 | `TestNumVal('3.14')=0` |
| `TestNumValC(n)` | 通貨記号を含む文字列を安全に数値に変換できるかを検査。0 なら可能 | `TestNumValC('$1,234.56','$')=0` |
| `TestNumValF(n)` | 浮動小数点数の文字列を安全に変換できるかを検査。0 なら可能 | `TestNumValF('1.5E2')=0` |

---

### B.5　日付と時刻

| 関数 | 説明 | 例 |
|---|---|---|
| `NOW` | 現在の日付時刻（形式が異なる） | `NOW=2026-08-03 14:30:00` |
| `TODAY` | 今日の日付 | `TODAY=2026-08-03` |
| `TIME` | 現在の時刻（CURRENT_DATE から時刻部分を取る） | `TIME=14:30:00` |
| `TDATE` | システム日付の別名 | `TDATE=2026-08-03` |
| `yesterday` | 昨日の日付 | `yesterday=2026-08-02` |
| `last-night()` | 昨夜の時点 | `last-night()=2026-08-02 20:00:00` |
| `last-month()` | 先月の初日 | `last-month()=2026-07-01` |
| `last-year()` | 昨年の初日 | `last-year()=2025-01-01` |
| `YEAR(d)` | 年を取る | `YEAR('2026-08-03')=2026` |
| `MONTH(d)` | 月を取る | `MONTH('2026-08-03')=8` |
| `DAY(d)` | 日を取る | `DAY('2026-08-03')=3` |
| `HOUR(d)` | 時を取る | `HOUR('14:30:00')=14` |
| `MINUTE(d)` | 分を取る | `MINUTE('14:30:00')=30` |
| `SECOND(d)` | 秒を取る | `SECOND('14:30:00')=0` |
| `WEEK(d)` | 週番号を取る | `WEEK('2026-08-03')=32` |
| `DAYOFWEEK(d)` | 曜日を取る（内部では DateUtils.DayOfTheWeek を使用、1=Monday...7=Sunday） | `DAYOFWEEK('2026-08-03')=1（Monday）` |
| `DAYOFYEAR(d)` | 年の何日目かを取る | `DAYOFYEAR('2026-08-03')=215` |
| `DaysInAMonth(y,m)` | ある年のある月の日数を得る | `DaysInAMonth(2024, 2)=29` |
| `IsLeapYear(y)` | うるう年かどうか | `IsLeapYear(2024)=True` |
| `StrToDate(s)` | 文字列を日付に変換 | `StrToDate('2026-08-03')=2026-08-03` |
| `StrToDateTime(s)` | 文字列を日付時刻に変換 | `StrToDateTime('2026-08-03 14:30:00')=2026-08-03 14:30:00` |
| `StrToTime(s)` | 文字列を時刻に変換 | `StrToTime('14:30:00')=14:30:00` |
| `DateToStr(d)` | 日付を文字列に変換（システムの地域設定の形式） | `DateToStr('2026-08-03')=2026/8/3` |
| `DateTimeToStr(d)` | 日付時刻を文字列に変換（システムの地域設定の形式） | `DateTimeToStr('2026-08-03 14:30:00')=2026/8/3 下午 02:30:00（中国語ロケールでの午後 2:30:00）` |
| `TimeToStr(t)` | 時刻を文字列に変換 | `TimeToStr('14:30:00')=下午 02:30:00（中国語ロケールでの午後 2:30:00）` |
| `MyDate(d)` | 独自の日付整形（民国暦の形式） | `MyDate('2026-08-03')=115/08/03` |
| `MyDateTime(d)` | 独自の日付時刻整形（民国暦の形式） | `MyDateTime('2026-08-03 14:30:00')=115/08/03 14:30:00` |
| `DateAddValue(date, n, unit)` | 日付の加減算。unit='D'/'M'/'Y'/'W' | `DateAddValue('2026-08-03',1,'M')=2026-09-03` |
| `DateDiffValue(date1, date2, unit)` | 日付の差。unit='D'/'M'/'Y' | `DateDiffValue('2026-01-01','2026-08-03','D')=214` |
| `DatePeriodStart(date, unit)` | 期間の始まりを取る。unit='M'=月初/'Y'=年初/'W'=月曜 | `DatePeriodStart('2026-08-03','M')=2026-08-01` |
| `DatePeriodEnd(date, unit)` | 期間の終わりを取る。unit='M'=月末/'Y'=年末 | `DatePeriodEnd('2026-08-03','M')=2026-08-31` |
| `WorkDaysBetween(date1, date2)` | 営業日数を計算（土日を除く） | `WorkDaysBetween('2026-08-01','2026-08-07')=5` |
| `QuarterOf(date)` | 四半期を取る（1~4） | `QuarterOf('2026-08-03')=3` |
| `RocDateOf(date)` | 民国暦の日付文字列 YYYYY/MM/DD | `RocDateOf('2026-08-03')='115/08/03'` |
| `RocDateTimeOf(date)` | 民国暦の日付時刻文字列 YYY/MM/DD HH:MM:SS | `RocDateTimeOf('2026-08-03 14:30:00')='115/08/03 14:30:00'` |
| `IsWeekEnd(date)` | 土曜または日曜かどうか | `IsWeekEnd('2026-08-01')=True` |
| `IsWeekDay(date)` | 平日（月曜~金曜）かどうか | `IsWeekDay('2026-08-03')=True` |
| `NextWeekDay(date, dow)` | date から次の指定した曜日を探す（dow=1 Mon..7 Sun） | `NextWeekDay('2026-08-03',5)=2026-08-07（次の金曜日）` |
| `PrevWeekDay(date, dow)` | date から前の指定した曜日を探す | `PrevWeekDay('2026-08-03',5)=2026-07-31（前の金曜日）` |
| `EomDate(year, month)` | 指定した年月の最終日 | `EomDate(2026,2)=2026-02-28` |
| `BomDate(year, month)` | 指定した年月の初日 | `BomDate(2026,8)=2026-08-01` |
| `AddWorkDays(date, n)` | n 営業日を加える（土日を飛ばす） | `AddWorkDays('2026-08-03',5)=2026-08-10` |
| `YearFraction(date1, date2)` | 2 つの日付の間の年数（Actual/365） | `YearFraction('2026-01-01','2026-07-01')=0.4959` |
| `CalcAge(birthdate, asofdate)` | 誕生日から満年齢を計算 | `CalcAge('2000-08-03','2026-08-03')=26` |
| `FiscalQuarter(date, fiscalStartMonth)` | 会計四半期（会計年度の開始月を指定） | `FiscalQuarter('2026-08-03',7)=1` |
| `FiscalYear(date, fiscalStartMonth)` | 会計年度 | `FiscalYear('2026-08-03',7)=2026` |
| `DayNameOf(date)` | 曜日の中国語名 | `DayNameOf('2026-08-03')='星期一'（月曜日）` |
| `MonthNameOf(date)` | 月の中国語名 | `MonthNameOf('2026-08-03')='八月'（8 月）` |
| `DateSerialValue(y, m, d)` | 年月日から TDateTime を組み立てる | `DateSerialValue(2026,8,3)=2026-08-03` |
| `TimeSerialValue(h, m, s)` | 時分秒から TDateTime を組み立てる | `TimeSerialValue(14,30,0)=14:30:00` |
| `CurrentDateValue` | 現在の日付時刻。簡略化した実装：システムで読める日付時刻の文字列を返す（タイムゾーンのオフセット情報を含む。引数なし） | `CurrentDateValue='20260803143000'` |
| `WhenCompiled` | プログラムのコンパイル時刻。簡略化した実装：CURRENT_DATE と同じ出どころの時刻文字列を返す（引数なし。本フレームワークはインタープリター実行のため、実際のコンパイル時刻のタイムスタンプはない） | `WhenCompiled='20260803143000'` |
| `DateOfInteger(n)` | COBOL の内部日付整数を YYYYMMDD に変換（COBOL の内部整数 = Delphi の日付シリアル値 + 109205。テストで検証済み） | `DateOfInteger(155442)=20260803` |
| `IntegerOfDate(n)` | YYYYMMDD を COBOL の内部日付整数に変換（= Delphi の日付シリアル値 + 109205。テストで検証済み） | `IntegerOfDate(20260803)=155442` |
| `DayOfInteger(n)` | COBOL の内部日付整数を YYYYDDD（通日形式）に変換（テストで検証済み） | `DayOfInteger(155442)=2026215` |
| `IntegerOfDay(n)` | YYYYDDD を COBOL の内部日付整数に変換（テストで検証済み） | `IntegerOfDay(2026215)=155442` |
| `SecondsPastMidnight` | 今日の午前 0 時からの秒数（引数なし） | `SecondsPastMidnight=52200（14:30:00 を表す）` |
| `CombinedDateTime(date, secs)` | COBOL の内部日付整数と秒数を合わせて総秒数にする（= date × 86400 + secs。テストで検証済み。小数形式の日付時刻値ではない） | `CombinedDateTime(155442,52200)=13430241000` |
| `DateToYyyymmdd(yymmdd [, pivot])` | 6 桁の日付（YYMMDD）をピボット年に基づいて 8 桁の YYYYMMDD に変換。第 2 引数が pivot で、省略または 0 なら既定は 50（YY≤50 は 20YY、それ以外は 19YY とみなす） | `DateToYyyymmdd(260803,50)=20260803` |
| `YearToYyyy(yy [, pivot])` | 2 桁の年をピボット年に基づいて 4 桁の年に変換。第 2 引数が pivot で、省略または 0 なら既定は 50 | `YearToYyyy(26,50)=2026` |
| `TestDateYyyymmdd(n)` | YYYYMMDD が正しい日付か（EncodeDate が受け付けるか）を検証。0 = 有効、1 = 無効 | `TestDateYyyymmdd(20260803)=0` |
| `TestDayYyyyddd(n)` | YYYYDDD が正しい年と通日か（年が 1601 以上で、通日がその年の日数の範囲内か）を検証。0 = 有効、1 = 無効 | `TestDayYyyyddd(2026215)=0` |

---

### B.6　条件と論理

| 関数 | 説明 | 例 |
|---|---|---|
| `IF(cnd,t,f)` | 条件式：cnd が真なら t、そうでなければ f を返す（IIF と同じ） | `IF(5>3,'Yes','No')=Yes` |
| `TRUE` | ブール値の真の定数 | `TRUE=True` |
| `FALSE` | ブール値の偽の定数 | `FALSE=False` |
| `ISNULL(x)` | NULL かどうか | `ISNULL(NULL())=True` |
| `ISNUMBER(x)` | 数値型かどうか | `ISNUMBER('123')=True` |
| `ISTEXT(x)` | 文字列型かどうか | `ISTEXT('abc')=True` |
| `ISEVEN(x)` | 偶数かどうか | `ISEVEN(4)=True` |
| `ISODD(x)` | 奇数かどうか | `ISODD(3)=True` |
| `VarIsNull(x)` | Variant が Null かどうか | `VarIsNull(NULL())=True` |
| `Assigned(x)` | オブジェクトが割り当て済みかどうか | `Assigned(obj)=True（obj のインスタンスが作られている場合）` |
| `TYPE(x)` | 型コードを返す（varString/varInteger/varDouble/varUString。テストで検証して修正済み） | `TYPE(123)='varInteger'` |
| `DEFINE(name)` | 識別子が定義済みかどうか | `DEFINE('v1')=True（v1 が宣言済みの場合）` |
| `NvlValue(value, default)` | value が Null なら default を返す（Oracle NVL） | `NvlValue(NULL,'N/A')='N/A'` |
| `Nvl2Value(value, notNullVal, nullVal)` | Oracle NVL2 | `Nvl2Value(5,'値あり','値なし')='値あり'` |
| `CoalesceValue(v1, v2, …)` | 最初の Null でない値を返す（可変長引数版） | `CoalesceValue([NULL,NULL,3])=3` |
| `ToIntSafe(value)` | 安全に整数へ変換。失敗すると 0 を返す | `ToIntSafe('abc')=0` |
| `ToFloatSafe(value)` | 安全に浮動小数点数へ変換。失敗すると 0 を返す | `ToFloatSafe('3.14')=3.14` |
| `ToDateSafe(value)` | 安全に日付へ変換。失敗すると Null を返す | `ToDateSafe('2026-08-03')=2026-08-03` |
| `TypeNameOf(value)` | 型名の文字列を返す | `TypeNameOf(123)='Integer'` |
| `SwitchValue(key, val1, res1, val2, res2, … [, default])` | key をペアで現れる (値, 結果) と順に照合し、一致すれば対応する結果を返す。一致しなかった場合、末尾に 1 つ余分な引数があればその既定値を、なければ Null を返す（Oracle DECODE の意味） | `SwitchValue([2,1,'One',2,'Two',3,'Three'])='Two'` |
| `DecodeValue(v1, v2, …)` | Oracle DECODE の意味（SwitchValue と同じ） | `DecodeValue([2,1,'One',2,'Two','Other'])='Two'` |

---

### B.7　ローカライズ

| 関数 | 説明 | 例 |
|---|---|---|
| `LEADBYTE(s,p)` | 2 バイト文字の先頭バイトかどうかを判定 | `LEADBYTE('中文',1)=True` |
| `LocaleDate(n)` | 簡略化した実装：COBOL の内部日付整数をシステムの地域形式の日付文字列に変換（locale 引数の指定には未対応） | `LocaleDate(155442)='2026/8/3'（例示の値。実際の形式はシステムの地域設定による）` |
| `LocaleTime(secs)` | 簡略化した実装：秒数をシステムの地域形式の時刻文字列に変換（locale 引数の指定には未対応） | `LocaleTime(52200)='下午 02:30:00'（中国語ロケールでの午後 2:30:00）` |
| `LocaleCompare(s1, s2)` | 地域の規則で文字列を比較し、'<'、'='、'>' を返す（実装上は STANDARD_COMPARE と同じ序数比較で、地域の並べ替え規則は適用しない） | `LocaleCompare('abc','abd')='<'` |
| `CurrencySymbol` | 現在の地域の通貨記号（引数なし） | `CurrencySymbol='NT$'` |
| `MonetaryDecimalPoint` | 通貨の小数点記号（引数なし） | `MonetaryDecimalPoint='.'` |
| `MonetaryThousandsSeparator` | 通貨の桁区切り記号（引数なし） | `MonetaryThousandsSeparator=','` |
| `NumericDecimalPoint` | 数値の小数点記号（引数なし） | `NumericDecimalPoint='.'` |
| `NumericThousandsSeparator` | 数値の桁区切り記号（引数なし） | `NumericThousandsSeparator=','` |

---

### B.8　乱数

| 関数 | 説明 | 例 |
|---|---|---|
| `RAND(a,b)` | a~b の間のランダムな整数を返す | `RAND(1,10)=7（実行するたびに結果はランダム）` |

---

### B.9　暗号化とセキュリティ

| 関数 | 説明 | 例 |
|---|---|---|
| `ENCRYPT(s,pwd)` | 文字列を暗号化（XOR、16 進文字列を返す。同じ s/pwd なら結果は固定で再現可能。ランダムなソルトは付かない） | `ENCRYPT('AB','key')='2A27'` |
| `DECRYPT(s,pwd)` | 文字列を復号（ENCRYPT の結果を元に戻す） | `DECRYPT('2A27','key')='AB'` |
| `MD5(s)` | 文字列の MD5 ハッシュ値を計算 | `MD5('Wapform')='A2269E58A973F7C621427BCC8BD3BBBA'` |
| `HashOf(str)` | 簡易な djb2 ハッシュ（32 ビット符号なし整数、16 進文字列を返す。テストで検証済み） | `HashOf('Wapform')='17333661'` |
| `CheckSumOf(str)` | 簡易な XOR チェックサム（0~255 の整数を返す） | `CheckSumOf('AB')=3` |

---

### B.10　システムと環境

| 関数 | 説明 | 例 |
|---|---|---|
| `GetUrlContent(url)` | URL の内容を取得 | `GetUrlContent('https://example.com')=<html>...</html>` |
| `GetMacPhysicalAddress` | MAC の物理アドレスを取得 | `GetMacPhysicalAddress=00-1A-2B-3C-4D-5E` |
| `GetPhysMem` | 物理メモリのサイズを取得 | `GetPhysMem=16384（MB、実際のマシンによる）` |
| `GetFreeRes` | 利用可能なリソースを取得 | `GetFreeRes=8192（実際のマシンによる）` |
| `DBX` | 多層アーキテクチャのフラグ | `DBX=True（多層アーキテクチャのモードのとき）` |
| `Beep` | システムのビープ音 | `Beep=（システムのビープ音を鳴らし、戻り値はない）` |
| `loCaseInsensitive` | 検索オプション：大文字・小文字を区別しない | `loCaseInsensitive=1（検索オプションのフラグ値）` |
| `loPartialKey` | 検索オプション：部分キー | `loPartialKey=2（検索オプションのフラグ値）` |
| `NBSP` | 改行しない空白 | `NBSP=&nbsp;` |
| `NULL` | 空値の定数 | `NULL=Null` |
| `IMG(name,size)` | 画像パスの処理 | `IMG('logo.png',32)=<img src="logo.png" width="32">` |
| `NewGuidStr` | 新しい GUID 文字列 xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx を生成 | `NewGuidStr='550e8400-e29b-41d4-a716-446655440000'` |
| `RandomStrOf(len, chars)` | chars の文字集合からランダムに len 文字を取って文字列を作る。chars が空なら既定で英大文字・小文字＋数字を使う | `RandomStrOf(6,'')='aZ3kQ9'（実行するたびに結果はランダム）` |
| `ToHexStr(n)` | 整数を 16 進文字列に変換（埋めなし） | `ToHexStr(255)='FF'` |
| `FromHex(str)` | 16 進文字列を整数に変換 | `FromHex('FF')=255` |
| `ToBinary(n, width)` | 整数を 2 進文字列に変換 | `ToBinary(5,8)='00000101'` |
| `FromBinary(str)` | 2 進文字列を整数に変換 | `FromBinary('101')=5` |
| `BitOrValue(a, b)` | ビット OR | `BitOrValue(5,3)=7` |
| `BitAndValue(a, b)` | ビット AND | `BitAndValue(5,3)=1` |
| `BitXorValue(a, b)` | ビット XOR | `BitXorValue(5,3)=6` |
| `BitNotValue(a)` | ビット NOT（32 ビット） | `BitNotValue(0)=-1` |
| `BitShiftLeft(a, n)` | n ビット左シフト | `BitShiftLeft(1,4)=16` |
| `BitShiftRight(a, n)` | n ビット右シフト | `BitShiftRight(16,4)=1` |
| `ByteSizeOf(n)` | n ビットを格納するのに必要なバイト数を返す | `ByteSizeOf(10)=2` |
| `BooleanOfInteger(n, len)` | 整数を BOOLEAN のビット文字列に変換。引数は (整数値, ビット幅) で、上位から下位へ '0'/'1' を出力 | `BooleanOfInteger(5,8)='00000101'` |
| `IntegerOfBoolean(s)` | BOOLEAN のビット文字列（'0'/'1' で構成）を整数に変換 | `IntegerOfBoolean('101')=5` |
| `StandardCompare(s1, s2)` | 標準の文字列比較（大文字・小文字を区別する序数比較）。'<'、'='、'>' を返す | `StandardCompare('abc','abd')='<'` |

---

### B.11　パス処理

| 関数 | 説明 | 例 |
|---|---|---|
| `ExtractFileDir(s)` | ディレクトリのパスを得る | `ExtractFileDir('C:\App\data.txt')=C:\App` |
| `ExtractFileDrive(s)` | ドライブ文字を得る | `ExtractFileDrive('C:\App\data.txt')=C:` |
| `ExtractFileExt(s)` | 拡張子を得る | `ExtractFileExt('data.txt')=.txt` |
| `ExtractFileName(s)` | ファイル名を得る（拡張子付き） | `ExtractFileName('C:\App\data.txt')=data.txt` |
| `ExtractFileNameNoExt(s)` | ファイル名を得る（拡張子なし） | `ExtractFileNameNoExt('C:\App\data.txt')=data` |
| `ExtractFilePath(s)` | パス全体を得る | `ExtractFilePath('C:\App\data.txt')=C:\App\` |

---

### B.12　動的変数と配列

| 関数 | 説明 | 例 |
|---|---|---|
| `var(name,val)` | 変数を動的に設定 | `var('x',10)=10（変数 x=10 を設定）` |
| `inc(name,val)` | 変数を増やす | `inc('x',1)=11（x を 1 増やした後の値）` |
| `dec(name,val)` | 変数を減らす | `dec('x',1)=10（x を 1 減らした後の値）` |
| `ARRAY(s)` | 文字列を空白で分割し、配列リテラル風の表示文字列を作る（実際のソースコードの動作とテストで検証して説明を修正済み） | `ARRAY('a b c')='[''a'',''b'',''c'']'` |
| `HIGH(x)` | 配列の上限 | `HIGH(arr)=9（配列のサイズが 10 なら上限のインデックスは 9）` |
| `LOW(x)` | 配列の下限 | `LOW(arr)=0（配列の下限のインデックス。通常は 0）` |
| `ArrayJoin(values, delim)` | 複数の値を delim でつないで文字列にする。最後の引数が delim | `ArrayJoin([1,2,3,','])='1,2,3'` |
| `ArrayMax(values)` | 複数の数値の最大値（可変長引数） | `ArrayMax([3,7,2])=7` |
| `ArrayMin(values)` | 複数の数値の最小値（可変長引数） | `ArrayMin([3,7,2])=2` |
| `ArraySum(values)` | 複数の数値の合計（可変長引数） | `ArraySum([1,2,3])=6` |
| `ArrayAverage(values)` | 複数の数値の平均（可変長引数） | `ArrayAverage([1,2,3])=2` |
| `ArrayContains(values, target)` | target が values の中にあるかを確認。最後の引数が target | `ArrayContains([1,2,3,2])=True` |
| `ArrayUnique(values)` | 重複した値を取り除き、最初に現れたものを残す。カンマでつないで返す | `ArrayUnique([1,2,2,3])='1,2,3'` |
| `ChooseValue(index, values)` | インデックス（1 始まり）でリストから値を選ぶ。index が最初の引数 | `ChooseValue([2,'A','B','C'])='B'` |

---

---

---

### B.13　財務関数

| 関数 | 説明 | 例 |
|---|---|---|
| `PaymentValue(rate, nper, pv)` | 各期の元利均等返済額（ローン） | `PaymentValue(0.005,360,-300000)=1798.65157545826` |
| `PresentValueOf(rate, nper, pmt)` | 現在価値（既知の定額年金から逆算） | `PresentValueOf(0.005,360,-1798.65157545826)=300000` |
| `FutureValue(rate, nper, pmt, pv)` | 将来価値 | `FutureValue(0.005,12,-100,0)=1233.55623728999` |
| `NumOfPeriods(rate, pmt, pv)` | ローンの完済に必要な期数 | `NumOfPeriods(0.005,-1798.65,300000)=360` |
| `RateOf(nper, pmt, pv)` | 1 期あたりの利率（ニュートン・ラフソン法、最大 100 回） | `RateOf(360,-1798.65,300000)=0.005` |
| `InterestPmt(rate, per, nper, pv)` | 第 per 期の利息部分 | `InterestPmt(0.005,1,360,-300000)=1500` |
| `PrincipalPmt(rate, per, nper, pv)` | 第 per 期の元本部分 | `PrincipalPmt(0.005,1,360,-300000)=298.651575458257` |
| `CumInterestPmt(rate, nper, pv, startPeriod [, endPeriod])` | startPeriod から endPeriod までの累計利息を計算。第 5 引数（endPeriod）を省略すると nper まで計算 | `CumInterestPmt([0.005,360,-300000,1,12])=17899.78376866893` |

---

### B.14　その他の組み込み関数（今回の追加テストでカバー）

> この節に収録した関数は、これまで第 6 章／元の付録の完全な例に含まれていなかったもので、ソースコードを 1 つずつ確認し、
テストを追加したうえでここに加えました。確認の過程で一部の関数のソースの実装に誤りが見つかり、あわせて修正しました
（詳しくは各行の「説明」欄の ⚠️ を参照）。修正内容は `myexp.pas` にも反映済みです。

| 関数 | 説明 | 例 |
|---|---|---|
| `CHAR(n)` | 整数を文字に変換 | `CHAR(65)='A'` |
| `COLOR2HEX(color)` | 色の値を 16 進のカラーコード文字列に変換（ColorToHex と同じ。Delphi の TColor は内部で BGR として格納） | `COLOR2HEX(255)='FF0000'` |
| `DAYOFMONTH(d)` | 日付の「日」を取る（DAY と同じ） | `DAYOFMONTH('2026-08-03')=3` |
| `DEL(s,index,count)` | 文字列の指定位置・指定長の部分文字列を削除 | `DEL('Hello',2,3)='Ho'` |
| `DELB(s,index,count)` | DEL と同じ（Byte 版） | `DELB('Hello',2,3)='Ho'` |
| `FIND(substr,s)` | 部分文字列の位置を探す（1 始まり）。見つからなければ 0 を返す | `FIND('ll','Hello')=3` |
| `FINDB(substr,s)` | FIND と同じ（Byte 版） | `FINDB('ll','Hello')=3` |
| `FLOAT2STR(v)` | 浮動小数点数を文字列に変換 | `FLOAT2STR(3.14)='3.14'` |
| `HEX2COLOR(hex)` | 16 進のカラーコード文字列を色の値に変換（HexToColor と同じ。Delphi の TColor は内部で BGR として格納） | `HEX2COLOR('0000FF')=16711680` |
| `HEX2INT(hex)` | 16 進文字列を整数に変換。⚠️ 元のソースのループはインデックス 0（有効な文字ではない）から始まっていたため、1 から始まるよう修正済み | `HEX2INT('FF')=255` |
| `HEX2STR(hex)` | 16 進文字列を通常の文字列に変換 | `HEX2STR('48656C6C6F')='Hello'` |
| `IIF(cond,t,f)` | 条件式（IF と同じ） | `IIF(1=1,'Yes','No')='Yes'` |
| `INS(substr,s,index)` | 文字列の指定位置に部分文字列を挿入 | `INS('XY','Hello',2)='HXYello'` |
| `INSB(substr,s,index)` | INS と同じ（Byte 版） | `INSB('XY','Hello',2)='HXYello'` |
| `INT2HEX(n,digits)` | 整数を 16 進文字列に変換 | `INT2HEX(255,4)='00FF'` |
| `INT2STR(n)` | 整数を文字列に変換 | `INT2STR(123)='123'` |
| `LENB(s)` | 文字列の長さ（Byte 版） | `LENB('Hello')=5` |
| `LENGTH(s)` | 文字列の長さ | `LENGTH('Hello')=5` |
| `MIDB(s,index,count)` | 部分文字列を取る（Byte 版、バイト単位、1 始まり） | `MIDB('Hello',2,3)='ell'` |
| `NTIER` | DBX と同じ（多層の接続モードかどうか） | `NTIER=False` |
| `Odd(n)` | 奇数かどうか | `Odd(3)=True` |
| `Ord(x)` | 文字または整数の序数値 | `Ord(65)=65` |
| `REPLACEB(s,old,new)` | 出現するすべての部分文字列を置換（Byte 版） | `REPLACEB('hello','l','L')='heLLo'` |
| `ROUNDTO(x,digits)` | 小数点以下 digits 桁に四捨五入 | `ROUNDTO(3.14159,2)=3.14` |
| `SQR(x)` | 2 乗 | `SQR(7)=49` |
| `STR2DATE(s)` | 文字列を日付に変換 | `STR2DATE('2026-08-03')=46237` |
| `STR2DATETIME(s)` | 文字列を日付時刻に変換 | `STR2DATETIME('2026-08-03 14:30:00')=46237.6041666667` |
| `STR2FLOAT(s)` | 文字列を浮動小数点数に変換 | `STR2FLOAT('3.14')=3.14` |
| `STR2HEX(s)` | 通常の文字列を 16 進文字列に変換 | `STR2HEX('Hello')='48656C6C6F'` |
| `STR2INT(s)` | 文字列を整数に変換 | `STR2INT('123')=123` |
| `STR2TIME(s)` | 文字列を時刻に変換 | `STR2TIME('14:30:00')=0.604166666666667` |
| `UPPERA(s)` | 大文字に変換（Ansi 版） | `UPPERA('abc')='ABC'` |
| `VALUE(s)` | VAL と同じ | `VALUE('3.14')=3.14` |
| `VARTYPE(v)` | 型名の文字列を返す（TYPE と同じ） | `VARTYPE(123)='varInteger'` |

---

### B.15　その他の組み込み関数（自動テストに不向き）

> 以下の関数は `myexp.pas` に存在し通常どおり呼び出せますが、それぞれに挙げた理由
（ランダム、システム／ネットワークの状態に依存、実行時の時刻に依存、ローカライズされた形式が一定でない、意味が不明確など）により、
固定の期待値を持つ自動テストには向かないため、`function.wml` には収録していません。

| 関数 | 説明 | テストしない理由 |
|---|---|---|
| `CPU` | （ソースコードに対応する登録が見つからない／未使用） | この関数自体は意味のある戻り値を生まない（システム音／内部のツール関数）ため、等値比較のテストに向かない |
| `DATE` | 現在の日付（引数なし、実行日によって変わる） | 結果は実行時のシステムの日付／時刻によって決まり、固定値ではないため期待値を書けない |
| `DATE2STR(d)` | 日付を文字列に変換 | 出力形式はシステムの地域設定（Locale）によって決まり、環境によって文字列の形式が一致する保証がないため、厳密な比較テストには含めない |
| `DATETIME2STR(d)` | 日付時刻を文字列に変換 | 出力形式はシステムの地域設定（Locale）によって決まり、環境によって文字列の形式が一致する保証がないため、厳密な比較テストには含めない |
| `RANDOM(lo,hi)` | [lo,hi) のランダムな整数 | ランダム関数で、比較できる固定の期待値がない |
| `RANDOMRANGE(lo,hi)` | [lo,hi) のランダムな整数 | ランダム関数で、比較できる固定の期待値がない |
| `RANDRANGE(lo,hi)` | [lo,hi) のランダムな整数 | ランダム関数で、比較できる固定の期待値がない |
| `TIME2STR(t)` | 時刻を文字列に変換 | 出力形式はシステムの地域設定（Locale）によって決まり、環境によって文字列の形式が一致する保証がないため、厳密な比較テストには含めない |
| `getpropstr(a,b)` | （unigui 関連の内部関数。意味は非公開） | unigui プラットフォーム関連の内部関数で、意味を外部に公開していないため、当面テストに含めない |
| `setpropstr(a,b,c)` | （unigui 関連の内部関数。意味は非公開） | unigui プラットフォーム関連の内部関数で、意味を外部に公開していないため、当面テストに含めない |

---

## 付録 C　Flutter 式エンジンの違い

WapForm for Flutter の式は `wapform_expression.dart`（`WapEvaluator`）が評価します。関数名は付録 B と同じですが、次のような違いがあります。この付録の結果はすべて Dart エンジンを実際に実行して得たものです。

### C.1　文法と型

| 項目 | Windows／Web | Flutter |
|---|---|---|
| `AND`／`OR` の両側の比較 | 括弧は省略可 | **括弧が必要**：`(qty>0) AND (price<100)`。括弧がないと `Invalid end token` が報告される |
| 数値演算 | Variant | 整数どうしの `+`、`-`、`*` は整数、それ以外（`/` を含む）は浮動小数点数 |
| 配列のインデックス | 宣言どおり | 常に 0 から。`[1..n]` は n+1 個の要素を作り、`LOW()` は 0 |
| 配列の上限を超える書き込み | エラー | 自動で延長（`null` で埋める） |
| 文字列中の `$` | — | Dart のコードでは raw string `r"..."` で書く。そうしないと `$` が先に Dart で補間される |
| `$(PAGE)` | レポートエンジンが自動で設定 | `PAGEPREFIX` で自分で設定する必要がある（7.6 節） |
| `request.*`／`session.*` | Web 環境のオブジェクト | 存在しない。必要なら `_ev.setVar("request.xxx", 値)` で自分で入れる |

### C.2　日付シリアル値を返す関数

次の関数は Flutter では「1899-12-30 からの日数」（小数部分は時刻）を返します。大小の比較や引き算には使えますが、現在のところ `DateToStr()`、`FORMATDATETIME()` で文字に戻すことはできません。日付の文字列が必要な場合は、`DATEADD`、`DATESTART`、`DATEEND`、`DATESERIAL`、`TODAY` など日付を返す関数を使ってください。

| 関数 | 例 | Flutter での結果 |
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

### C.3　結果が Windows 版と異なる関数

次の関数は呼び出せますが、結果が付録 B の Windows 版と一致しません。使う前にテストしてください：

| 関数 | 付録 B の例（Windows） | Flutter での結果 |
|---|---|---|
| `LENA(s)` | `LENA('中文')=6（UTF-8 では 1 文字 3 byte）` | `2` |
| `AnsiLength(s)` | `AnsiLength('中文')=4（Big5 では 1 文字 2 byte）` | `2` |
| `REPLACEAT(s,p,new)` | `REPLACEAT('Hello',1,'J')=Jello` | `Hello` |
| `INSERT(s,p,n,new)` | `INSERT('Hllo',2,0,'e')=Hello` | `ERROR` |
| `INSA(s,p,new)` | `INSA('Hllo',2,'e')=Hello` | `Hllo2` |
| `AnsiInsert(s,p,new)` | `AnsiInsert('Hllo',2,'e')=Hello` | `Hllo2` |
| `CODE(s)` | `CODE('001-ABC')=001（データ形式による）` | `（空文字列）` |
| `NAME(s)` | `NAME('001-ABC')=ABC（データ形式による）` | `（空文字列）` |
| `FORMAT(fmt,x)` | `FORMAT('0.00',3.5)=3.50` | `0.00` |
| `LIKE(s,pat)` | `LIKE('Hello','H*o')=True` | `H` |
| `ANSI(s)` | `ANSI('中文')=中文（Big5 エンコードのバイト列に変換）` | `中文` |
| `UTF8(s)` | `UTF8('中文')=中文（UTF-8 エンコードのバイト列に変換）` | `中文` |
| `HTML(s)` | `HTML('<b>')=&lt;b&gt;` | `<b><br/>` |
| `EllipsisStr(str, maxLen)` | `EllipsisStr('HelloWorld',5)='Hello...'` | `He...` |
| `HexToColor(s)` | `HexToColor('FF0000')=16711680（赤）` | `255` |
| `ColorToHex(n)` | `ColorToHex(16711680)=FF0000` | `0000FF` |
| `HOUR(d)` | `HOUR('14:30:00')=14` | `0` |
| `MINUTE(d)` | `MINUTE('14:30:00')=30` | `0` |
| `TimeToStr(t)` | `TimeToStr('14:30:00')=下午 02:30:00（中国語ロケールでの午後 2:30:00）` | `（空文字列）` |
| `MyDate(d)` | `MyDate('2026-08-03')=115/08/03` | `2026-08-03` |
| `MyDateTime(d)` | `MyDateTime('2026-08-03 14:30:00')=115/08/03 14:30:00` | `2026-08-03 14:30:00` |
| `ISNULL(x)` | `ISNULL(NULL())=True` | `ERROR` |
| `VarIsNull(x)` | `VarIsNull(NULL())=True` | `ERROR` |
| `LEADBYTE(s,p)` | `LEADBYTE('中文',1)=True` | `false` |
| `IMG(name,size)` | `IMG('logo.png',32)=<img src="logo.png" width="32">` | `ERROR` |

### C.4　Flutter で対応していない関数

次の関数は Flutter では案内の文字列を返すだけです：

- `GetUrlContent(url)`
- `GetMacPhysicalAddress`
- `GetPhysMem`
- `GetFreeRes`

Web ページの内容を取得するには Dart の `http` パッケージを、ローカルのハードウェア情報には対応するプラットフォームの Flutter パッケージを使ってください。

### C.5　Flutter が追加で提供する関数

次の関数は Dart エンジンにだけ登録されており、`eval()`、`setvar()`、`$(...)` の中で呼び出せます。「引数」欄は引数の個数です。

| 関数 | 引数 | 説明 |
|---|---|---|
| `AGE` | 2 | 誕生日から指定した日付までの満年齢を計算 |
| `ArcCos` | 1 | 逆余弦（ACOS と同じ） |
| `ArcSin` | 1 | 逆正弦（ASIN と同じ） |
| `ArcTan` | 1 | 逆正接（ATAN と同じ） |
| `ARRAVG` | 可変 | 複数の値の平均 |
| `ARRCONTAINS` | 可変 | 最後の引数が前の値の中に現れるか |
| `ARRJOIN` | 可変 | 最後の引数を区切り文字として前の値をつなぐ |
| `ARRMAX` | 可変 | 複数の値の最大値 |
| `ARRMIN` | 可変 | 複数の値の最小値 |
| `ARRSUM` | 可変 | 複数の値の合計 |
| `ARRUNIQ` | 可変 | 重複を取り除き、カンマでつないで返す |
| `As10` | 1 | ブール値 → '1'／'0' |
| `AsISO` | 1 | ISO 8601 の日付文字列 |
| `AsOct` | 1 | 整数 → 8 進文字列 |
| `AsPct` | 2 | パーセント文字列（小数 d 桁） |
| `AsRDate` | 1 | 民国暦の日付文字列 |
| `AsRDateTime` | 1 | 民国暦の日付時刻文字列 |
| `AsSci` | 2 | 指数表記の文字列（例 1.23E+04） |
| `AsString` | 1 | 任意の値 → 文字列 |
| `AsTF` | 1 | ブール値 → 'T'／'F' |
| `AsTime` | 1 | 任意の値 → 時刻 |
| `AsYN` | 1 | ブール値 → 'Y'／'N' |
| `BDATE` | 1 | 日付の変換（互換用） |
| `BETWEEN` | 3 | 値が [lo, hi] の範囲にあるか |
| `BITAND` | 2 | ビット AND |
| `BITNOT` | 1 | ビット NOT |
| `BITOR` | 2 | ビット OR |
| `BITSHL` | 2 | n ビット左シフト |
| `BITSHR` | 2 | n ビット右シフト |
| `BITXOR` | 2 | ビット XOR |
| `BOOLEAN_OF_INTEGER` | 2 | 整数 → ビット文字列 |
| `BR2CRLF` | 1 | <br/> → 改行 |
| `BYTESIZE` | 1 | n ビットを格納するのに必要なバイト数 |
| `BYTE_LENGTH` | 1 | 文字列のバイト長 |
| `CBRT` | 1 | 立方根 |
| `CELL` | 2 | クロス集計表のセルの値（互換用） |
| `CHECKSUM` | 1 | XOR チェックサム |
| `CHOOSE` | 可変 | インデックス（1 始まり）でリストから値を取る |
| `CLAMP` | 3 | 値を [lo, hi] の範囲に制限 |
| `COALESCE` | 可変 | 最初の Null でない値を返す（可変長引数） |
| `COMBINED_DATETIME` | 2 | 日付整数と秒数を合わせて日付時刻にする |
| `COMMAFMT` | 1 | 整数に桁区切りを付ける |
| `CONCATENATE` | 可変 | すべての引数を連結 |
| `CONTAINS` | 2 | 文字列が部分文字列を含むか |
| `COPY` | 3 | 部分文字列を取る（Pascal の Copy と同じ） |
| `COPYB` | 3 | バイト単位で部分文字列を取る |
| `COUNTSTR` | 2 | 部分文字列の出現回数 |
| `CRLF2BR` | 1 | 改行 → <br/> |
| `CUMIPMT` | 可変 | 累計利息（期間 start～end） |
| `CURRENCY_SYMBOL` | 0 | 通貨記号 |
| `CURRENT_DATE` | 0 | 現在のタイムスタンプ文字列 yyyyMMddHHmmsscc+HHmm |
| `DATEADD` | 3 | 日付の加減算（unit：'D'／'M'／'Y'／'W'） |
| `DATEDIFF` | 3 | 2 つの日付の差（unit による） |
| `DATEEND` | 2 | 期間の終了日（unit：'M' 月末／'Y' 年末） |
| `DATESERIAL` | 3 | 年月日から日付を作る |
| `DATESTART` | 2 | 期間の開始日（unit：'M' 月初／'Y' 年初／'W' 月曜） |
| `DATE_OF_INTEGER` | 1 | 日付整数 → YYYYMMDD |
| `DATE_TO_YYYYMMDD` | 2 | YYMMDD をピボット年に基づいて YYYYMMDD に変換 |
| `DAYNAME` | 1 | 曜日名（中国語） |
| `DAY_OF_INTEGER` | 1 | 日付整数 → YYYYDDD |
| `DECODE` | 可変 | Oracle の DECODE に似る：値の対応で結果を返し、最後が既定値 |
| `DEG2RAD` | 1 | 度 → ラジアン |
| `E` | 0 | ネイピア数 e |
| `ELLIPSIS` | 2 | 切り詰めて '...' を付ける |
| `ENDSWITH` | 2 | 文字列が指定した接尾辞で終わるか |
| `EVEN` | 1 | n 以上の最小の偶数 |
| `EXP10` | 1 | 10 の x 乗 |
| `FIB` | 1 | n 番目のフィボナッチ数（0 始まり） |
| `FRACTION_PART` | 1 | 小数部分 |
| `FROMBIN` | 1 | 2 進文字列 → 整数 |
| `FV` | 4 | 将来価値 |
| `GCD` | 2 | 最大公約数 |
| `GEOMEAN` | 可変 | 幾何平均 |
| `GUID` | 0 | 新しい GUID 文字列を生成 |
| `HARMEAN` | 可変 | 調和平均 |
| `HASH` | 1 | 簡易な djb2 ハッシュ（32 ビット、16 進文字列） |
| `HIGHEST_ALGEBRAIC` | 1 | その型の最大値 |
| `HTMLDECODE` | 1 | HTML の特殊文字をデコード |
| `HTMLENCODE` | 1 | HTML の特殊文字をエンコード |
| `HYPOT` | 2 | 直角三角形の斜辺 sqrt(a²+b²) |
| `INDEXOF` | 3 | start（1 始まり）から部分文字列の位置を探す |
| `INTEGER` | 1 | 切り捨て（floor） |
| `INTEGER_OF_BOOLEAN` | 1 | ビット文字列 → 整数 |
| `INTEGER_OF_DATE` | 1 | YYYYMMDD → 日付整数 |
| `INTEGER_OF_DAY` | 1 | YYYYDDD → 日付整数 |
| `INTEGER_PART` | 1 | ゼロ方向へ切り捨てて整数化 |
| `IPMT` | 4 | 第 n 期の支払いのうち利息部分 |
| `IRR` | 可変 | 内部収益率（ニュートン法による反復） |
| `ISPRIME` | 1 | 素数かどうか |
| `JOIN` | 2 | 余分な空白を取り除いてから区切り文字でつなぐ |
| `last-month` | 0 | 先月の同じ日 |
| `last-night` | 0 | 昨日 |
| `last-week` | 0 | 先週の同じ日 |
| `last-year` | 0 | 昨年の同じ日 |
| `LASTINDEXOF` | 2 | 右から部分文字列の位置を探す（1 始まり） |
| `LCM` | 2 | 最小公倍数 |
| `LEADBYTEB` | 2 | 2 バイト文字の先頭バイトかどうか |
| `LERP` | 3 | 線形補間 a + (b-a)*t |
| `LOCALE_COMPARE` | 2 | 地域設定に従って比較し、'<'、'='、'>' を返す |
| `LOCALE_DATE` | 1 | 地域設定に従って日付を整形 |
| `LOCALE_TIME` | 1 | 地域設定に従って時刻を整形 |
| `LOCATE` | 2 | 部分文字列の位置 |
| `LOG10` | 1 | 10 を底とする対数 |
| `LOG2` | 1 | 2 を底とする対数 |
| `LOGN` | 2 | base を底とする対数 |
| `LOWERA` | 1 | 小文字に変換 |
| `LOWER_CASE` | 1 | 小文字に変換 |
| `LOWEST_ALGEBRAIC` | 1 | その型の最小値 |
| `LPAD` | 3 | 指定した文字で左側を埋めて len 幅にする |
| `MASK` | 3 | マスクで整形（プレースホルダー文字の既定は '#'） |
| `MEAN` | 可変 | 平均値 |
| `MEDIAN` | 可変 | 中央値 |
| `MIDRANGE` | 可変 | 最大値と最小値の平均 |
| `MOD` | 2 | 剰余（符号は除数と同じ） |
| `MONETARY_DECIMAL_POINT` | 0 | 通貨の小数点記号 |
| `MONETARY_THOUSANDS_SEPARATOR` | 0 | 通貨の桁区切り記号 |
| `MONTHNAME` | 1 | 月の名前（中国語） |
| `NEXTWDAY` | 2 | 日付から次の指定した曜日（1＝月曜…7＝日曜） |
| `NPER` | 3 | 支払い期数 |
| `NPV` | 可変 | 正味現在価値 |
| `NUMERIC_DECIMAL_POINT` | 0 | 数値の小数点記号 |
| `NUMERIC_THOUSANDS_SEPARATOR` | 0 | 数値の桁区切り記号 |
| `NUMFMT` | 2 | 数値の整形：桁区切りと小数桁数 |
| `NUMVAL_C` | 2 | 通貨記号を含む文字列 → 数値 |
| `NUMVAL_F` | 1 | 浮動小数点表記の文字列 → 数値 |
| `NVL` | 2 | 値が Null のとき既定値を返す |
| `NVL2` | 3 | Oracle の NVL2 に似る：Null でない場合と Null の場合でそれぞれ別の値を返す |
| `ORD_MAX` | 可変 | 最大値の位置（1 始まり） |
| `ORD_MIN` | 可変 | 最小値の位置（1 始まり） |
| `PADC` | 2 | 空白で埋めて len 幅の中央に揃える |
| `PADL` | 2 | 空白で左側を埋めて len 幅にする |
| `PADR` | 2 | 空白で右側を埋めて len 幅にする |
| `PERCENT` | 2 | 百分率の計算 |
| `PMT` | 3 | 各期の定額支払額 |
| `PPMT` | 4 | 第 n 期の支払いのうち元本部分 |
| `PRESENT_VALUE` | 可変 | 各期の金額の現在価値 |
| `PREVWDAY` | 2 | 日付より前の指定した曜日 |
| `PRODUCT` | 可変 | すべての値の積 |
| `PV` | 3 | 現在価値 |
| `QUARTER` | 1 | 四半期（1～4） |
| `QUARTILE` | 可変 | 四分位数（q＝1、2、3） |
| `RAD2DEG` | 1 | ラジアン → 度 |
| `RANDOMSTR` | 2 | 指定した長さのランダムな文字列を生成 |
| `RANGE` | 可変 | 最大値と最小値の差 |
| `RATE` | 3 | 1 期あたりの利率（ニュートン法による近似） |
| `RDATE` | 1 | 民国暦の日付文字列 YYY/MM/DD |
| `RDATETIME` | 1 | 民国暦の日付時刻文字列 YYY/MM/DD HH:MM:SS |
| `REM` | 2 | 剰余（符号は被除数と同じ） |
| `REPEAT` | 2 | 文字列を n 回繰り返す |
| `REVERSE` | 1 | 文字列を反転 |
| `ROUNDBANK` | 2 | 銀行型丸め（偶数丸め） |
| `RPAD` | 3 | 指定した文字で右側を埋めて len 幅にする |
| `SECONDS_PAST_MIDNIGHT` | 0 | 今日の経過秒数 |
| `SIGN` | 1 | 符号（-1、0、1） |
| `SLUGIFY` | 1 | URL のスラッグに変換 |
| `SPLIT` | 3 | 区切り文字で分割し、n 番目（1 始まり）を取る |
| `STANDARD_COMPARE` | 2 | 標準の比較。'<'、'='、'>' を返す |
| `STANDARD_DEVIATION` | 可変 | 標準偏差 |
| `STARTSWITH` | 2 | 文字列が指定した接頭辞で始まるか |
| `STORED_CHAR_LENGTH` | 1 | 末尾の空白を除いた長さ |
| `SUBSTITUTE` | 可変 | ペアの引数で順に文字列を置換 |
| `SUBSTITUTE_CASE` | 可変 | ペアの引数で置換（大文字・小文字を区別しない） |
| `SUM` | 可変 | 合計 |
| `SUMSQ` | 可変 | 平方和 |
| `SWITCH` | 可変 | 値の対応で結果を返し、最後が既定値 |
| `TEST_DATE_YYYYMMDD` | 1 | YYYYMMDD が有効か検査（0＝有効） |
| `TEST_DAY_YYYYDDD` | 1 | YYYYDDD が有効か検査（0＝有効） |
| `TEST_NUMVAL` | 1 | 文字列を数値に変換できるか検査（0＝可能） |
| `TEST_NUMVAL_C` | 2 | 通貨記号を含む文字列を数値に変換できるか検査 |
| `TEST_NUMVAL_F` | 1 | 浮動小数点表記の文字列を数値に変換できるか検査 |
| `TIMESERIAL` | 3 | 時分秒から時刻を作る |
| `TOBIN` | 2 | 整数 → 2 進文字列（width 桁） |
| `TODATE` | 1 | 安全に日付へ変換 |
| `TOFLOAT` | 1 | 安全に浮動小数点数へ変換 |
| `TOHEX` | 1 | 整数 → 16 進文字列 |
| `TOINT` | 1 | 安全に整数へ変換 |
| `TrimLeft` | 1 | 左側の空白を除去 |
| `TrimRight` | 1 | 右側の空白を除去 |
| `TYPENAME` | 1 | 値の型名 |
| `UNMASK` | 3 | マスクを取り除き、プレースホルダー位置の文字だけを残す |
| `UPPER_CASE` | 1 | 大文字に変換 |
| `URLENCODE` | 1 | URL のパーセントエンコード |
| `VARIANCE` | 可変 | 分散 |
| `WHEN_COMPILED` | 0 | CURRENT_DATE と同じ |
| `WORKDAYS` | 2 | 2 つの日付の間の営業日数（土曜・日曜を除く） |
| `WRAP` | 2 | width 文字ごとに改行を挿入 |
| `YEARFRAC` | 2 | 2 つの日付の間が 1 年に占める割合（Actual/365） |
| `YEAR_TO_YYYY` | 2 | 2 桁の年をピボット年に基づいて 4 桁に変換 |
| `ZFILL` | 2 | 整数の左側をゼロで埋めて width 桁にする |

## 索引

**alert** — 4-1, 6-2
**block** — 4-11（Web）, 7-2, 7-3
**bookmark pattern** — 4-14, A
**card** — 1-1, 2-1, 4-2
**CDATA** — 4-5
**chart** — 4-12（Web）
**datasource** — 1-2, 3-1, 4-4
**dbgrid** — 4-6
**dbquery** — 4-3
**dbtable** — 4-4
**DEFINE function** — 1-4, 5-9（Web）
**device attribute** — 2-1, 4-2, A
**dynamic WHERE** — 3-3, 3-7, A
**expression system** — 1-4, 5-1
**for loop** — 4-12（Web）
**function** — 4-12, 6-2
**go** — 4-12
**group / group change** — 4-16, 5-3
**if / elseif / else** — 4-13
**include** — 4-11（Web）, 7-2
**input** — 4-9
**invoke** — 4-14
**lookup attribute** — 3-4, 4-10
**mail** — 4-12（Web）, 7-5
**navigator** — 4-5
**nowap / wap** — 4-12（Web）
**oncalccellcolors** — 4-7, 6-4
**ondblclick** — 4-8, 6-4
**onevent** — 1-5, 4-8
**onnewrecord** — 4-8, A
**operator** — 4-10（Web）, 7-4
**page** — 4-16
**pagecontrol** — 4-11
**platform** — 4.5, 12.3, 16
**redirect** — 4-11（Web）, 3-8, 7-3
**report** — 4-16
**request.*** — 1-4, 5-4（Web）
**section** — 4-11（Web）
**select** — 4-11
**session** — 4-11（Web）, 3-8, 7-3
**setprop** — 4-13, 6-3
**setvar** — 4-13
**SUB card** — 3-6, 4-2
**switch** — 4-13
**tabsheet** — 4-11
**timer** — 4-12（Web）
**varblock** — 4-11（Web）
**while** — 4-14
**wml** — 2-1, 4-2

---

WapForm 完全技術マニュアル
著者：Neil Tsai
Copyright © 2026 敏弘資訊有限公司（Minhong Information Co., Ltd.）All rights reserved.
