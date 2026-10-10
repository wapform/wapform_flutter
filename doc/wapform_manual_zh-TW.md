# WapForm 完整技術手冊

---

WapForm 是企業應用的宣告式 XML 框架：一份 `.wml` 檔案同時驅動資料庫、渲染介面、產出報表，執行期直接生成 Windows 桌面應用、Web 網頁、Flutter App，並可匯出 COBOL 程式，延伸範圍涵蓋 IC 電子設計自動化（EDA）與本地端 AI Agent Cherith。沒有樣板程式碼，沒有框架汰換，換平台不必重寫——這套設計模式已在製造業 ERP、金融系統與電商平台的生產環境中驗證超過二十年。

**WapForm 的核心主張只有一個：描述「是什麼」，而不是「怎麼做」。** 開發者以 XML 宣告資料集、繫結欄位、定義事件與輸出格式，框架負責驅動資料庫、渲染介面、處理分頁與合計。同一份 `.wml` 檔案可以同時是輸入表單和分頁報表，不需切換語言，不需在 UI 框架與資料層之間搭橋。宣告式的力量在於：當業務規則改變，你只修改描述，其餘由框架推導。

### 四項核心優勢

**快還要快** — 官方案例中，一份多層次巢狀的生產報表（多維度分組，含自動分頁）以傳統命令式程式碼估計需數月開發，用 WapForm 數天內建置並上線，程式碼從數千行跨檔案邏輯收斂為一份數百行的 WML 宣告。不是問題少，而是修改速度快到讓測試不再令人恐懼。

**快速跨平台、快速跨領域** — 一次掌握宣告式語法，同一套思維即可覆蓋 Windows 桌面、Web 伺服器端、Flutter 行動裝置，乃至 IC 電子設計自動化（EDA）與 COBOL 大型主機。WapForm 不是某個平台的工具，而是一種可以跨越任何領域的**開發設計模式（Design Pattern）**。

**創新套表機制** — 內建觸發式模板系統，HTML 模板主導版面，程式只宣告內容區塊，報表套用邏輯與主程式徹底分離，帶來直覺且流暢的開發體驗。

**堅若磐石** — 模組化架構搭配嚴謹的資料邏輯驗證，確保企業級應用的穩定性與可擴充性，在真實的製造業 ERP、電商平台與金融系統中經過二十年驗證。

### WapForm 真正是什麼：定義一次，落地多次

資料來源、欄位、查找、事件、表單與報表，都在 WML 中被描述，而不是直接綁定在 Dart、Flutter 或其他特定語言上。因此：

> **WapForm 是應用程式的 Source of Truth。**

生成器負責把這份定義展開成目標平台程式碼，而 Runtime 與元件庫則提供程式實際運行的「落地層」。

### AI 的價值，不是自由產生程式碼

如果只是把既有桌面資料庫元件庫的原始碼交給 LLM，一個檔案一個檔案要求它翻譯成 Dart，即使能產生大量程式碼，也不代表能可靠地完成大型系統的移植。

真正困難的是行為一致性、API 對應、資料模型、事件模型，以及長期維護。

WapForm 採取的是不同的方法：

**WML Definition → Generator → Stable Runtime/API → Target Code**

AI 並不是被要求自由地「寫一個 App」，而是在已經明確定義的 WML 與穩定的目標 API 上，進行大量、機械式、可重複的程式展開。

這次 WapForm for Flutter 的移植，約以兩個月的 AI 輔助開發完成；相較於同等規模手動移植原先估計的六至十二個月，真正的差異並不只是 AI 寫程式比較快，而是：

> **先建立定義，再讓 AI 依照定義生成。**

因此，Flutter 的兩個月不是單純的 AI 開發速度展示，而是對這套「定義 → 生成 → Runtime → 執行」工程模式的一次實際驗證。

### 拿 Flutter 來說：不是元件移植，而是應用程式定義的第一次驗證

跨平台從來不是最大的成本，真正昂貴的是每換一個平台，就必須重新開發一次。

即使把桌面資料感知元件完整移植到 Flutter，擁有了熟悉的資料集、表格、導覽列、欄位與事件模型，開發者仍然要用 Dart 建立畫面、綁定資料、撰寫事件與商業邏輯。本質上，仍然是在另一個平台重新寫一套程式。

WapForm 解決的不是元件，而是應用程式的定義方式。

WML 是一種純文字、宣告式的應用程式定義語言。資料來源、欄位、查找、事件、表單與報表，都以「描述」的方式定義，而不是綁定在 Dart、Flutter 或任何特定平台上。因此，真正的開發流程變成：

> **定義一次，落地多次。**

WML 是唯一的應用程式定義；Generator 負責展開成目標平台程式碼；Runtime 則提供程式真正執行所需的元件與行為模型。以 Flutter 為例，`wapform_flutter` 這個 repository 就是 Flutter 的 Runtime——它不是另一套 Flutter UI Framework，而是 WapForm 資料集、運算式與報表模型在 Flutter 上的對應實作。WapForm 產生器生成的每一行 Dart，都以這套 API 為目標，因此同一份原本在 Windows 執行的 WML，可以不改定義，直接落地到 Flutter。這也是「寫十行 WML，就得到一個能執行的 Flutter 畫面」的原因，因為真正被重複利用的，不是程式碼，而是應用程式本身的定義（詳見第十六章）。

### 拿 Web 來說：觸發套表，版面與邏輯徹底分離

傳統 PHP／ASP 把判斷式直接寫在 HTML 裡，程式知道太多版面細節：改一個區塊要動程式，設計師沒辦法獨立改版面，系統一大，維護成本就跟著爆炸。

WapForm for Web 的核心是**觸發套表**：程式不寫 HTML，只宣告「在什麼條件下，觸發哪一個版面區塊」；HTML 全部放在套表檔裡，以 `<!-- 名稱.aa -->`／`<!-- 名稱.zz -->` 標出一個個具名區塊。

```xml
<card id="main" device="wapform.html">          <!-- device 指定套表檔 -->
  <setvar name="op" value="request.op"/>
  <block name="wapform.aa"/>                     <!-- 觸發：輸出外框開頭 -->
  <include name="header"/>                       <!-- 共用頁首，全站一份 -->
  <block name="onpage" cnd="op='page'"/>         <!-- 依條件觸發不同版型 -->
  <block name="onblog" cnd="op='blog'"/>
  <include name="footer"/>
  <block name="wapform.zz"/>                     <!-- 觸發：輸出外框結尾 -->
</card>
```

```html
<!-- onpage.aa -->
#(breadcrumb)                                     <!-- 原地執行 breadcrumb 子卡片 -->
<div class="content">#(content)</div>             <!-- 原地執行 content 子卡片 -->
<!-- onpage.zz -->
```

觸發套表的幾個關鍵：

- **條件觸發版型**：`cnd` 成立的區塊才輸出，版型自動切換，不需要 if／else；同一組條件可以驅動多個輸出區塊。
- **`aa`／`zz` 成對開關容器**：外框與元件拆成可重用的積木，巢狀套用；維護時只改套表，不動主程式。
- **`#(card)` 注入子卡片**：流程跑到 `#(content)` 時，`content` 子卡片被當成完整模組執行並回填到這個位置——它自己的查詢、逐筆輸出、分組都照常發生。外殼不動、內容可換，所有引用同一個外殼的頁面一起更新。
- **區塊可帶參數與狀態**：`<block name="row.aa" alg="'align-items-center'"/>` 把值傳進套表的 `$alg`；`var()`／`inc()` 讓跨區塊的序號、輪替配色可以預期。
- **與 CDATA 直寫的差別**：用 CDATA 在原地硬寫 HTML，等於自己拼接「殼＋內容」，分段、換版、套表重用都不會自動帶進來，頁面與版型一多，維護成本快速上升。

結果是：**設計師改套表不碰邏輯，工程師改 WML 不碰版面**；頁首、頁尾、選單用 `<include>` 定義一次，全站同步更新；輸出是標準 HTML，Bootstrap、Tailwind 或自訂 CSS 都能直接套用。同一套機制換個套表檔，就從網頁變成 API——`device="api.htm"` 只輸出 `.wml` 自己產生的內容，用來回應 LINE Bot 這類 Webhook 的 JSON。完整說明見第九章 Web 模板系統與第十五章。

### 拿 COBOL 來說：不是語言轉換器，也不用從零開始

目前許多 AI 工具都強調可以將 COBOL 轉換成 Java、C# 或其他現代語言。但：

> **程式碼成功轉換，不等於系統完成移植。**

COBOL 企業系統真正複雜的地方，往往包含多年累積的資料結構、交易流程、欄位語意、批次作業、報表、例外處理，以及原有 Runtime 所形成的行為。因此，單純的 **COBOL → Java** 很容易變成 **COBOL → AI → Java → Compile → Debug → Test → 再修改**，即使最後成功編譯，仍可能需要大量異質平台除錯與驗證，才能確認轉換後的系統是否真的與原系統具有相同的行為。

WapForm 的方向不同：它不是把「原始程式碼」當成唯一的真相，而是將應用程式提升到 WML 這個平台無關的定義層。未來的 **WapForm for COBOL** 並不只是「產生 COBOL」——既有 COBOL 系統的應用程式邏輯、資料、欄位、流程、事件與報表，也可以轉換*成* WML（**既有 COBOL → WapForm for COBOL → WML**），而且這個入口不是單向的，同一份 WML 也可以落地回 COBOL 本身（**COBOL → WapForm for COBOL → WML → COBOL**），讓 WapForm for COBOL 不只是「舊系統退場的出口」，也可以是「舊系統本身的重新生成與驗證工具」——確認轉換後的行為跟原本一致，或重新產生一份更乾淨、跟現行 Runtime 對齊的版本。一旦進入 WML，應用程式就不再被 COBOL 本身綁定，同一份定義可以再透過已經建立的 Flutter Generator 與 Runtime 落地：**既有 COBOL → WML → Flutter**，不必每次重新走一遍 **COBOL → Flutter**。如果 WML 已經完整描述原有應用程式，從 WML 產生 Flutter 時，原則上不需要重新理解一次 COBOL，也不需要重新進行一次大型跨語言翻譯，只需要針對少數平台差異進行必要調整——這就是 WML 作為中間定義層真正重要的地方。

**WapForm for COBOL 目前還不存在**——但 Flutter 已經完成了 **Definition → Generator → Runtime → Target Code** 這條完整工程鏈的第一次驗證，所以未來建立 COBOL 所需要的 Runtime、元件模型與 Generator 時，不需要重新發明整套 WapForm。在條件允許的情況下，後續平台甚至可能以與 Flutter 相同或更短的週期完成，因為最重要的方法、架構與生成流程已經存在：

> **第一個平台已經把最困難的工程方法建立並驗證，後續平台可以站在這個基礎上繼續落地。**

因此，未來可能形成：

**COBOL → WML → COBOL**

**COBOL → WML → Flutter**

以及：

**WML → 其他平台：MicroPython、Node.js**

**WML → 其他領域：AI、EDA**

不同平台不同領域不再需要各自重新定義一次相同的應用程式。

### WapForm 真正要建立的是什麼？

所以，WapForm 的核心並不是：

**WapForm for Flutter**

也不是：

**WapForm for COBOL**

而是一個更高層的架構：

> **讓應用程式先被定義，再由不同平台去實現。**

WML 是中心。AI 是加速器。Runtime 是落地層。平台只是最終的實現形式。

這也是 WapForm 與一般 AI 程式碼轉換工具最大的差異：

**AI Code Conversion**

`Source Code → AI → Another Source Code`

**WapForm**

`Application Definition → Target Runtime → Target Code`

前者是在不同語言之間搬移程式碼；後者則是讓應用程式定義本身脫離平台。

WapForm for Flutter 不只是一次 Flutter 移植——它是 WapForm 跨平台架構的第一個完整實證。

而 WapForm for COBOL，也不只是下一個「語言轉換器」。它可以成為既有 COBOL 系統進入 WML、再進一步落地到 Flutter 或其他平台的橋樑。

**One Definition. Any Platform. Every Domain.**

### 本書範圍

WapForm 目前有兩種正式的執行環境，也是本書主要涵蓋的內容：

**WapForm for Windows** — 傳統桌面 MDI 應用程式，直接連接資料庫，提供豐富的 UI 控制項（格線、頁籤、列印預覽）。

**WapForm for Web** — 伺服器端動態網頁引擎，將 `.wml` 解析為 HTML 輸出。Card 的 `device` 屬性指向 HTML 模板檔（如 `"wapform.html"`）。透過 `request.*` 接收 HTTP 參數，透過 `session.*` 維護使用者狀態，輸出可直接嵌入 Bootstrap 等前端框架。

第十六章額外收錄 **WapForm for Flutter**：同一份 WML 定義如何透過開源 Runtime 落地成 Flutter App，作為「定義一次，落地多次」在第三個平台上的具體示範。

本書是一本精簡、以範例驅動的參考手冊。假設讀者已熟悉 SQL、XML，以及事件驅動應用程式的概念，但不需要有任何 WapForm 使用經驗。

### 本書排版慣例

`<element/>` 代表 WML 空元素（void element）；`<element>` 代表容器元素。屬性名稱以 `等寬字型` 呈現。必填屬性標記為 **(必)**；選填屬性標記為 **(選)**。運算式語法採用 WapForm 的 `$()` 插值慣例。

---

### WapForm 平台生態系

WapForm 是一個持續演進的跨平台生態系：

| 平台 | 說明 | 狀態 |
|---|---|---|
| **WapForm Windows** | 桌面 MDI 應用框架，含表格、分頁、預覽列印 | 正式版 |
| **WapForm Web** | 伺服器端動態網頁引擎（IIS ISAPI），版面與邏輯分離 | 正式版 |
| **WapForm Flutter** | 同一份 WML 直接匯出跨平台 Flutter App，核心定位聚焦 Web，行動裝置支援逐步加入中 | 正式版 |
| **WapForm COBOL** | COBOL 匯入 → WapForm 開發 → 匯出 COBOL，免重寫的大型主機現代化 | 開發中 |
| **WapForm EDA** | 把散落在腳本裡的 IC 設計流程，收斂為可讀、可追溯的 WML 管線 | 開發中 |
| **WapForm AI（Cherith）** | 不預先訓練、直接推理的本地端 AI Agent | 開發中 |

---

### WapForm for AI：Cherith

Cherith 是 WapForm 進入 AI 時代的核心計畫，建立在二十年跨平台實戰經驗之上，走一條與 LLM 截然不同的路線。

LLM 依賴海量語料的統計關聯來預測輸出，本質上是語言的模仿者。Cherith 的主張是：**「語言即程式」，「世界即物件導向」**——每一句自然語言都能被解構為可推理的邏輯結構，名詞映射為物件，動作對應為方法，條件成為屬性操作，整個語意場景成為一個可程式化的物件導向世界模型。

這帶來幾個關鍵差異：不依賴預先訓練、可在邊緣設備運行（功耗為 GPU 的數分之一）、推理過程可解釋且可驗證、不產生幻覺。WapForm 十倍速開發能力，正是讓這套需要建構數千萬語句對應邏輯的系統成為可能的基礎。

> *LLM 是模仿，Cherith 是理解；LLM 是文字的輸出，Cherith 是認知的建構。*

---

本書涵蓋 WapForm for Windows、WapForm for Web 與 WapForm for Flutter 三個完整環境，以真實專案原始碼為基礎，從思維模型、語言參考到生產級實戰，提供完整的技術文件。

---

## 目錄

- [平台支援標記說明](#平台支援標記說明)
- [第一章　WapForm 思維模型](#第一章wapform-思維模型)
  - [1.1 一切皆為 Card](#11-一切皆為-card)
  - [1.2 資料集繫結模型](#12-資料集繫結模型)
  - [1.3 流程模式 vs. 輸出模式](#13-流程模式-vs-輸出模式)
  - [1.4 運算式系統](#14-運算式系統)
  - [1.5 事件模型](#15-事件模型)
- [第二章　文件結構](#第二章文件結構)
  - [2.1 WML 文件](#21-wml-文件)
  - [2.2 Card 生命週期](#22-card-生命週期)
  - [2.3 資料集欄位的變數命名規則](#23-資料集欄位的變數命名規則)
- [第三章　核心模式](#第三章核心模式)
  - [3.1 模式：單資料表 CRUD 表單](#31-模式單資料表-crud-表單)
  - [3.2 模式：主從結構](#32-模式主從結構)
  - [3.3 模式：查詢輸入 → 報表輸出](#33-模式查詢輸入--報表輸出)
  - [3.4 模式：Lookup 帶自動回填](#34-模式lookup-帶自動回填)
  - [3.5 模式：多頁籤分區表單](#35-模式多頁籤分區表單)
  - [3.6 模式：背景複製作業](#36-模式背景複製作業)
  - [3.7 模式：動態 WHERE + 多模式搜尋](#37-模式動態-where--多模式搜尋)
  - [3.8 模式：Web 會員登入與 Session 管理](#38-模式web-會員登入與-session-管理)
- [第四章　標籤完整參考手冊](#第四章標籤完整參考手冊)
  - [4.1 文件與版面標籤](#41-文件與版面標籤)
  - [4.2 資料存取標籤](#42-資料存取標籤)
  - [4.3 資料繫結與清單標籤](#43-資料繫結與清單標籤)
  - [4.4 表單輸入與互動標籤](#44-表單輸入與互動標籤)
  - [4.5 流程控制標籤](#45-流程控制標籤)
  - [4.6 變數與資料集操作標籤](#46-變數與資料集操作標籤)
  - [4.7 報表輸出標籤](#47-報表輸出標籤)
  - [4.8 交叉列表與圖表標籤](#48-交叉列表與圖表標籤)
  - [4.9 導覽與選單標籤](#49-導覽與選單標籤)
  - [4.10 系統整合標籤](#410-系統整合標籤)
  - [4.11 Web 專用標籤](#411-web-專用標籤)
  - [4.12 HTML 文字與版面標籤](#412-html-文字與版面標籤)
  - [4.13 標籤速查表](#413-標籤速查表)
- [第五章　陣列](#第五章陣列)
  - [5.1 宣告](#51-宣告)
  - [5.2 存取](#52-存取)
  - [5.3 陣列函數](#53-陣列函數)
  - [5.4 name() / value() 函數](#54-name--value-函數)
  - [5.5 陣列作為計數器（報表累計）](#55-陣列作為計數器報表累計)
  - [5.6 陣列作為查找表](#56-陣列作為查找表)
  - [5.7 陣列作為色彩對照表](#57-陣列作為色彩對照表)
  - [5.8 資料集的陣列式存取](#58-資料集的陣列式存取)
  - [5.9 限制與注意事項](#59-限制與注意事項)
- [第六章　運算式與函數庫](#第六章運算式與函數庫)
  - [6.1 插值語法](#61-插值語法)
  - [6.2 運算子](#62-運算子)
- [第七章　資料集物件參考](#第七章資料集物件參考)
  - [7.1 欄位值存取](#71-欄位值存取)
  - [7.2 資料集狀態屬性](#72-資料集狀態屬性)
  - [7.3 Lookup 前綴](#73-lookup-前綴lupDataset)
  - [7.5 Web 環境物件](#75-web-環境物件)
  - [7.6 報表環境特殊變數](#76-報表環境特殊變數)
  - [7.7 資料集方法速查](#77-資料集方法速查)
- [第八章　Windows 版系統登入與權限控制](#第八章windows-版系統登入與權限控制)
  - [8.1 三層協同架構](#81-三層協同架構)
  - [8.2 登入對話框](#82-登入對話框)
  - [8.3 身分驗證](#83-身分驗證)
  - [8.4 選單建構與 LoginLevel 設定](#84-選單建構與-loginlevel-設定)
  - [8.5 欄位區塊權限：author 標籤](#85-欄位區塊權限author-標籤)
  - [8.6 實戰範例：訂單簽核區塊](#86-實戰範例訂單簽核區塊)
  - [8.7 完整資料流](#87-完整資料流)
  - [8.8 資料庫設計參考](#88-資料庫設計參考)
  - [8.9 設計要點總結](#89-設計要點總結)
- [第九章　Web 模板系統](#第九章web-模板系統)
  - [9.1 概念：WML 驅動 HTML 模板](#91-概念wml-驅動-html-模板)
  - [9.2 觸發區塊（Triggered Block）](#92-觸發區塊triggered-block)
  - [9.3 HTML 模板的結構：區塊標記](#93-html-模板的結構區塊標記)
  - [9.4 版面模式](#94-版面模式)
  - [9.5 notebar 目錄樹：side sub card 詳解](#95-notebar-目錄樹side-sub-card-詳解)
  - [9.6 AJAX 按需載入與 wap 標籤](#96-ajax-按需載入與-wap-標籤)
  - [9.7 三種內容注入機制](#97-三種內容注入機制)
  - [9.8 兩種 HTML 模板](#98-兩種-html-模板)
  - [9.9 block 呼叫時的參數傳遞](#99-block-呼叫時的參數傳遞)
  - [9.10 模板內的運算式與狀態函數](#910-模板內的運算式與狀態函數)
  - [9.11 完整對應關係](#911-完整對應關係notewml--wapformhtml)
  - [9.12 套表機制小結](#912-套表機制小結)
- [第十章　圖表](#第十章圖表)
  - [10.1 概觀](#101-概觀)
  - [10.2 基本結構](#102-基本結構)
  - [10.3 chart — 圖表容器屬性](#103-chart--圖表容器屬性)
  - [10.4 serie — 數列屬性](#104-serie--數列屬性)
  - [10.5 point — 資料點](#105-point--資料點)
  - [10.6 圖型完整列表](#106-圖型完整列表)
  - [10.7 圖型速查表](#107-圖型速查表)
  - [10.8 資料來源：兩種模式](#108-資料來源兩種模式)
  - [10.9 顏色陣列技巧](#109-顏色陣列技巧)
  - [10.10 多圖表並排](#1010-多圖表並排table-版面)
  - [10.11 平台差異](#1011-平台差異)
  - [10.12 常見模式速覽](#1012-常見模式速覽)
- [第十一章　Web 檔案上傳實戰：upload 與 multiupload](#第十一章web-檔案上傳實戰upload-與-multiupload)
  - [11.1 multiupload：多檔 multipart 上傳](#111-multiupload多檔-multipart-上傳)
  - [11.2 upload：原始 PUT 單檔上傳](#112-upload原始-put-單檔上傳)
  - [11.3 安全機制小結](#113-安全機制小結)
  - [11.4 本章小結](#114-本章小結)
- [第十二章　Windows 檔案搬運實戰：open 與 webcopy](#第十二章windows-檔案搬運實戰open-與-webcopy)
  - [12.1 open：系統檔案選擇對話框](#121-open系統檔案選擇對話框)
  - [12.2 webcopy：五種協定的檔案搬運](#122-webcopy五種協定的檔案搬運)
  - [12.3 實戰整合：open + webcopy httpupload 圖片上傳與預覽](#123-實戰整合open--webcopy-httpupload-圖片上傳與預覽)
  - [12.4 本章小結](#124-本章小結)
- [第十三章　交叉列表實戰](#第十三章交叉列表實戰)
  - [13.1 WapForm 交叉列表的本質](#131-wapform-交叉列表的本質)
  - [13.2 系統概覽](#132-系統概覽)
  - [13.3 資料查詢：從明細到樞紐軸](#133-資料查詢從明細到樞紐軸)
  - [13.4 crosstab 根元素屬性](#134-crosstab-根元素屬性)
  - [13.5 狀態變數初始化](#135-狀態變數初始化)
  - [13.6 表格容器與分頁設定](#136-表格容器與分頁設定)
  - [13.7 欄軸定義：col change](#137-欄軸定義col-change)
  - [13.8 列軸與儲存格渲染](#138-列軸與儲存格渲染)
  - [13.9 欄末小計欄（TOTAL 欄）](#139-欄末小計欄total-欄)
  - [13.10 列末 AMOUNT 欄（橫向總合計）](#1310-列末-amount-欄橫向總合計)
  - [13.11 群組末小計列（TOTAL 列）](#1311-群組末小計列total-列)
  - [13.12 最終總計列（AMOUNT 總計）](#1312-最終總計列amount-總計)
  - [13.13 完整 WML 原始碼](#1313-完整-wml-原始碼)
  - [13.14 報表設計模式總結](#1314-報表設計模式總結)
- [第十四章　建構銷貨管理系統](#第十四章建構銷貨管理系統)
  - [14.1 系統概觀](#141-系統概觀)
  - [14.2 單表 CRUD 的三種寫法](#142-單表-crud-的三種寫法)
  - [14.3 動態查詢三劍客：`xyz` / `clr` / `set`](#143-動態查詢三劍客xyz--clr--set)
  - [14.4 出貨單主從結構：流水號與明細合計連動](#144-出貨單主從結構流水號與明細合計連動)
  - [14.5 動態聯動：條碼掃描與客戶歷史售價回填](#145-動態聯動條碼掃描與客戶歷史售價回填)
  - [14.6 跳窗式資料選取：四種 lookup 對話卡片](#146-跳窗式資料選取四種-lookup-對話卡片)
  - [14.7 雙聯式連續報表：出貨單／進貨單列印](#147-雙聯式連續報表出貨單進貨單列印)
  - [14.8 分組彙總報表：應收對帳單與期初餘額結轉](#148-分組彙總報表應收對帳單與期初餘額結轉)
  - [14.9 郵件整合：一鍵通知客戶出貨](#149-郵件整合一鍵通知客戶出貨)
  - [14.10 帳號與權限管理：巢狀主從＋自動展開子表](#1410-帳號與權限管理巢狀主從自動展開子表)
  - [14.11 本章小結](#1411-本章小結)
- [第十五章　建構動態網路交易平台（WapForm for Web）](#第十五章建構動態網路交易平台wapform-for-web)
  - [15.1 系統概覽](#151-系統概覽)
  - [15.2 一次查詢、全站共用的選單樹](#152-一次查詢全站共用的選單樹)
  - [15.3 元件重用：asider.wml 完全不查資料庫](#153-元件重用asiderwml-完全不查資料庫)
  - [15.4 依內容類型動態決定連結目標](#154-依內容類型動態決定連結目標)
  - [15.5 AJAX 局部載入：手冊與須知的雙檔設計](#155-ajax-局部載入手冊與須知的雙檔設計)
  - [15.6 商店首頁：三種操作模式與安全的動態查詢組裝](#156-商店首頁三種操作模式與安全的動態查詢組裝)
  - [15.7 分頁列產生器：`navigator` sub card](#157-分頁列產生器navigator-sub-card)
  - [15.8 購物車彙總：`header.wml` 內建的金流試算](#158-購物車彙總headerwml-內建的金流試算)
  - [15.9 Session 存活期：三層壽命與逐變數到期](#159-session-存活期三層壽命與逐變數到期)
  - [15.10 本章小結](#1510-本章小結)
- [第十六章　同一份定義，落地到 Flutter（WapForm for Flutter）](#第十六章同一份定義落地到-flutterwapform-for-flutter)
  - [16.1 為什麼需要另一個 Runtime](#161-為什麼需要另一個-runtime)
  - [16.2 套件架構：WapForm 模組](#162-套件架構wapform-模組)
  - [16.3 WML 標籤如何逐一映射成 Dart 類別](#163-wml-標籤如何逐一映射成-dart-類別)
  - [16.4 主從結構映射：出貨單與明細](#164-主從結構映射出貨單與明細)
  - [16.5 報表引擎映射：分組小計如何變成 `parseBlock`/`emitRow`](#165-報表引擎映射分組小計如何變成-parseblockemitrow)
  - [16.6 檔案架構：一個檔案一個獨立單元](#166-檔案架構一個檔案一個獨立單元)
  - [16.7 實例驗證：`app001`～`app902` 一次全部轉譯](#167-實例驗證app001app902-一次全部轉譯)
  - [16.8 平台現況與已知限制](#168-平台現況與已知限制)
  - [16.9 安裝與授權](#169-安裝與授權)
  - [16.10 本章小結](#1610-本章小結)
- [附錄 A　快速參考卡](#附錄-a快速參考卡)
- [附錄 B　函數完整參考](#附錄-b函數完整參考)
- [附錄 C　Flutter 運算式引擎差異](#附錄-cflutter-運算式引擎差異)
- [索引](#索引)

---

## 平台支援標記說明

第一至十五章的功能條目採用以下兩種標記，說明各功能在 Windows／Web 平台的支援狀況；第十六章 WapForm for Flutter 篇幅獨立成章，不套用此標記系統：

| 標記 | 說明 |
|---|---|
| 🖥️ **Win** | WapForm for Windows（桌面應用程式） |
| 🌐 **Web** | WapForm for Web（動態網頁伺服器端） |
| ✅ | 支援 |
| ⚠️ | 部分支援、行為有差異，或本手冊尚未確認 |
| ❌ | 不支援 |

第四章「標籤完整參考手冊」額外加註第三個平台標記：

| 標記 | 說明 |
|---|---|
| 📱 **Flutter** | WapForm for Flutter（一份 WML 匯出可執行的 Flutter App） |

WapForm for Flutter 的匯出機制，是把 **Windows 元件模型**（資料集、表格、導覽列、欄位、事件）逐一對應成等價的 Dart 類別，而不是另外對應 Web 版的 HTML 模板／Session／伺服器端機制。因此：

- 凡是 🖥️ **Win** 標記為 ❌ 的標籤（在 Windows 版本身就不存在），📱 **Flutter** 一律隨之標為 ❌，因為沒有 Windows 端的對應物可供匯出。
- **交叉列表**（`<crosstab>` 及其子標籤）與**圖表**（`<chart>` 及其子標籤）二類，官網版本功能對照表明確列為「各版本皆不支援」，原因是行動裝置本身的呈現限制，與付費版本無關；因此一律標為 📱 **Flutter** ❌。
- 其餘標籤依官網版本功能對照表歸類的能力項目（CRUD 表單、主從結構、Lookup 回填、計算欄位、資料導覽列、事件掛鉤、動態查詢、報表分組與分頁、多頁籤、列印預覽等）逐一比對；找不到對應能力項目、本手冊也無法從既有資料確認的標籤，一律標為 ⚠️，不做未經證實的斷言。

以上依據 WapForm 官網 `flutter.html`〈版本功能對照〉頁面之公開資訊整理，若日後版本功能異動，請以官網當時公告為準。

**📱 Flutter 段落**

第一至十五章裡，凡是 `wapform_flutter` 有對應模組的標籤與小節，後面都附一段 **📱 Flutter**，說明在 Dart 中用哪個模組、哪個 API 做到同樣的事，並附範例。沒有對應模組的功能（例如交叉列表、圖表、Web 模板、Session、`<navigator/>`、`<dbgrid>`）不附 Flutter 段落。用到的模組都在套件根目錄：

| 模組 | 主要 API |
|---|---|
| `wapform_expression.dart` | `WapEvaluator`：`eval()`、`cond()`、`setVar()`、`getVar()`、`setRow()`、`addFunction*()` |
| `wapform_lazarus.dart` | `useEngine()`、`setvar()`、`expression()`、`condition()`、`expandText()`／`expandSql()`／`expandSqlAuto()`／`expandSqlQuoted()`、`invoke()`、`varChangeHooks`、`DataSetRegistry`、`DbQuery` |
| `wapform_lookup_box.dart` | `WapLookupBox` |
| `wapform_filter.dart` | `WapFilter`、`FilterItem` |
| `wapform_report.dart` | `WapReport`、`WapPage`、`isLandscape()`、`normalizePaper()`、`customPaperSizeInches()`、`pageSizeOf()` |
| `wapform_report_style.dart` | `reportCssScreen`、`reportCssPrint`、`reportCssSrc` |
| `report_web.dart` | `openHtmlForPrint()`、`buildHtmlIframe()` |
| `wapform_colors.dart` | `WapColors` |

各段範例共用三個物件：`_ev`（這張 card 的 `WapEvaluator`）、`_reg`（這張 card 的 `DataSetRegistry`）與 `db`（`DbQuery(registry: _reg, connection: 連線)`，連線物件的建立方式見套件 README），並且已在畫面初始化時呼叫 `useEngine(_ev, _reg)`。安裝與架構見第十六章。

---

## 如何閱讀本書

第 1–3 章建立概念模型；第 4 章為標籤完整參考手冊；第 5 章為陣列；第 6 章為運算式系統（插值語法與運算子）；第 7 章為資料集物件參考；第 8 章為 Windows 登入與權限；第 9 章為 Web 模板系統；第 10 章為圖表；第 11 章為 Web 檔案上傳實戰（`<upload>` 與 `<multiupload>`）；第 12 章為 Windows 檔案搬運實戰（`<open>` 與 `<webcopy>`）；第 13 章為交叉列表實戰；第 14 章為銷貨管理系統實戰（WapForm for Windows）；第 15 章為動態網路交易平台實戰（WapForm for Web）；第 16 章為同一份定義落地 Flutter 實戰（WapForm for Flutter）；附錄 A 為快速參考卡；附錄 B 為函數完整參考，收錄全部 398 個函式（字串、數學、日期與時間、條件、編碼與轉換、其他）；附錄 C 為 Flutter 運算式引擎的差異。各章有對應模組的標籤與小節之後，附有 **📱 Flutter** 段落。

---

## 第一章　WapForm 思維模型

### 1.1 一切皆為 Card

🖥️ **Win** ✅ | 🌐 **Web** ✅

WapForm 的基本執行單位是 **card**——一個帶有唯一 `id` 的 `<card>` 元素。一個 WapForm 程式是一份包含一或多張 card 的 `<wml>` 文件。

**Windows 環境：** Card 更接近 Delphi 表單或 Windows 對話框，執行環境將它們托管在同一個 MDI 應用程式視窗內。

**Web 環境：** Card 的 `device` 屬性指向 HTML 模板（如 `"wapform.html"`），框架將 WML 流程的輸出嵌入模板的指定區塊。輔助 card 使用 `device="sub"` 作為可呼叫的子程序，由 JavaScript 的 `loadDoc()` 或框架路由機制非同步載入。

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
  <card id="P" device="wapform.html">   ← 主頁面，輸出嵌入 HTML 模板
  <card id="slider"    device="sub">    ← 輪播區塊（非同步載入）
  <card id="breadcrumb" device="sub">   ← 麵包屑（非同步載入）
  <card id="content"   device="sub">    ← 主要內容（非同步載入）
</wml>
```

Card 之間的導覽使用 `<go href="#id">` 向前跳轉，使用 `<prev/>` 返回上一張。Web 環境下可改用 `<redirect href="page.wml"/>` 進行 HTTP 重新導向。

### 1.2 資料集繫結模型

🖥️ **Win** ✅ | 🌐 **Web** ✅

WapForm 的資料層圍繞著 **dataset**（資料集）構建——具有名稱、游標定位的記錄集，其生命週期與 card 相同。每個 dataset 以 `<dbquery>`（SQL 查詢式）或 `<dbtable>`（資料表式）宣告。宣告後，`<datasource dataset="name">` 元素包裹 UI 控制項，並將它們繫結到目前記錄。

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

Web 環境下資料集同樣可用，但 UI 繫結（`<datasource>`、`<navigator/>`、`<dbgrid>`）通常替換為直接輸出 HTML。

**📱 Flutter**（`wapform_lazarus.dart`：`DbQuery`、`DataSetRegistry`）

`<dbquery id="em">` 對應 `db.query("em", sql)`：查詢開啟後以 `em` 註冊在 `DataSetRegistry`，運算式就能用 `em.欄位` 讀取目前記錄（id 不分大小寫）。

```dart
Future<void> openEmployees() async {
  await db.query("em", "select * from employees order by emp_no");
  debugPrint("${expression("em.emp_name")} / ${expression("em.COUNT")}");
}
```

### 1.3 流程模式 vs. 輸出模式

🖥️ **Win** ✅ | 🌐 **Web** ✅

Card 有兩種執行模式：

**流程模式** — card 主體由上而下作為程式執行：`<setvar>`、`<if>`、`<dbquery>`、`<alert>`、`<go>`。登入驗證、複製記錄、背景批次作業均以此模式運作。

**輸出模式** — card 主體產生類 HTML 標記，由托管渲染器消費。Windows 報表（`device="prv"`）以此模式運作；Web 環境的所有頁面輸出亦以此模式運作。

同一張 card 內可以混合流程與輸出——執行環境會自動分離兩者。

**📱 Flutter**（`wapform_lazarus.dart`；`wapform_report.dart`：`WapReport`）

流程模式的標籤依序寫成 `setvar()`、`condition()`、`await db.query(...)`；輸出模式寫在 `WapReport` 子類別的 `parseBlock()`，用 `emitRow(expandText(r"..."))` 輸出 HTML，再交給 `WapPage` 預覽與列印（第 4.7 節）。

```dart
Future<bool> checkStock() async {
  await db.query("st", r"select * from stock where pno=$(AsQuoted(pa.pno))");
  if (condition("st.COUNT=0")) return false;     // <if cnd="st.COUNT=0"> ... <exit/>
  setvar("ONHAND", "st.qty");
  return true;
}
```

### 1.4 運算式系統

🖥️ **Win** ✅ | 🌐 **Web** ✅

WapForm 以 `$variable` 進行簡單替換，以 `$(expression)` 計算任意字串屬性的值：

```xml
<setvar name="label" value="sz.color_name+'('+sz.color_no+')'"/>
<td>$(IF(total_qty>0, STR(total_qty), '—'))</td>
<alert message="$('Balance: '+STR(sa.c))" cnd="sa.c>0"/>
```

Web 環境增加 `DEFINE(var)` 函數，用於檢查 request 或 session 變數是否存在：

```xml
<setvar name="pg" value="1"/>
<setvar name="pg" value="val(request.pg)" cnd="DEFINE(request.pg)"/>
```

運算式遵循 SQL 式運算子優先順序，支援完整函數庫（第 5 章）。

**📱 Flutter**（`wapform_expression.dart`：`WapEvaluator`；`wapform_lazarus.dart`：`setvar()`、`expression()`、`condition()`、`expandText()`）

```dart
void expressionDemo() {
  setvar("label", "sz.color_name+'('+sz.color_no+')'");                  // <setvar>
  final td = expandText(r"<td>$(IF(total_qty>0, STR(total_qty), '—'))</td>"); // $(...)
  if (condition("sa.c>0")) {                                               // cnd=
    debugPrint(expandText(r"$('Balance: '+STR(sa.c))"));
  }
  _ev.setVar("request.pg", "3");             // Flutter 沒有 request.*：自己放進引擎
  setvar("pg", "1");
  if (condition("DEFINE(request.pg)")) setvar("pg", "VAL(request.pg)");
  debugPrint(td);
}
```

- `setvar()` 的值一律當運算式計算，字串常值要加單引號：`setvar("pa.icon", "'a.jpg'")`；要原樣存入 Dart 的值（使用者輸入、`List`）用 `_ev.setVar()`。
- 含 `$` 的字串請寫成 Dart raw string（`r"..."`），否則 `$` 會先被 Dart 自己插值。

### 1.5 事件模型

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（僅流程事件有效，UI 事件不適用）

資料集與 UI 控制項在關鍵生命週期時刻觸發事件。事件由包含任意 WapForm 流程的 `<onevent type="...">` 區塊處理：

| 觸發時機 | 事件 | Win | Web |
|---|---|---|---|
| 新增記錄時 | `onnewrecord` | ✅ | ⚠️ |
| 儲存前 / 後 | `beforepost` / `afterpost` | ✅ | ⚠️ |
| 刪除前 / 後 | `beforedelete` / `afterdelete` | ✅ | ⚠️ |
| 記錄游標移動後 | `afterscroll` | ✅ | ❌ |
| 欄位值變更時 | `onchange` | ✅ | ❌ |
| Lookup 選取關閉後 | `oncloseup` | ✅ | ❌ |
| 欄位失去焦點時 | `onexit` | ✅ | ❌ |
| 格線列雙擊時 | `ondblclick` | ✅ | ❌ |
| 計算格線儲存格色彩時 | `oncalccellcolors` | ✅ | ❌ |
| 格線頁尾需要更新時 | `onupdatefooter` | ✅ | ❌ |

**📱 Flutter**

有模組直接對應的事件：

| 事件 | Flutter |
|---|---|
| Lookup 選取關閉後 `oncloseup` | `WapLookupBox(onPicked: (key) { ... })`（第 4.4 節） |
| 篩選列 `onfilter` | `WapFilter(onQuery: (sql) async { ... })`（第 4.2 節） |
| 欄位值變更後，畫面同步變數 | `varChangeHooks`（第 7.7 節） |

事件裡的流程照樣用 `setvar()`、`condition()`、`invoke()` 撰寫。

---

## 第二章　文件結構

### 2.1 WML 文件

🖥️ **Win** ✅ | 🌐 **Web** ✅

每個 WapForm 程式都是一個副檔名為 `.wml` 的格式良好 XML 檔案：

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

**Web 環境典型結構：**

```xml
<?xml version="1.0"?>
<wml>
  <card id="P" device="wapform.html">
    <!-- 流程邏輯：讀取 request 參數、查詢資料庫 -->
    <setvar name="gp" value="request.gp" cnd="DEFINE(request.gp)"/>
    <dbquery id="sys">select * from sys</dbquery>
    <!-- 呼叫 HTML 模板區塊 -->
    <block name="wapform.aa"/>
    <include name="header"/>
    <block name="onreport"/>
    <include name="footer"/>
    <block name="wapform.zz"/>
  </card>

  <!-- 子 card：由 JS 非同步載入或路由呼叫 -->
  <card id="content" device="sub">
    <dbquery id="items"><![CDATA[SELECT ... ]]></dbquery>
    <report dataset="items">
      <group>
        <!-- 輸出 HTML 片段 -->
      </group>
    </report>
  </card>
</wml>
```

**作用域規則：**
- 宣告在 card 頂層的 `<dbquery>` 與 `<dbtable>`，在該 card 及其子 datasource 內均可見。
- 宣告在頂層的 `<function>` 元素，可透過 `<go href="@id">` 從同一檔案的任意 card 呼叫。
- 以 `<setvar>` 設定的變數在 card 工作階段內為全域。

### 2.2 Card 生命週期

🖥️ **Win** ✅ | 🌐 **Web** ✅（流程步驟相同，但 UI 渲染改為 HTML 輸出）

當一張 card 被開啟時：
1. 頂層流程依序執行：`<setvar>`、`<dbquery>`、`<if>`、`<alert>`。
2. `<datasource>` 元素初始化，觸發 `onnewrecord` 或從查詢載入資料。（Win）
   Web 環境直接以 `<report>` 迭代資料集輸出 HTML。
3. 渲染後的 UI 顯示給使用者。
4. 使用者互動觸發事件；事件執行後續流程。（Win）
   Web 環境由下一次 HTTP request 觸發新的 card 執行週期。
5. `<prev/>` 或 `<go href="#other">` 離開 card。（Win）
   Web 環境以 `<redirect href="page.wml"/>` 或 `<go href="#card_id">` 跳轉。

**📱 Flutter**（`wapform_lazarus.dart`：`useEngine()`、`DataSetRegistry.releaseAll()`）

一張 card 對應一個畫面，各有自己的 `WapEvaluator` 與 `DataSetRegistry`：

```dart
final WapEvaluator _ev = WapEvaluator();         // 這張 card 的變數
final DataSetRegistry _reg = DataSetRegistry();   // 這張 card 的資料集

Future<void> onOpen() async {                     // 1. 頂層流程（initState 呼叫）
  useEngine(_ev, _reg);                           //    setvar()/expression()/condition() 改用這張 card
  await db.query("em", "select * from employees");
}

void onClose() => _reg.releaseAll();              // 5. 離開 card：關閉並釋放所有資料集
```

同時開著多張 card 時，`useEngine()` 決定 `setvar()`、`expression()`、`condition()` 作用在哪一張；從另一張 card 回來後要再呼叫一次。子 card 要共用上層的變數與資料集時，把同一組 `_ev`、`_reg` 傳下去。

### 2.3 資料集欄位的變數命名規則

🖥️ **Win** ✅ | 🌐 **Web** ✅

WapForm 將資料集 `id` 與欄位名稱串接，產生複合變數名稱。例如：

```xml
<dbquery id="orderhdr" ...>
  <field fieldname="work_order_no" displaylabel="Work Order No."/>
```

變數 `orderhdrwork_order_no` 儲存目前欄位值，可透過 `<setvar>` 讀寫：

```xml
<setvar name="orderhdrwork_order_no" value="'WO-2024-001'"/>
```

**📱 Flutter**（`wapform_lazarus.dart`：`setvar()`）

Flutter 不使用 `orderhdrwork_order_no` 這種串接名稱，一律寫成 `資料集id.欄位`：

```dart
void namingDemo() {
  setvar("orderhdr.work_order_no", "'WO-2024-001'"); // 寫入目前記錄（瀏覽中會自動進入編輯）
  debugPrint("${expression("orderhdr.work_order_no")}");
}
```

`setvar()` 遇到 `id.欄位`、且 `id` 是已註冊並開啟的資料集時寫入欄位；否則當成一般變數名稱。

---

## 第三章　核心模式

### 3.1 模式：單資料表 CRUD 表單

🖥️ **Win** ✅ | 🌐 **Web** ❌（Web 使用 `<operator>` 輸出 HTML form）

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

`<navigator/>` 自動提供「第一筆 / 上一筆 / 下一筆 / 最後一筆 / 新增 / 刪除 / 儲存 / 取消」等按鈕。

### 3.2 模式：主從結構

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（以多次 `<dbquery>` + `<report>` 巢狀輸出替代）

**Windows 版——巢狀 `<datasource>` 建立主從：**

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

`masterfields="shipment_no"` 的效果：表頭移動時以表頭目前的單號重查明細，新增明細時帶入表頭單號。

```dart
// 表頭游標移動後呼叫
Future<void> loadDetail() async {
  await db.query("sn",
      r"select * from sn where shipment_no=$(AsQuoted(sh.shipment_no)) order by seq_no");
}

// 新增明細時呼叫
void newDetail() => setvar("sn.shipment_no", "sh.shipment_no");
```

`db.query()` 以同一個 id 再查一次時重用原資料集；`$(AsQuoted(...))` 會加上單引號並跳脫內容。

### 3.3 模式：查詢輸入 → 報表輸出

🖥️ **Win** ✅ | 🌐 **Web** ✅（Web 輸出 HTML，Windows 輸出列印預覽）

標準的 WapForm 報表流程是兩張 card 的序列：輸入 card 收集參數，報表 card 渲染輸出。

**步驟一 — 動態組合 WHERE 子句：**

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

**步驟二（Windows）— 在 `<page>` 區塊中渲染：**

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

**步驟二（Web）— 在 sub card 中輸出 HTML：**

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

**步驟一 — 動態組合 WHERE：**

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

**步驟二 — 報表：**`<report dataset="rpt_data">` 變成 `WapReport` 子類別，沒有 `change` 的 `<group>` 是 `RECORD` 區塊，`<page>` 是 `PAGEPREFIX`／`PAGESUFFIX`：

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

**步驟三 — 預覽**（`device="PRV"`、`orientation="landscape"`）：

```dart
Future<void> showReport() async {
  await buildQuery();
  if (!mounted) return;
  await Navigator.push(context, MaterialPageRoute(
    builder: (_) => WapPage(title: "Orders", report: OrderListReport(), orient: "L"),
  ));
}
```

Flutter 沒有「不預覽直接送印」：`PRN` 也開 `WapPage`，由使用者按列印（Web 交給瀏覽器列印，Android 產生 PDF）。

### 3.4 模式：Lookup 帶自動回填

🖥️ **Win** ✅ | 🌐 **Web** ❌（Web 以 HTML select 或 AJAX 替代）

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

lookup 屬性格式為：`"dataset_id ; 鍵值欄位 ; 顯示欄位"`。前綴 `lup` + dataset id 可存取所選列的欄位。

以 SQL 為基礎的動態 lookup：

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

`lookup="pm;material_code;material_name"` ＋ `oncloseup` 回填：

```dart
Widget materialLookup() => WapLookupBox(
      dataSet: _reg.findQuery("pm"),                  // lookup 的來源資料集
      keyField: "material_code",
      displayFields: const ["material_code", "material_name"],
      colWidths: const [100, 220],
      value: "${expression("sn.material_code") ?? ''}",
      onPicked: (key) {                               // oncloseup
        _ev.setVar("PICKED", key);
        setvar("sn.material_code", "PICKED");
        invoke("pm", "first");                        // 找到所選那一列（相當於 luppm）
        while (!condition("pm.EOF") && !condition("pm.material_code=PICKED")) {
          invoke("pm", "next");
        }
        setvar("sn.material_name", "pm.material_name");
      },
      onChanged: (key) {                              // onexit：清空時名稱一併清空
        if (key.isEmpty) setvar("sn.material_name", "''");
      },
    );
```

- SQL 式 lookup（`lookup="sql;yy;SELECT ..."`）：先 `await db.query("yy", "SELECT color_no, color_name FROM color_master ORDER BY color_no")`，再把 `_reg.findQuery("yy")` 交給 `dataSet:`。
- 固定選項不必開資料集：`lookupItems: {'A': '現金', 'B': '匯款'}`（單欄），或 `lookupColumns: {'P01': ['原子筆', '支']}` ＋ `colWidths`（多欄）。

### 3.5 模式：多頁籤分區表單

🖥️ **Win** ✅ | 🌐 **Web** ❌（Web 以 Bootstrap tabs + 多個 sub card 替代）

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

### 3.6 模式：背景複製作業

🖥️ **Win** ✅ | 🌐 **Web** ✅（Web 以 `device="sub"` + `<redirect>` 替代）

`device="SUB"` 的 card 在不開啟視窗的情況下執行工作流程，適用於記錄複製、批次更新與自動流水號。

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
  <!-- 其餘邏輯 -->
</card>
```

**📱 Flutter**（`wapform_lazarus.dart`：`DbQuery.query()`／`DbQuery.exec()`）

`device="SUB"` 的 card 在 Flutter 就是一個不建畫面的 `async` 方法：

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

- `db.query(id, sql)`：開查詢並以 id 註冊；`db.exec(sql)`：執行沒有傳回資料列的 SQL，傳回影響筆數。
- 兩者都可以改用參數：`db.query("src", "select * from orders where work_order_no=:no", params: {"no": sourceNo})`；傳了 `params` 就不再展開 `$`。

### 3.7 模式：動態 WHERE + 多模式搜尋

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
  <!-- 防止全表掃描 -->
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
  if (condition("S='1=1'")) setvar("S", "'work_order_no=`__NONE__`'"); // 防止全表掃描
  await db.query("result", r"SELECT * FROM orders WHERE $S ORDER BY order_date DESC");
}
```

反引號在展開時換成單引號；`$S` 原樣插入；使用者輸入一律先經過 `AsSqlStr()`（`'` → `''`）。Dart 引擎的 `AND`／`OR` 兩側比較要加括號。

### 3.8 模式：Web 會員登入與 Session 管理

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
      <block name="login-alert" message="'使用者無權限登入。'"/>
    <elseif cnd="MD5(B)<>usr.password"/>
      <block name="login-alert" message="'密碼輸入錯誤。'"/>
    <else/>
      <session name="usr" value="A"/>
      <redirect href="index.wml"/>
    </if>
  </if>
</card>
```

要讓登入身分自動逾時，在寫入時加上 `expire`（單位分鐘）即可：

```xml
<else/>
  <session name="usr" value="A" expire="480"/>   <!-- 8 小時後自動登出 -->
  <redirect href="index.wml"/>
```

`expire` 只能讓變數比系統預設更早失效，不能延長；完整說明見第十五章 15.9 節。

> **注意**：`<block>` 的參數值是運算式，字串常值必須加引號。上面的 `title="'錯誤'"` 若寫成 `title="錯誤"`，會被當成變數名稱、取到 Null，樣板輸出時即拋出 `Could not convert variant of type (Null) into type (OleStr)`。

---

## 第四章　標籤完整參考手冊

本章依功能分類，收錄 WML 中會用到的所有標籤，包含 WapForm 專屬標籤與可直接輸出的標準 HTML 標籤。每個標籤標示 🖥️ Win／🌐 Web 支援狀況、完整屬性表（含必填 **(必)** / 選填 **(選)**）、常見子標籤，並附最小可執行範例。屬性名稱以 `等寬字型` 呈現；`<element/>` 代表空元素（void element），`<element>` 代表容器元素。運算式語法採用 `$()` 插值慣例，詳見第六章。

### 4.1 文件與版面標籤

#### `<wml>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

每個 `.wml` 檔案的根容器，內含一或多個 `<card>`。本身沒有屬性，不可省略。

**常見子標籤：** `<card>`（一或多個）

```xml
<?xml version="1.0"?>
<wml>
  <card id="P" title="範例">
    ...
  </card>
</wml>
```

#### `<card>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

WML 的基本執行單元，第一章稱為「一切皆為 Card」。一個 `.wml` 可以有多張 card，框架依 `device` 決定渲染方式與角色。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `id` | (必) | Card 識別碼，供 `<include>`、`loadDoc()`、路由呼叫引用 |
| `title` | (選) | 視窗標題（Win）或 HTML `<title>`（Web） |
| `device` | (選) | 決定渲染角色：`MDI`（Windows 主視窗）、`SUB`／`sub`（背景/子 card，不產生 UI）、`PRV`（列印預覽）、`PRN`（直接送印）、HTML 模板檔名（Web，如 `"wapform.html"`、`"wapform-js.html"`） |
| `width` / `height` | (選) | 對話框尺寸（Win） |
| `orientation` | (選) | 報表方向：`portrait`（預設）／`landscape` |
| `printer` | (選) | 指定印表機來源，通常帶 `sys.printer1` 等系統設定 |
| `preview` | (選) | `Y`／`N`，控制報表是否先進入列印預覽 |
| `zoom` | (選) | 列印預覽的初始縮放比例 |
| `rowheight` | (選) | 格線／報表列高（像素） |
| `fontsize` | (選) | 預設字型大小（點數） |

**常見子標籤：** `<dbquery>`、`<datasource>`、`<report>`、`<crosstab>`、`<mainmenu>`、`<fieldset>`、`<do>`、`<function>`、`<onevent>`，以及各種流程控制標籤

```xml
<card id="P" title="員工主檔" device="MDI">
  <dbquery id="em">select * from employees</dbquery>
  <datasource dataset="em">
    <navigator/>
    <fieldset>
      員工編號：<input field="emp_no" size="8"/>
    </fieldset>
  </datasource>
</card>
```

Card 的生命週期詳見第二章 2.2 節。

**📱 Flutter**（`wapform_report.dart`：`WapPage`）

報表用的 card（`device="PRV"`／`"PRN"`）在 Flutter 是一個 `WapPage`，`orientation` 對應 `orient`：

```dart
Widget reportCard(WapReport report) => WapPage(
      title: "員工名冊",           // title=
      report: report,              // card 內的 <report>
      orient: "L",                 // orientation="landscape"
      paper: "A4",
    );
```

`orient` 接受 `P`（預設）、`L`、`landscape`、`1`、`橫`、`水平`；`paper` 接受 `A4`、`A3`、`A5`、`B5`、`letter`、`legal`，或自訂英吋 `"8.5x5.5"`。

#### `<page>`（版面）

🖥️ **Win** ✅ | 🌐 **Web** ✅（僅列印輸出情境） | 📱 **Flutter** ✅

包裹一個實體頁面的內容，在 `<report>`／`<crosstab>` 中每次分頁會重新進入 `<page>`。

**常見子標籤：** `<table>`、`<group>`、任意 HTML 版面標籤

```xml
<page>
  <table class="wap" width="100%" rows="40">
    <group>...</group>
  </table>
</page>
```

**📱 Flutter**（`wapform_report.dart`：`PAGEPREFIX`／`PAGESUFFIX`／`PAGEBREAK` 區塊）

`WapReport` 每頁開始呼叫 `parseBlock('PAGEPREFIX')`、結束呼叫 `parseBlock('PAGESUFFIX')`，兩頁之間呼叫 `parseBlock('PAGEBREAK')`；`<page>` 裡每頁重印的表頭寫在 `PAGEPREFIX`，`rows="40"` 對應 `wap.wapLpp = 40`：

```dart
// WapReport 子類別的 parseBlock() 片段
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

包裹一組相關輸入欄位，對應 HTML `<fieldset>`，內部直接放置 `<input>` 與說明文字。

**常見子標籤：** `<input>`、`<p>`、`<br/>`

```xml
<fieldset>
  <p>員工編號：<input field="emp_no" size="8"/></p>
  <p>姓名：<input field="emp_name" size="20"/></p>
</fieldset>
```

---

### 4.2 資料存取標籤

#### `<dbquery>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

宣告一個資料集（dataset），內容為 SQL 敘述。多行或含特殊字元的 SQL 建議包在 `<![CDATA[ ]]>` 中，避免 `<`、`>`、`&` 等符號與 XML 解析衝突。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `id` | (必) | 資料集識別碼，之後以 `$id.欄位` 或 `id.欄位` 引用 |
| `name` | (選) | 部分版本以 `name` 取代 `id`，效果相同 |
| `tablename` | (選) | 搭配 `<dbtable>` 使用時指定實體資料表名 |

**常見子標籤：** `<field>`（明確定義欄位時）

```xml
<dbquery id="em"><![CDATA[
  SELECT * FROM employees WHERE dept='$dept'
]]></dbquery>
```

單筆查詢可省略 CDATA：`<dbquery id="sys">select * from sys</dbquery>`。

**📱 Flutter**（`wapform_lazarus.dart`：`DbQuery.query()`／`DbQuery.exec()`、`expandSql()`）

| WML | Flutter |
|---|---|
| `<dbquery id="em">select ...</dbquery>` | `await db.query("em", r"select ...")` |
| SQL 中的 `$dept`、`$(expr)` | 查詢前自動以 `expandSql()` 展開 |
| 沒有 `id` 的 `<dbquery>`（INSERT／UPDATE／DELETE） | `await db.exec(r"...")`，傳回影響筆數 |

```dart
Future<void> dbqueryDemo() async {
  await db.query("em", r"SELECT * FROM employees WHERE dept='$dept'");
  await db.query("em2", "select * from employees where dept=:d", params: {"d": "R&D"});
  final n = await db.exec(r"UPDATE employees SET active=1 WHERE dept='$dept'");
  debugPrint("$n rows");
}
```

- 同一個 id 再呼叫一次，就是以新 SQL 重新查詢同一個資料集；id 給空字串則是不註冊的一次性查詢。
- 傳了 `params` 時不展開 `$`，值以參數方式送出，最能避免 SQL 注入。
- Dart 字串裡的 `<`、`>`、`&` 直接寫，不需要 CDATA。

#### `<dbtable>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（多以 `<dbquery>` 取代） | 📱 **Flutter** ✅

搭配 `<field>` 子標籤，明確定義資料集欄位與顯示名稱，取代直接寫 SQL；常見於簡單主檔的 CRUD 頁面，也用於帶查找鍵值的輔助資料集（lookup dataset）。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `tablename` | (必) | 實體資料表名稱 |
| `name` | (選) | 資料集識別碼 |
| `indexfieldnames` | (選) | 索引欄位，用於排序與 `locate` 定位 |
| `keyfields` | (選) | 主鍵欄位，作為查找/更新依據 |
| `lookupkeyfields` | (選) | 被其他 `<input lookup=...>` 引用時的鍵值欄位 |
| `filter` | (選) | 初始篩選條件字串 |

**常見子標籤：** `<field>`（一或多個）

```xml
<dbtable tablename="fm">
  <field fieldname="fno" displaylabel="貨運代號"/>
  <field fieldname="fname" displaylabel="貨運姓名"/>
</dbtable>

<!-- 帶鍵值的查找輔助資料集 -->
<dbtable name="gs" tablename="gszl" keyfields="factory_code" lookupkeyfields="factory_code">
  <field fieldname="factory_code" displaylabel="工廠代號"/>
  <field fieldname="factory_name" displaylabel="工廠名稱"/>
</dbtable>
```

**📱 Flutter**（`wapform_lazarus.dart`：`DbQuery.query()`）

Flutter 只有查詢式資料集，`<dbtable tablename="fm" indexfieldnames="fno">` 寫成：

```dart
Future<void> openFm() => db.query("fm", "select * from fm order by fno");
```

`lookupkeyfields` 對應 `WapLookupBox` 的 `keyField`（第 4.4 節 `<input>`）。

#### `<field>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

`<dbquery>` 或 `<dbtable>` 底下的子標籤，定義單一欄位的顯示名稱、型態與預設值。空元素。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `fieldname` | (必) | 對應資料庫實體欄位名 |
| `name` | (選) | 部分版本以 `name` 取代 `fieldname` |
| `displaylabel` | (選) | 畫面顯示標籤 |
| `type` | (選) | 資料型態，如 `date`、`checkbox` |
| `value` | (選) | 預設值（常用於新增記錄時） |

```xml
<field fieldname="hired" displaylabel="到職日" type="date"/>
```

#### `<dbfilter>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（多以手寫動態 WHERE 取代，見 14.3 節） | 📱 **Flutter** ✅

宣告式快速篩選列，框架自動產生輸入框並在 `onfilter` 事件中組出條件字串。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `result` | (必) | 篩選結果字串的變數名 |

**常見子標籤：** `<item>`（定義篩選欄位）、`<onevent type="onfilter">`

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
| `<item field="cno" size="20"/>` | `items: [FilterItem(field: "cno", label: "客戶代號", size: 20)]` |
| `result="R"` ＋ SQL 中的 `$R` | `sqlTemplate: r"select * from cu where $R order by cno"` |
| `<onevent type="onfilter">` | `onQuery: (sql) async { ... }`，收到 `$R` 已替換的完整 SQL |

```dart
Widget customerFilter() => WapFilter(
      items: const [
        FilterItem(field: "cno", label: "客戶代號", size: 20),
        FilterItem(field: "cname", label: "客戶名稱", size: 20),
      ],
      sqlTemplate: r"select * from cu where $R order by cno",
      onQuery: (sql) async {
        await db.query("cu", sql);           // onfilter 裡的 <dbquery>
        if (mounted) setState(() {});
      },
    );
```

使用者在各欄位輸入的條件：

| 輸入 | 組出的條件 |
|---|---|
| `A` | `欄位 = 'A'` |
| `A~Z` | `(欄位 >= 'A' and 欄位 <= 'Z')` |
| `A~` | `欄位 >= 'A'` |
| `~Z` | `欄位 <= 'Z'` |
| 含 `%`（`A%`、`%A%`） | `欄位 like '...'` |
| 全部空白 | `1=1` |

多個欄位以 `and` 串接，輸入中的 `'` 自動跳脫成 `''`；按 **Clear** 清空所有欄位並以 `1=1` 呼叫 `onQuery`。`width` 不給時撐滿外層，`borderColor` 可改框線色。

---

### 4.3 資料繫結與清單標籤

#### `<datasource>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（Web 環境改以 `<report>` 迭代輸出，見 3.1／3.2 節） | 📱 **Flutter** ✅

把畫面元件（`<input>`、`<dbgrid>`、`<navigator>`）繫結到指定資料集，可巢狀建立主從結構。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `dataset` | (必) | 對應 `<dbquery>` 的 `id` |
| `name` | (選) | 供內層 `<datasource>` 以 `mastersource` 引用 |
| `mastersource` | (選) | 巢狀主從時，指向外層 `<datasource>` 的 `name` |
| `masterfields` | (選) | 主從關聯欄位，子層自動依此欄位重新篩選 |

**常見子標籤：** `<navigator/>`、`<fieldset>`、`<input>`、`<dbgrid>`、內層 `<datasource>`（主從巢狀）

```xml
<datasource dataset="sh">
  <navigator/>
  <fieldset>
    單號：<input field="sno" readonly="true"/>
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

主從結構詳見 3.2 節；第十四章 14.4 節有完整生產範例。

#### `<dbgrid>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（Web 以 HTML `<table>` 迴圈輸出取代） | 📱 **Flutter** ✅

表格式清單，內含多個 `<item>` 定義欄位，支援就地編輯與勾選。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `name` | (選) | 供程式碼引用（如 `lookupResolver`） |
| `height` / `width` | (選) | 格線尺寸（像素） |
| `color` | (選) | 背景色 |
| `fontsize` | (選) | 字型大小（點數） |
| `multi` | (選) | `1` 允許多選 |

**常見子標籤：** `<item>`（一或多個）、`<column>`（樣式規則）

#### `<item>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ✅

`<dbgrid>` 或 `<dbfilter>` 底下的欄位定義。空元素。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `field` | (必) | 對應資料集欄位 |
| `size` | (選) | 欄寬 |
| `title` | (選) | 欄位標題，預設取資料集欄位的 `displaylabel` |
| `type` | (選) | `checkbox` 等特殊呈現型態 |
| `range` | (選) | 搭配 `type="checkbox"`，格式 `已選值;未選值` |
| `lookup` | (選) | `表;鍵欄;顯示欄` 格式，欄位顯示為查找結果 |

```xml
<dbgrid name="gd" height="200">
  <item field="itm" title="序" size="10"/>
  <item field="uid" size="30" lookup="users;userid"/>
  <item field="w" title="啟動" type="checkbox" range="1;0" size="10"/>
</dbgrid>
```

**📱 Flutter**

- 在 `<dbfilter>` 內：一個 `FilterItem(field:, label:, size:)`（見 `<dbfilter>`）。
- 帶 `lookup` 時：查找清單由 `WapLookupBox` 提供；放在表格儲存格內時設 `forGrid: true`，並以 `onTab`／`onTabPrev` 處理 Tab 跳格（參數見第 7.3 節）。

#### `<navigator/>`

🖥️ **Win** ✅ | 🌐 **Web** ❌（Web 以按鈕搭配 `request.op` 手動實作） | 📱 **Flutter** ✅

自動產生「第一筆／上一筆／下一筆／最後一筆／新增／刪除／儲存／取消」的完整 CRUD 按鈕列，空元素，繫結所在 `<datasource>` 的資料集，無屬性。

```xml
<p align="center"><navigator/></p>
```

#### `<column/>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

`<dbgrid>` 內用於依條件套用整欄或整列樣式（如背景色、文字色），常見於狀態高亮顯示。空元素，一律寫在 `<dbgrid>` 的 `<onevent type="oncalccellcolors">` 底下，每筆資料換行時逐一判斷。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `field` | (選) | 目標欄位（**省略則套用整列**，而不是整欄——這點常被誤解，`field` 指的是「只套到這一欄」，不填才是「這一列全部套用」） |
| `brush` | (選) | 背景色（十六進位色碼，無 `#`） |
| `color` | (選) | 文字色 |
| `cnd` | (選) | 條件運算式，成立才套用樣式；省略時視同永遠成立（見下方進階範例） |

**基本用法**（整列套色，`cnd` 成立時該列全部背景變色）：

```xml
<column brush="EDDA74" color="000000" cnd="od.cancelled='Y'"/>
```

**進階用法**：一個 `oncalccellcolors` 底下可以放多條 `<column>` 規則，每列資料會依序逐條判斷、互不影響（後面的規則不會覆蓋前面已經套用的，除非兩條規則的 `field` 或整列範圍重疊）。常見組合：一條負責「標出目前這一筆」，其餘各自負責「特定欄位依資料值變色」：

```xml
<onevent type="oncalccellcolors">
  <!-- 沒有 field：整列套色，標出「目前這一筆」（比對主鍵組成的字串） -->
  <column brush="#E5F3FF" cnd="sh.sno=(shym+shco+FORMAT('%4.4d',1))"/>

  <!-- 有 field：只有 cno 這一欄套色，顏色本身也是動態算出來的
       （brush 的值用 $(...) 從資料庫欄位 sh.color 組字串，不是寫定的色碼） -->
  <column field="cno" _color="#FF0000" brush="$('#'+sh.color)" cnd="sh.color&lt;&gt;''"/>
  <column field="cshort" _color="#FF0000" brush="$('#'+sh.color)" cnd="sh.color&lt;&gt;''"/>

  <!-- 沒有 cnd 也合法：這兩條沒有條件，等於「一律套用」，用來固定標示某欄的文字色 -->
  <column field="eval" color="#0000FF"/>
  <column field="log" color="#FF0000"/>
</onevent>
```

從這個例子可以看出三個補充規則：

1. **`brush`／`color` 可以是動態值**，不限於寫定的十六進位字面值——上例用 `$('#'+sh.color)` 把資料庫欄位 `sh.color` 現有的顏色值組成完整色碼，同一個 `<dbgrid>` 裡不同列可以套用不同顏色。
2. **`cnd` 可以省略**：沒有 `cnd` 的 `<column>` 規則視同永遠成立，常用來固定標示某欄的樣式（如上例 `eval`／`log` 兩欄）。
3. ⚠️ 上例出現 `_color="#FF0000"`（底線開頭、且帶 `#`）而不是文件表格中列出的 `color`（不帶底線）。這份手冊目前沒有找到底線前綴屬性（`_color`、`_bgcolor` 等）的正式規格說明，不確定底線前綴是代表「停用中、暫時保留」還是另一套獨立語法；`<dbgrid>` 元素本身在上例也帶了 `_bgcolor="#EEF3E9"`。實際行為建議以你環境中的 `wap.exe`／`flutter.pas` 產生結果為準，這裡先如實記錄觀察到的寫法，避免誤導。

---

### 4.4 表單輸入與互動標籤

#### `<input>`

🖥️ **Win** ✅ | 🌐 **Web** ✅（Web 需自行處理 `request.*` 回寫） | 📱 **Flutter** ✅

繫結單一欄位的輸入元件，型態與屬性依 `type` 變化。空元素。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `field` | (必) | 對應資料集欄位 |
| `size` | (選) | 顯示寬度 |
| `type` | (選) | `date`／`checkbox`／`radio` 等，預設為文字輸入 |
| `value` | (選) | `checkbox`／`radio` 的選項值，格式 `已選值;未選值` |
| `readonly` | (選) | `true` 時唯讀 |
| `lookup` | (選) | `表;鍵欄;顯示欄`，帶自動回填（見 3.4 節） |
| `oncustomdlg` | (選) | 指向一個彈出式選取卡片（如 `#PC`），取代預設 lookup 對話框 |
| `color` | (選) | 欄位底色，常配合 `cnd` 高亮異常值 |
| `title` | (選) | 搭配 `type="checkbox"` 時作為選項文字標籤 |
| `rows` / `cols` | (選) | 多行文字輸入（`textarea` 型態）的行列數 |
| `onclick` | (選) | 點擊時觸發的事件處理 |

```xml
<input field="cno" size="14" lookup="cu;cno;cname"/>
<input field="confirmed" type="checkbox" value="Y;N" title="正式訂單"/>
<input field="cancel_date" type="date"/>
<input field="remark" type="textarea" rows="4" cols="40"/>
```

**📱 Flutter**（`wapform_lookup_box.dart`：`WapLookupBox`）

`<input lookup="cu;cno;cname">` 的查找下拉框：

```dart
Widget customerLookup(bool editing) => WapLookupBox(
      dataSet: _reg.findQuery("cu"),               // lookup 第 1 段：來源資料集
      keyField: "cno",                             // 第 2 段：鍵值欄位
      displayFields: const ["cno", "cname"],       // 第 3 段：顯示欄位（可多個）
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

輸入框打字時，清單只留下代號或任一顯示欄含有輸入文字的項目，Enter 選定；失去焦點時以輸入內容回填並呼叫 `onChanged`。

#### `<do>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（Web 以一般 HTML 按鈕 + `request.op` 取代） | 📱 **Flutter** ✅

定義畫面按鈕，`type` 決定內建行為。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `type` | (必) | `accept`（確定，觸發存檔或自訂事件）／`prev`（取消，觸發 `<prev/>` 返回上一層） |
| `label` | (選) | 按鈕文字 |

**常見子標籤：** `<prev>`、`<setvar>`、`<invoke>`、`<dbquery>` 等任意流程標籤

```xml
<do type="accept" label="確定">
  <prev><setvar name="RESULT" value="gr.id"/></prev>
</do>
<do type="prev" label="取消"><prev/></do>
```

#### `<prev>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ✅

關閉目前彈出卡片並返回上一層；內含 `<setvar>` 時可在關閉前把選取結果帶回上層變數（見 14.6 節四種 lookup 對話卡片）。無屬性時為空元素 `<prev/>`；有子標籤時為容器元素。

**常見子標籤：** `<setvar>`

```xml
<prev><setvar name="shcno" value="cu1.cno"/></prev>
```

#### `<alert>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（Web 以 JavaScript `alert()` 或前端訊息元件取代） | 📱 **Flutter** ✅

彈出訊息框，常搭配 `cnd` 條件式驗證使用。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `cnd` | (選) | 條件成立才彈出 |
| `message` | (選) | 訊息內容；也可直接寫在標籤內文 |

```xml
<alert cnd="qty<=0">數量必須大於零</alert>
```

#### `<prompt>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

彈出輸入對話框，要求使用者輸入單一值並存回指定變數。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `message` | (選) | 提示文字 |
| `result` | (必) | 輸入結果存入的變數名 |

---

### 4.5 流程控制標籤

#### `<if>` / `<elseif>` / `<else>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

條件分支。`<if>` 可用 `cnd` 屬性做單行條件，或搭配 `<elseif>`／`<else>` 建立多分支。

| 屬性 | 必／選 | 說明（適用於 `<if>`／`<elseif>`） |
|---|---|---|
| `cnd` | (必) | 條件運算式 |

**常見子標籤：** 任意標籤；`<elseif>`／`<else>` 只能出現在 `<if>` 內部

```xml
<if cnd="CUSTNO_TO=''">
  <setvar name="SQL_WHERE" value="SQL_WHERE+' AND cno like '''+CUSTNO_FROM+'%'''"/>
  <elseif cnd="CUSTNO_FROM=''"/>
  <setvar name="SQL_WHERE" value="SQL_WHERE"/>
  <else/>
  <setvar name="SQL_WHERE" value="SQL_WHERE+' AND cno &gt;= '''+CUSTNO_FROM+''''"/>
</if>
```

多數標籤（`<setvar>`、`<dbquery>`、`<invoke>` 等）都支援直接掛 `cnd` 屬性做單一條件執行，等同於外面包一層 `<if>`。

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

- 標籤上的 `cnd` 屬性寫成 `if (condition("...")) ...;`。
- **Dart 引擎的 `AND`／`OR` 兩側比較要加括號**：`condition("(qty>0) AND (price<100)")`；不加括號會解析失敗並傳回 `false`。
- `condition()` 出錯時傳回 `false`，並在主控台印出 `[ERROR] 運算式 # 原因`。

#### `<switch>` / `<case>` / `<default>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

多分支選擇結構，依 `exp` 運算式比對各 `<case>` 的 `value`。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `exp`（`<switch>`） | (必) | 要比對的運算式 |
| `value`（`<case>`） | (必) | 比對值 |

**常見子標籤：** 一或多個 `<case>`，最後可加一個 `<default>`

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

只是依值換算時，一行運算式即可：`setvar("app", "SWITCH(mnu_typ[k],'b','book','n','note','p','page','grid')")`（`DECODE()` 用法相同）。

#### `<while>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

條件迴圈，`cnd` 為真時持續執行內部標籤，常搭配資料集的 `First`／`Next`／`EOF` 手動迭代。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `cnd` | (必) | 迴圈持續條件 |

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

迴圈中移動的資料集接著畫面元件時，前後加上 `invoke("mnu", "disablecontrols")`／`invoke("mnu", "enablecontrols")`，避免每移一筆就重繪。

#### `<for>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

計數迴圈，Web 環境常用於固定次數的版面重複輸出（如分頁按鈕列）。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `var` | (必) | 迴圈變數名 |
| `from` / `to` | (必) | 起訖值 |
| `step` | (選) | 遞增量，預設 1 |

#### `<go/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ✅

跳轉呼叫一個具名 `<function>`（以 `@函式名` 引用）或另一張 card；報表引擎中常見 `<go href="@header"/>` 呼叫頁首函式。空元素。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `href` | (必) | `@函式id` 或目標 card／URL |

```xml
<go href="@header"/>
```

#### `<exit/>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

空元素，立即結束目前 `<function>` 或流程區塊，常掛 `cnd` 做提前返回（見 14.4 節 `UpdateTotal` 函式的重入保護）。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `cnd` | (選) | 條件成立才結束 |

```xml
<exit cnd="DeletingItems"/>
```

#### `<function>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

定義一段可被 `<go href="@id">` 或事件呼叫的具名流程區塊，等同於命名子程序。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `id` | (必) | 函式名稱，供 `@id` 引用 |

**常見子標籤：** 任意流程控制與資料操作標籤

#### `<block/>`

🖥️ **Win** ⚠️ | 🌐 **Web** ✅ | 📱 **Flutter** ❌

輸出一段預先定義的 HTML/文字片段，常見於模板系統中依名稱插入固定樣板區塊（如 `footer.aa`、`footer.zz`）。空元素。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `name` | (必) | 樣板區塊名稱 |

```xml
<block name="footer.aa"/>
```

#### `<platform>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

依執行平台選擇要執行的內容，讓同一份 `.wml` 在各平台各走各的實作。Windows／Web 引擎只執行 `name` 含有自己平台名稱的區塊，其餘略過；WapForm for Flutter 產生器則把 `name="flutter"` 區塊裡的 `<![CDATA[ ]]>` 原樣當成 Dart 程式碼放進產生的 `.dart`。常用於某個功能在 Flutter 還沒有對應標籤（例如 `<open>` ＋ `<webcopy>` 的圖片上傳），或兩個平台需要不同寫法的時候。

**在 WML 中內嵌原程式**：`<platform>` ＋ `<![CDATA[ ]]>`

- 一份 `.wml` 可以直接帶目標平台的原生程式碼。
- 目前支援 Flutter（Dart）；COBOL 原程式預定沿用同一機制（`<platform name="cobol">`，開發中）。
- CDATA 內容原樣放進產生的程式，其餘部分仍是宣告式 WML。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `name` | (必) | 平台名稱：`windows`、`web`、`flutter`；可以同時寫多個（如 `name="windows,web"`） |
| `part` | (選) | 只用於 `name="flutter"`：`import` 表示內容是 Dart 的 `import` 敘述，放到產生檔開頭的匯入區 |

**常見子標籤：** `windows`／`web` 區塊內放一般 WML 標籤；`flutter` 區塊內放一段 `<![CDATA[ Dart 程式碼 ]]>`

`flutter` 區塊依擺放位置有三種用法：

| 位置 | 產生的 Dart |
|---|---|
| `part="import"` | 加到檔案開頭的 `import` 區 |
| `<function>`、`<onevent>` 等流程中 | 一段敘述，原樣插入該函式；內容有 `await` 時，函式自動成為 `async` |
| 版面中（如 `<td>`） | 一個 `Widget` 運算式，插入版面 |

**完整範例：`app002.wml` 產品圖片上傳**（Windows 用 `<open>` ＋ `<webcopy>`，Flutter 用 `file_picker` ＋ `http`）：

```xml
<card id="P" title="Product Master" width="1200">

  <!-- Flutter：產生檔要多匯入兩個套件 -->
  <platform name="flutter" part="import"><![CDATA[
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
  ]]></platform>

  <!-- 選圖並上傳 -->
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

  <!-- 清除圖片 -->
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

  <!-- 顯示圖片：只有 Windows 需要 -->
  <function id="SHOWIMG">
    <platform name="windows">
      <setprop name="g0" prop="img" value="IF(paicon='', 'http://localhost:90/xyz/upload/300x300.jpg', 'http://localhost:90/xyz/upload/'+paicon)"/>
    </platform>
  </function>

  <dbquery id="pa">
    <![CDATA[select * from pa order by pno]]>
    <field fieldname="icon" displaylabel="Icon"/>
    <onevent type="afterscroll">
      <!-- Flutter 的畫面在游標移動後會重繪，圖片自動跟著換 -->
      <platform name="windows"><go href="@SHOWIMG"/></platform>
    </onevent>
  </dbquery>

  <datasource dataset="pa">
    <table columns="1">
      <tr>
        <td>
          <!-- 版面：Windows 用連結與 <img>，Flutter 用一個 Widget 運算式 -->
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

這個範例看得出幾個重點：

1. **只有一個平台需要的區塊**（`SHOWIMG`、`afterscroll` 裡的 `<go>`）只寫 `windows`，Flutter 自然略過。
2. **`flutter` 區塊裡可以直接用產生檔內的名稱**：`<function id="A0">` 產生 `_a0()`、資料集 `pa` 是 `_pa`，以及產生檔內建的 `_saveAsync()`（寫回資料庫）、`_alert()`、`_str()`；`setvar()` 等則是 `wapform_flutter` 的函式。
3. **上傳檔名的處理一致**：Windows 的 `unique` 以時間戳命名；Flutter 端同樣用時間戳產生檔名，由 `upload.php?name=` 接收。
4. `<platform>` 也可以包住任意一段 WML（不只函式），例如只在 Web 顯示的說明文字：`<platform name="web"><p>…</p></platform>`。

> **注意：**`flutter` 區塊的內容會原樣放進 Dart 檔，語法錯誤要到 Flutter 編譯時才會發現；修改 `.wml` 後請重新產生並執行 `flutter analyze`。

---

### 4.6 變數與資料集操作標籤

#### `<setvar/>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

宣告或賦值一個變數，是 WML 中最常用的標籤；`value` 支援完整運算式語法（見第六章），可掛 `cnd` 做條件賦值。空元素。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `name` | (必) | 變數名稱 |
| `value` | (必) | 運算式或字面值 |
| `cnd` | (選) | 條件成立才賦值 |

```xml
<setvar name="TempTotal" value="TempTotal+sn.Total"/>
<setvar name="mnu_id" value="[0..1023]"/>  <!-- 宣告固定長度陣列 -->
```

**📱 Flutter**（`wapform_lazarus.dart`：`setvar()`；`wapform_expression.dart`：`WapEvaluator.setVar()`）

```dart
void setvarDemo() {
  setvar("TempTotal", "TempTotal+sn.Total");     // value 是運算式
  setvar("mnu_id", "[0..1023]");                 // 宣告固定長度陣列
  setvar("mnu_id[3]", "mnu.pno");                // 寫入陣列元素
  setvar("sh.amount", "TempTotal");              // 寫入資料集欄位
  if (condition("qty>0")) setvar("OK", "1");     // cnd=
  _ev.setVar("USER_INPUT", "O'Brien");           // Dart 值原樣存入，不經運算式
}
```

| `name` 寫法 | 行為 |
|---|---|
| `X` | 設定變數 |
| `X[i]` | 設定陣列元素；`i` 是運算式，陣列不夠長時自動延長（補 `null`） |
| `ds.欄位` | `ds` 已註冊且已開啟：寫入目前記錄（瀏覽中先自動進入編輯）；否則當成變數名稱 |

`setvar()` 改了變數後會通知 `varChangeHooks` 裡的函式，讓畫面同步（第 7.7 節）。

#### `<setprop/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ✅

動態設定畫面元件的屬性值（如顏色、可見性、頁籤索引），在執行期依條件改變 UI 外觀。空元素。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `name` | (必) | 目標元件 id |
| `prop` | (必) | 要設定的屬性名稱（如 `enabled`、`Readonly`、`img`、`filter`、`ActivePageIndex`） |
| `value` | (必) | 新的屬性值 |
| `cnd` | (選) | 條件成立才設定 |

```xml
<setprop name="$ID" prop="enabled" value="0" cnd="I=-1"/>
<setprop name="b0" prop="img" value="$(sys.GSWEB+'nopic.jpg')"/>
<setprop name="pagecontrol" prop="ActivePageIndex" value="0"/>
```

#### `<getprop/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ✅

讀取畫面元件目前的屬性值存入變數，與 `<setprop>` 相對。空元素。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `name` | (必) | 目標元件 id |
| `prop` | (必) | 要讀取的屬性名稱 |
| `result` | (必) | 存入的變數名 |

#### `<invoke/>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

呼叫資料集物件的方法（如 `First`／`Next`／`Edit`／`Post`／`GetBookmark`），是操作資料集游標與交易狀態的主要手段，完整方法清單見第七章 7.7 節。空元素。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `instance` | (必) | 目標資料集的 `id` |
| `method` | (必) | 方法名稱 |
| `arg1`／`arg2`／`arg3` | (選) | 方法參數（如 `locate` 的鍵值與比對選項） |
| `params` | (選) | 部分方法（如 `GoToBookmark`）以此傳入書籤變數 |
| `result` | (選) | 方法回傳值存入的變數名 |
| `cnd` | (選) | 條件成立才呼叫 |

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

| `method` | 說明 |
|---|---|
| `first`／`next`／`prior`／`last` | 移動游標 |
| `edit`／`insert`／`append`／`cancel`／`post`／`delete` | 編輯狀態（`post`／`delete` 寫回資料集；送進資料庫由資料集的更新機制處理） |
| `disablecontrols`／`enablecontrols` | 暫停／恢復畫面更新（`beginwalk`／`endwalk` 同義） |
| `getbookmark`／`gotobookmark`／`freebookmark` | 書籤 |

方法名稱不分大小寫；`invoke()` 找不到資料集時傳回 `null`、不做任何事。`locate`、`refresh` 沒有對應的 `invoke` 方法：重新查詢用 `db.query("ds", sql)`。

---

### 4.7 報表輸出標籤

#### `<report>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

依資料集逐筆迭代並輸出內容，是報表與 Web 版面渲染的核心標籤；搭配 `<group>` 建立分組小計，搭配 `<page>` 控制分頁。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `dataset` | (必) | 要迭代的資料集 `id` |
| `rows` | (選) | 每頁固定行數，用於連續報表自動分頁（見 12.11 節） |
| `dialog` | (選) | 分組對話框依據欄位，常見於多層分組報表 |

**常見子標籤：** `<setvar>`、`<group>`、`<page>`

```xml
<report dataset="sh" dialog="cno;sno">
  <group change="sh.cno">
    <setvar name="AMOUNT_SUM" value="0"/>
    <page>...</page>
  </group>
</report>
```

**📱 Flutter**（`wapform_report.dart`：`WapReport`、`WapPage`；`wapform_report_style.dart`；`report_web.dart`）

`<report dataset="sh">` 寫成 `WapReport` 子類別，由 `WapPage` 顯示。執行順序：

```
initParams() → fetchFirst()
PREFIX → PAGEPREFIX
  ┌ 每筆：群組值改變？→ onGroupPrepare() → G1_PREFIX…G9_PREFIX
  │       RECORD → fetchNext()
  │       下一筆群組值改變？→ fetchPrior() → G9_SUFFIX…G1_SUFFIX → fetchNext()
  └ 每滿 wapLpp 行（emitRow 計算）→ PAGESUFFIX → PAGEBREAK → PAGEPREFIX
最後一組的 SUFFIX → PAGESUFFIX → SUFFIX
```

| 子類別要實作 | 說明 |
|---|---|
| `initParams()` | `wap.wapLpp`（每頁行數）、`wap.wapGroups`（群組層數，最多 9）、`wap.wapRow[i].tagPrefix`／`tagSuffix`（第 i 層的區塊名稱） |
| `expression(int idx)` | 第 idx 層群組的值；值一改變就換組（對應 `<group change>`） |
| `fetchFirst()`／`fetchNext()`／`fetchPrior()` | 資料怎麼讀，通常用 `invoke()` ＋ `condition("ds.EOF")` |
| `parseBlock(String id)` | 各區塊輸出什麼 |
| `onGroupPrepare()` | （選用）換組前的非同步準備，例如先查該組的彙總資料 |

| 可呼叫 | 說明 |
|---|---|
| `emitRow(html, {isHeader, isFooter})` | 輸出一行並計算行數，滿 `wapLpp` 自動換頁、重印 `PAGEPREFIX` |
| `emit(text, {isHeader, isFooter, tag})` | 輸出但不計行數（表格開頭、收尾） |
| `forcePageBreak()` | 強制換頁 |
| `buildHtml()` | 整份報表 HTML |
| `buildPdf({orient, paper, fontAsset})` | 產生 PDF（Android）；Web 上改為開新分頁列印 |

> **注意：**`WapReport` 自己有 `expression(int idx)` 方法，會遮住 `wapform_lazarus.dart` 的頂層 `expression()`。報表類別裡要計算運算式，請用 `expandText(r"$(...)")`、`condition()`，或 `currentEvaluator!.eval("...")`。

`WapPage` 在 Web 以 iframe 預覽、列印時開新分頁交給瀏覽器（`report_web.dart` 的 `openHtmlForPrint()`）；在 Android 以系統 WebView 預覽、列印時產生 PDF。螢幕與列印樣式來自 `wapform_report_style.dart` 的 `reportCssScreen`／`reportCssPrint`。`dialog="cno;sno"` 的條件輸入，在 Flutter 用 `WapFilter` 取得條件、查好資料集後再開報表。

#### `<group>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ✅

`<report>`／`<crosstab>` 內的分組區塊。不帶 `change` 屬性時代表逐筆輸出（RECORD 區塊）；帶 `change` 時，該運算式的值改變才會重新進入這個區塊，常用來做分組小計與自動換頁。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `change` | (選) | 分組依據運算式，值改變才重新觸發 |

**常見子標籤：** `<setvar>`、內層 `<group>`（多層分組）、任意輸出內容

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

`<group change="sh.cno">` 是第 1 層、`<group change="datetostr(sh.sdate)">` 是第 2 層，最內層沒有 `change` 的 `<group>` 是 `RECORD`：

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
  await db.query("sh", "select * from sh order by cno, sdate");   // 依群組欄位排序
  if (!mounted) return;
  await Navigator.push(context, MaterialPageRoute(
    builder: (_) => WapPage(title: "應收對帳單", report: StatementReport()),
  ));
}
```

換組時引擎先 `fetchPrior()` 回到上一組最後一筆再輸出 `G?_SUFFIX`，所以小計列裡的 `sh.cname` 仍是上一組的客戶。

#### `<newpage/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（Web 以分頁按鈕/URL 參數取代實體換頁） | 📱 **Flutter** ✅

空元素，強制換頁，常見於固定行數連續報表手動控制換頁邏輯（見 14.7 節）。無屬性。

**📱 Flutter**（`wapform_report.dart`：`forcePageBreak()`）

```dart
// WapReport 子類別的 parseBlock() 片段：每位客戶從新的一頁開始
void newPageDemo(String id) {
  if (id == 'G1_PREFIX' && condition("not(cu.bof)")) forcePageBreak(); // <newpage cnd="not(cu.bof)"/>
}
```

`forcePageBreak()` 依序輸出 `PAGESUFFIX` → `PAGEBREAK` → `PAGEPREFIX`；該頁還沒有明細時不會產生空白頁。一般情況不必手動換頁，`emitRow()` 數到 `wap.wapLpp` 行會自動換頁。

#### `<varblock/>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

逐段累積 HTML 到具名變數，模板結尾以 `$(varname)` 一次插入，取代逐步輸出（見第九章 varblock 預累積注入）。空元素。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `name` | (必) | 累積變數名 |
| `block` | (必) | 要累加的內容區塊名稱 |

```xml
<report dataset="mnu">
  <varblock name="footer" block="footer.aa"/>
  <varblock name="footer" block="footer-item"/>
  <varblock name="footer" block="footer.zz"/>
</report>
```

#### `<debug/>`

🖥️ **Win** ✅ | 🌐 **Web** ✅ | 📱 **Flutter** ⚠️

開發期輔助標籤，輸出目前報表引擎的座標與累計狀態（如 `$row,$col;$K,$(X[K])`），發布前應移除。無屬性。

**📱 Flutter**（`wapform_expression.dart`：`getUserVars()`、`hasError`／`lastError`；`wapform_lazarus.dart`：`DataSetRegistry.registeredIds`）

```dart
void debugDump() {
  debugPrint(expandText(r"$K,$(X[K])"));         // 指定的值
  debugPrint("${_ev.getUserVars()}");            // 所有使用者變數
  debugPrint("datasets: ${_reg.registeredIds}"); // 已註冊的資料集
  _ev.eval("1>0 AND 2>1");
  if (_ev.hasError) debugPrint(_ev.lastError);   // 運算式錯誤原因
}
```

`expression()`／`condition()` 出錯時會自動在主控台印出 `[ERROR] 運算式 # 原因`。

---

### 4.8 交叉列表與圖表標籤

#### `<crosstab>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ❌

宣告式交叉列表（樞紐分析），以列群組、欄群組、交叉格彙總描述複雜報表，取代外部報表工具，詳見第十三章。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `dataset` | (必) | 來源資料集 |
| `field` | (必) | 交叉彙總的數值欄位 |
| `dialog` | (選) | 對話框依據欄位 |
| `autospan` | (選) | `yes` 時相同群組值的標頭儲存格自動合併 |

**常見子標籤：** `<row change>`、`<col change>`、內層 `<group>`

```xml
<crosstab dataset="xy" dialog="cno;sdate" field="amount" autospan="yes">
  <row change="xy.cno">...</row>
  <col change="xy.YM">...</col>
</crosstab>
```

#### `<row>` / `<col>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ❌

`<crosstab>` 內分別定義列群組與欄群組，`change` 屬性語意與 `<group change>` 相同，可多層巢狀。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `change` | (選) | 分組依據運算式 |

#### `<chart>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（Web 多以前端圖表庫如 Chart.js 取代） | 📱 **Flutter** ❌

宣告式圖表輸出，讓開發者不需撰寫 JavaScript 即可產生互動式圖表，完整屬性見第十章 10.3 節。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `title` | (選) | 圖表標題文字 |
| `dataset` | (選) | 綁定資料集名稱（資料集驅動模式） |
| `rangeto` | (選) | 軸最大刻度值 |
| `legend` | (選) | `yes` 顯示圖例 |
| `autocolor` | (選) | `yes` 自動為各資料點套用不同顏色 |
| `xaxisposition` / `yaxisposition` | (選) | 座標軸顯示位置，`none` 表示隱藏 |
| `titlefontsize` | (選) | 標題字型大小（點數） |
| `xresult` | (選) | 圖表輸出結果存入指定變數 |

**常見子標籤：** 一或多個 `<serie>`

#### `<serie>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ❌

`<chart>` 內定義單一資料數列，完整屬性見第十章 10.4 節。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `type` | (必) | 圖型種類，共 12 種（完整範例見第十章 10.6 節）：折線類 `line`／`digitalline`；長條類 `bar`／`stackedbar`／`histogram`；面積類 `area`／`stackedarea`；圓餅類 `pie`／`donut`／`sizedpie`／`sizeddonut`；雷達類 `spider` |
| `title` | (選) | 數列名稱（顯示於圖例） |
| `color` | (選) | 填充色（`#RRGGBB`） |
| `linecolor` / `linewidth` | (選) | 線條色／寬度（line 類） |
| `opacity` | (選) | 透明度 0–255（area 類） |
| `marker` | (選) | `yes` 顯示資料點標記（line 類） |
| `valuewidth` | (選) | 資料點寬度（bar 類） |
| `fieldnamevalue` / `fieldnamexaxis` | (選) | 資料集驅動模式的數值／X 軸欄位 |
| `pielegend`／`pieposition`／`pieleft`／`pietop`／`piesize`／`pieshowvalues`／`pieshowlegendonslice`／`pievalueposition` | (選) | 圓餅／環圈類專屬屬性 |

**常見子標籤：** 一或多個 `<point>`（程式產生模式）

#### `<point/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ❌

`<serie>` 內的單一資料點，通常在 `<while>` 或 `<for>` 迴圈內動態產生。空元素。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `label` | (必) | X 軸標籤或圖例名稱，支援運算式 |
| `value` | (必) | Y 軸數值，支援運算式 |
| `color` | (選) | 個別資料點顏色 |

```xml
<chart title="line" rangeto="11" legend="yes">
  <serie type="line" linecolor="#f37735" linewidth="2" marker="yes">
    <point label="1月" value="120"/>
    <point label="2月" value="95"/>
  </serie>
</chart>
```

---

### 4.9 導覽與選單標籤

#### `<include/>`

🖥️ **Win** ⚠️ | 🌐 **Web** ✅ | 📱 **Flutter** ⚠️

引入另一個具名 card 的輸出，是 Web 模板共用元件（`header`／`footer`／`asider`）的核心機制，詳見第九章、第十五章。空元素。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `name` | (必) | 目標 card 的 `id` |

```xml
<include name="header"/>
```

#### `<redirect/>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

空元素，導向另一個 URL 或 `.wml`，常見於登入驗證失敗或流程結束後跳轉。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `href` | (必) | 目標網址或 `.wml` |

```xml
<redirect href="index.wml"/>
```

#### `<mainmenu>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

定義 Windows MDI 主視窗的選單列，通常出現在 `device="MDI"` 的主 card 中。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `images` | (選) | 選單圖示清單來源（imagelist）名稱 |

**常見子標籤：** 一或多個 `<menuitem>`（可巢狀代表子選單）

#### `<menuitem>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

`<mainmenu>` 底下的選單項目，可巢狀建立多層選單。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `name` | (選) | 元件 id，供 `<setprop>` 動態控制（如停用） |
| `caption` | (必) | 顯示文字，支援運算式 |
| `hint` | (選) | 提示文字或分類標記 |
| `imageindex` | (選) | 對應 `images` 圖示清單的索引 |
| `onclick` | (選) | 點擊時要導向的目標（如選單項目對應的 `href`） |

**常見子標籤：** 內層 `<menuitem>`（子選單）

```xml
<mainmenu images="imagelist1">
  <menuitem caption="銷貨作業" hint="sub">
    <menuitem name="A001" caption="出貨單建檔" hint="app006.wml"
              imageindex="1" onclick="app006.wml"/>
  </menuitem>
</mainmenu>
```

#### `<tabsheet>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️（Web 以 Bootstrap 頁籤元件手動實作） | 📱 **Flutter** ✅

分頁籤容器，常見於多頁籤搜尋表單或建檔頁面切換不同檢視模式。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `caption` | (必) | 頁籤標題 |

**常見子標籤：** 任意版面與輸入標籤（該頁籤的內容）

#### `<pagecontrol>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ✅

`<tabsheet>` 的外層容器，管理多個頁籤之間的切換；可搭配 `<setprop prop="ActivePageIndex">` 動態切換目前顯示的頁籤。

**常見子標籤：** 一或多個 `<tabsheet>`

---

### 4.10 系統整合標籤

#### `<mail>`

🌐 **Web** ✅ | 🖥️ **Win** ❌（Win 以 `<shellexecute>` 呼叫 `mailto:` 取代，見 14.9 節） | 📱 **Flutter** ❌

伺服器端直接寄送電子郵件，不需使用者本機安裝郵件軟體。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `to` | (必) | 收件人 |
| `subject` | (選) | 主旨 |
| `body` | (選) | 內文 |

#### `<shellexecute/>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

呼叫作業系統層級的外部程式或協定，常見於開啟預設郵件軟體（`mailto:`）或啟動外部應用程式。空元素。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `operation` | (必) | 通常為 `open` |
| `file` | (必) | 目標路徑或協定 URL |

```xml
<shellexecute operation="open" file="mailto:$(cu.email)?subject=出貨通知"/>
```

#### `<webcopy/>`

🖥️ **Win** ✅ | 🌐 **Web** ❌ | 📱 **Flutter** ⚠️

依 `protocol` 屬性在本機檔案系統、HTTP、FTP 之間搬運檔案，是 Windows 端唯一內建的檔案傳輸手段；常搭配 `<open/>` 做「選檔 → 上傳」的圖片管理流程。空元素。完整協定行為、`host`/`url`/`dir` 對照表與實戰範例詳見第十二章。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `protocol` | (選，預設 `file`) | `file`／`httpupload`／`httpdownload`／`ftpupload`／`ftpdownload` 之一 |
| `host` | 依協定而定 | 意義隨 `protocol` 改變（目標目錄／目標網址／來源網址／FTP 主機） |
| `url` | 依協定而定 | 意義隨 `protocol` 改變（來源路徑／本機檔案路徑／FTP 上的檔名） |
| `dir` | 依協定而定 | 意義隨 `protocol` 改變（存放目錄／FTP 上的目錄），`file`／`httpupload` 協定不使用 |
| `username` / `password` | FTP 協定必填 | FTP 登入帳號密碼 |
| `unique` | (選) | 出現此屬性即代表 `true`：以時間戳自動命名，撞名則加序號，不覆蓋既有檔案 |
| `result` | (選) | 成功時寫入存檔／上傳後的檔名；失敗時寫入錯誤訊息 |
| `errmsg` | (選) | 失敗時寫入錯誤訊息；成功時清空為空字串 |
| `response` | (選，僅 `httpupload` 有效) | 寫入伺服器回應的原始內容 |

#### `<open/>`

🖥️ **Win** ✅ | 🌐 **Web** ⚠️ | 📱 **Flutter** ⚠️

依屬性組合分成兩種完全不同的用途，屬性不可混用：

| 用途 | 屬性 | 平台 | 說明 |
|---|---|---|---|
| 彈出另一張 card | `href` (必) | 🖥️ **Win** ✅ \| 🌐 **Web** ⚠️ \| 📱 **Flutter** ⚠️ | 開啟另一張 card 作為彈出視窗，`href` 為目標 card 的 `id`（常以 `#id` 表示）；與 `<include>` 不同之處在於會產生獨立的視窗/對話框而非嵌入輸出 |
| 系統檔案選擇對話框 | `filename` (必)、`result` (必) | 🖥️ **Win** ✅ \| 🌐 **Web** ❌ \| 📱 **Flutter** ⚠️ | 彈出作業系統原生的「開啟舊檔」對話框；`filename` 寫入使用者選取的完整路徑，`result` 寫入使用者是否確認（`1` 為確認），詳見第十二章 12.1 節 |

#### `<upload/>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

伺服器端接收原始 HTTP `PUT` 請求並存檔，整個 request body 就是檔案本身的位元組，沒有 multipart 外包裝、也沒有檔名，相容傳統 `upload.php` 的收法。空元素。完整檔名決定順序、Content-Type 推斷與安全機制詳見第十一章 11.2 節。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `destination` | (必) | 存檔目錄 |
| `filename` | (選) | 固定存檔檔名；留空則依 `Content-Disposition` 標頭或時間戳決定 |
| `accept` | (選) | 允許的副檔名白名單，逗號分隔；留空代表不限制 |
| `unique` | (選) | `yes` 時，撞名自動加序號避免覆蓋（與 `nameconflict="unique"` 等義） |
| `result` | (選) | 錯誤訊息／狀態要寫入哪個變數 |
| `size` | (選) | 收到的位元組數要寫入哪個變數 |
| `savedname` | (選) | 實際存檔後的檔名要寫入哪個變數 |

#### `<multiupload>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

伺服器端接收瀏覽器 `<form enctype="multipart/form-data">` 送出的多檔上傳請求；容器元素，每存好一個檔案就執行一次子節點，供頁面逐檔顯示縮圖或寫入資料庫。完整範例與引擎規則詳見第十一章 11.1 節。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `filefield` | (必) | 對應 `<input type="file" name="...">` 的欄位名稱 |
| `destination` | (必) | 存檔目錄 |
| `filename` | (必) | 存檔後的檔名要寫入哪個變數（迴圈內逐檔更新） |
| `srcname` | (選) | 使用者端原始檔名要寫入哪個變數 |
| `index` | (選) | 目前是第幾個檔案（從 1 起算）要寫入哪個變數 |
| `count` | (選) | 上傳結束後，總共成功存檔的檔案數要寫入哪個變數 |
| `result` | (選) | 錯誤訊息要寫入哪個變數，全部成功則為空字串 |
| `accept` | (選) | 允許的副檔名白名單，逗號分隔；留空代表不限制 |
| `nameconflict` | (選) | 撞名處理策略，`unique` 表示自動加時間戳與序號避免覆蓋 |

---

### 4.11 Web 專用標籤

#### `<wap>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

Web 環境中直接輸出原始 HTML／文字內容的容器，內部可使用 `$()` 插值運算式，常見於 AJAX 局部載入的內容 card（見 15.5 節 `book-js.wml`）。

**常見子標籤：** 通常搭配 `<![CDATA[ ]]>` 包裹一段 HTML

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
      src: r'$pa.topic <div>$pa.pno</div>',      // 先 expandText() 再以 HTML 顯示
      showPrint: false,
    );
```

`src` 會經過 `expandText()`，內容中要輸出 `$` 字元時寫成 `$$`。

#### `<session/>`

🌐 **Web** ✅ | 🖥️ **Win** ❌ | 📱 **Flutter** ❌

寫入伺服器端 Session 狀態的標籤，語法與 `<setvar>` 對應，空元素。維持使用者登入狀態與購物車流水號等跨頁請求需要保留的值。`<setsession>` 是同一個標籤的別名，行為完全相同。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `name` | (必) | Session 變數名稱 |
| `value` | (必) | 要寫入的值。**設為空字串 `''` 即刪除該變數** |
| `expire` | (選) | 這一個變數的存活時間，單位**分鐘**。省略＝不設到期，跟隨整個 session 的壽命；`expire="0"` ＝清除既有的到期設定。**需 2026-09 之後的引擎版本**，舊版會忽略此屬性（行為等同省略） |
| `cnd` | (選) | 條件式，成立時才執行寫入 |

```xml
<session name="usr" value="A"/>              <!-- A 為使用者輸入的帳號 -->
<session name="ord" value="''"/>             <!-- 清空購物車流水號 -->
<session name="usr" value="A" expire="480"/> <!-- 8 小時後自動失效 -->
<session name="lang" value="'tw'" cnd="DEFINE(request.lang)"/>
```

讀取端不使用 `<session>` 標籤，而是在運算式中以 `session.欄位` 前綴讀取（如 `session.usr`、`session.ord`），寫法與 `sys.*`、`request.*` 這類屬性前綴相同，詳見第七章 7.4 節。

**逐變數到期：`expire` 屬性**

同一個 session 裡的每個變數可以有各自的存活時間。引擎會在每次 HTTP 請求解析卡片**之前**先清掉已過期的變數——因此卡片裡的 `DEFINE(session.xxx)` 自然就看不到過期的值，不需要在每一頁自己判斷是否逾時。

```xml
<!-- 登入狀態 8 小時；購物車暫存只留 2 小時 -->
<session name="usr" value="A"   expire="480"/>
<session name="ord" value="S"   expire="120"/>

<!-- 之後若要延長，重新寫入同一個變數即可，到期時間從當下重新計算 -->
<session name="usr" value="session.usr" expire="480"/>
```

常用換算：`60`＝1 小時、`480`＝8 小時、`1440`＝1 天、`10080`＝7 天、`43200`＝30 天。

使用 `<delsession>` 刪除變數時，伴隨的到期戳會一併清除；`<clearsession>` 清空整個 session 自然也包含在內。

**Session 的三層壽命**

`expire` 只能讓變數「更早」失效，它之上還有兩道無法從 WML 突破的上限：

| 層級 | 控制方式 | 預設 | 行為 |
|---|---|---|---|
| session 變數 | `<session expire="分鐘"/>` | 無到期 | 逐變數計時，到期即刪 |
| 瀏覽器 cookie | 伺服器設定 | 關閉瀏覽器即失效 | 決定使用者「回得來」的期限 |
| 伺服器 session | 伺服器設定 | 閒置 7 天回收 | **閒置**逾時才回收，每次請求都會重設計時 |

session 資料存在伺服器記憶體，**伺服器重啟即全部消失**。因此 `expire` 設得比 cookie 或伺服器回收時間長沒有意義——使用者會先因為 cookie 失效或 session 被回收而登出；設計時應從最短的那一層往回推算。

#### `<operator>`

🌐 **Web** ✅ | 🖥️ **Win** ⚠️ | 📱 **Flutter** ❌

Web 模板中的運算輔助標籤，用於在模板區塊間傳遞簡單運算結果，減少在 HTML 內嵌過多 `$()` 運算式。

---

### 4.12 HTML 文字與版面標籤

📱 **Flutter**：本節全部標籤 ❌ 不適用。WapForm for Flutter 匯出的是原生 Dart／Flutter 元件樹，不經過 HTML；本節列出的內嵌 HTML 標籤僅存在於 Web 版輸出內容與 HTML 模板檔中，以下各表不再逐一重複標記。

WML 的輸出內容（無論是 `<wap>`、`<varblock>`、報表儲存格，還是 `<fieldset>` 裡的說明文字）都可以直接內嵌標準 HTML 標籤。以下是全書實際使用過的常見標籤，依用途分類。

#### 文字效果標籤（inline）

| 標籤 | 說明 |
|---|---|
| `<b>...</b>` | 粗體 |
| `<i>...</i>` | 斜體 |
| `<u>...</u>` | 底線 |
| `<small>...</small>` | 縮小字體，常用於註記或單位 |
| `<big>...</big>` | 放大字體 |
| `<ins>...</ins>` | 加註／強調插入內容，常見於備註欄位標記變更 |
| `<span class="...">...</span>` | 行內容器，無預設樣式，靠 `class` 或 `style` 控制外觀 |
| `<br/>` | 強制換行，空元素 |
| `<hr/>` | 水平分隔線，空元素 |

```xml
<p>單價：<b>$(FORMAT('%.2n',od.price))</b>　<small>（未稅）</small></p>
<span class="text-danger">逾期未收</span><br/>
```

#### 版面容器標籤（block）

| 標籤 | 常見屬性 | 說明 |
|---|---|---|
| `<div class="...">...</div>` | `class`、`id`、`style` | 區塊容器，Web 版面分區的主要容器 |
| `<section style="...">...</section>` | `style`、`class` | HTML5 語意區塊容器，常搭配 `$()` 運算式動態計算 `style`（見第九章 9.10 節 `var()`／`inc()` 跨區塊狀態函數） |
| `<p align="...">...</p>` | `align` | 段落 |
| `<article>...</article>` | — | 語意化內容區塊，用於手冊/文章內文（見 15.5 節手冊內文） |
| `<h1>...</h1>` ～ `<h6>...</h6>` | — | 標題層級，數字越小字級越大 |

```xml
<div class="card p-3">
  <h4>客戶資訊</h4>
  <p align="left">$(cu.cname)</p>
</div>

<!-- section 搭配 var()/inc() 產生循環變化的背景色 -->
<section style="background-color:$('#'+COLOR2HEX(color[inc('idx',1) mod 5]));">
  ...
</section>
```

#### 表格標籤

| 標籤 | 常見屬性 | 說明 |
|---|---|---|
| `<table>...</table>` | `class`、`width`、`border`、`cols`、`columns`、`rows` | 表格容器；`rows` 常用於連續報表固定行數（見 14.7 節） |
| `<tr>...</tr>` | — | 表格列 |
| `<th>...</th>` | `align`、`width` | 表頭儲存格 |
| `<td>...</td>` | `align`、`valign`、`class`、`width`、`colspan`、`rowspan` | 資料儲存格，`colspan`／`rowspan` 用於合併儲存格（見 12.11 節跨欄合計） |

```xml
<table class="wap" width="100%" border="1" rows="40">
  <tr>
    <th>單號</th><th>金額</th>
  </tr>
  <tr>
    <td>$(rpt_data.work_order_no)</td>
    <td align="right">$(FORMAT('%.2n',rpt_data.order_price))</td>
  </tr>
  <tr>
    <td colspan="4">製表:$aa.prepared_by</td>
  </tr>
</table>
```

**📱 Flutter**（`wapform_report.dart`、`wapform_report_style.dart`、`wapform_colors.dart`）

報表與 `WapPage(src:)` 輸出的就是 HTML，本節的 `<table>`／`<tr>`／`<td>` 等標籤照常使用，`class="wap"` 的格式由 `wapform_report_style.dart` 提供（螢幕 `reportCssScreen`、列印 `reportCssPrint`）。隔行色 `class="row1"`／`"row2"` 等，在 Flutter 畫面中可用 `WapColors` 取得同一份色彩：

```dart
Future<Color> stripe(int i) async {
  await WapColors.load();                        // 讀 assets/wapform.htm 的 CSS；讀不到用內建預設
  return i.isEven ? WapColors.trRow1 : WapColors.trRow2;  // 或 WapColors.flutter("row2")
}
```

`WapColors.hex("row2")` 傳回 CSS 色碼，可直接寫進報表 HTML。

#### 清單標籤

| 標籤 | 說明 |
|---|---|
| `<ul>...</ul>` | 無序清單容器 |
| `<ol>...</ol>` | 有序清單容器 |
| `<li>...</li>` | 清單項目，需為 `<ul>`／`<ol>` 的子標籤 |

```xml
<ul>
  <li>$(itm.title)</li>
</ul>
```

#### 連結與媒體標籤

| 標籤 | 常見屬性 | 說明 |
|---|---|---|
| `<a href="...">...</a>` | `href`、`class`、`op`、`pg`、`gp`、`az` | 超連結；Web 版選單/分頁連結常在 `href` 後帶自訂查詢參數（`op`、`pg`、`gp`、`az`），例如分頁連結 `shop.wml?op=$op&gp=$gp&pg=$K&az=$az` |
| `<img src="..." />` | `src`、`width`、`height`、`border`、`id` | 圖片，空元素；`src` 常搭配 `sys.GSWEB`／`sys.images` 組合完整路徑 |
| `<link rel="..." href="..." />` | `rel`、`href` | 外部樣式表或資源連結，用於 HTML 模板 `<head>` |
| `<script>...</script>` | `src`（外部）或內嵌 JS | 內嵌或載入 JavaScript，如 `loadDoc()` 的定義與呼叫（見 15.5 節） |

```xml
<a href="javascript:loadDoc('book-js.wml?pg=$itm.pno')">$itm.des</a>
<img src="$(sys.GSWEB+pa.pic1)" width="120" border="0"/>
```

#### 文件結構標籤（僅 Web HTML 模板使用）

| 標籤 | 說明 |
|---|---|
| `<html>...</html>` | HTML 文件根容器 |
| `<head>...</head>` | 文件標頭，內含 `<title>`、`<link>`、`<script>` |
| `<body>...</body>` | 文件主體 |
| `<title>...</title>` | 瀏覽器標題列文字 |

這些標籤只出現在 Web 版的 HTML 模板檔（如 `wapform.html`）本身，一般 `.wml` card 的輸出內容會被嵌入模板既有的 `<body>` 區塊中，不需要重複宣告。

---

### 4.13 標籤速查表

| 分類 | 標籤 |
|---|---|
| 文件與版面 | `wml`、`card`、`page`、`section`、`fieldset` |
| 資料存取 | `dbquery`、`dbtable`、`field`、`dbfilter` |
| 資料繫結與清單 | `datasource`、`dbgrid`、`item`、`navigator`、`column` |
| 表單輸入與互動 | `input`、`do`、`prev`、`alert`、`prompt` |
| 流程控制 | `if`／`elseif`／`else`、`switch`／`case`／`default`、`while`、`for`、`go`、`exit`、`function`、`block`、`platform` |
| 變數與資料集操作 | `setvar`、`setprop`、`getprop`、`invoke` |
| 報表輸出 | `report`、`group`、`newpage`、`varblock`、`debug` |
| 交叉列表與圖表 | `crosstab`、`row`、`col`、`chart`、`serie`、`point` |
| 導覽與選單 | `include`、`redirect`、`mainmenu`、`menuitem`、`tabsheet`、`pagecontrol` |
| 系統整合 | `mail`、`shellexecute`、`webcopy`、`open`、`upload`、`multiupload` |
| Web 專用 | `wap`、`session`、`operator` |
| HTML 文字效果 | `b`、`i`、`u`、`small`、`big`、`ins`、`span`、`br`、`hr` |
| HTML 版面容器 | `div`、`p`、`article`、`h1`–`h6` |
| HTML 表格 | `table`、`tr`、`th`、`td` |
| HTML 清單 | `ul`、`ol`、`li` |
| HTML 連結與媒體 | `a`、`img`、`link`、`script` |
| HTML 文件結構（僅模板檔） | `html`、`head`、`body`、`title` |

各標籤的完整使用情境與真實案例，可對照第三章核心模式、第十一至十六章實戰案例交叉閱讀。

📱 **Flutter 支援情形總覽**（依前述各節逐一標記，詳細依據見「平台支援標記說明」）：完全不支援的只有兩類——**交叉列表**（`crosstab`／`row`／`col`）與**圖表**（`chart`／`serie`／`point`），因行動裝置呈現限制，各付費版本皆不支援；**Web 專用標籤**（`wap`、`session`、`operator`）與僅存在於 Web 版的系統整合標籤（`mail`、`upload`、`multiupload`）、模板機制（`varblock`、`redirect`、`block`）亦不支援，因為 Flutter 匯出的是 Windows 元件模型而非 Web 模板機制；其餘表單、資料、主從結構、Lookup、計算欄位、事件、動態查詢、報表分組與分頁、多頁籤等核心能力均支援；少數 Windows 桌面專屬或本手冊未能從官網資料確認的標籤（如 `column`、`prompt`、`debug`、`mainmenu`／`menuitem`、`include`、`shellexecute`、`webcopy`、`open`）標為 ⚠️，實際行為請以 `wapform_flutter` 產生結果為準。

**📱 Flutter 模組對照**（只列有對應模組的標籤）

| 標籤 | 模組 | API |
|---|---|---|
| `card`（`device="PRV"`／`"PRN"`）、`page` | `wapform_report.dart` | `WapPage`、`PAGEPREFIX`／`PAGESUFFIX` |
| `dbquery`、`dbtable` | `wapform_lazarus.dart` | `DbQuery.query()`／`exec()`、`DataSetRegistry` |
| `dbfilter`、`item`（篩選） | `wapform_filter.dart` | `WapFilter`、`FilterItem` |
| `input lookup`、`item lookup` | `wapform_lookup_box.dart` | `WapLookupBox` |
| `if`、`switch`、`while` | `wapform_lazarus.dart` | `condition()`、`expression()` |
| `setvar`、`invoke` | `wapform_lazarus.dart` | `setvar()`、`invoke()` |
| `report`、`group`、`newpage` | `wapform_report.dart` | `WapReport`、`expression(idx)`、`forcePageBreak()` |
| `debug` | `wapform_expression.dart` | `getUserVars()`、`lastError` |
| `wap` | `wapform_report.dart` | `WapPage(src:)` |
| `platform` | （產生器） | `name="flutter"` 區塊原樣成為 Dart 程式碼 |
| `$(...)` 插值 | `wapform_lazarus.dart` | `expandText()`、`expandSql()`、`expandSqlAuto()`、`expandSqlQuoted()` |

---

---

## 第五章　陣列

## 5.1 宣告

WapForm 的陣列是以 `<setvar>` 設定的特殊 Variant 值，有三種宣告語法：

### 範圍宣告（預配置固定長度）

```xml
<!-- 整數範圍，元素初始值為 0 -->
<setvar name="X" value="[1..999]"/>
<setvar name="P" value="[0..1023]"/>
<setvar name="L" value="[1..26]"/>
```

宣告後陣列即可以 `X[i]` 存取；下界是範圍起始值（`1` 或 `0`），`low(X)` / `high(X)` 回傳下界 / 上界。

### 字面值宣告（直接指定初始內容）

```xml
<!-- 整數陣列 -->
<setvar name="L" value="[31,28,31,30,31,30,31,31,30,31,30,31]"/>

<!-- 字串陣列 -->
<setvar name="P" value="['代收','自取','月結','匯款']"/>

<!-- 色碼陣列 -->
<setvar name="C" value="['#ffeeee','#fff4ea','#ffffe3','#ebffec','#f1f4ff']"/>

<!-- 數值陣列 -->
<setvar name="myArray" value="[1, 2, 3, 4, 5]"/>
```

字面值陣列的下界為 `0`，上界為元素個數減一。

### 空值陣列

```xml
<!-- 全空字串 -->
<setvar name="VR" value="['','','','','','','','','','','','','','','']"/>

<!-- 全零 -->
<setvar name="XV" value="[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"/>
```

**📱 Flutter**（`wapform_lazarus.dart`：`setvar()`；`wapform_expression.dart`：`WapEvaluator.setVar()`）

三種宣告語法照寫在 `setvar()` 裡；Dart 端已有的 `List` 用 `_ev.setVar()` 放進引擎：

```dart
void declareArrays() {
  setvar("X", "[1..999]");                                        // 範圍宣告，初值 0
  setvar("L", "[31,28,31,30,31,30,31,31,30,31,30,31]");          // 字面值
  setvar("P", "['代收','自取','月結','匯款']");
  setvar("VR", "['','','','','']");                               // 空值陣列
  _ev.setVar("N", [10, 20, 30]);                                  // Dart 的 List
}
```

Dart 的陣列從 0 開始：範圍宣告 `[1..26]` 會建立索引 0～26 共 27 個元素，原本從 1 開始的索引照常可用，但 `LOW(X)` 傳回 0。

---

## 5.2 存取

### 讀取元素

```xml
<!-- 在運算式中直接索引 -->
<setvar name="days" value="L[month-1]"/>
<td>$(C[i MOD 5])</td>
<setvar name="sp" value="spec[j]"/>

<!-- 在輸出中插值 -->
<p>第一個元素：$(myArray[0])</p>
<p>第三個元素：$(myArray[2])</p>
```

### 寫入元素

```xml
<setvar name="X[K]" value="X[K]+N"/>
<setvar name="C[0]" value="'#ffeeee'"/>
<setvar name="mnu_title[k]" value="mnu.title"/>
```

索引可以是任意整數運算式，包括變數和函數回傳值。

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

寫入超出長度的索引時，陣列會自動延長（中間補 `null`），這點與 Windows 版「超出上界產生錯誤」不同。

---

## 5.3 陣列函數

| 函數 | 說明 | 備註 |
|---|---|---|
| `low(arr)` | 回傳陣列下界索引 | 字面值陣列為 `0`；範圍宣告為起始值 |
| `high(arr)` | 回傳陣列上界索引 | 即最後一個有效索引 |
| `COUNT(arr)` | 回傳陣列元素個數 | 等於 `high(arr) - low(arr) + 1` |

```xml
<!-- 遍歷所有元素 -->
<for int="i" from="low(spec)" to="high(spec)">
  <setvar name="sp" value="spec[i]"/>
  <block name="spec-option" id="name(sp)" opt="value(sp)"/>
</for>

<!-- 用 while 遍歷（Win/Web 均可） -->
<setvar name="I" value="low(L)"/>
<while cnd="I&lt;=high(L)">
  <setvar name="total" value="total+L[I]"/>
  <setvar name="I" value="I+1"/>
</while>
```

**📱 Flutter**（`wapform_expression.dart`）

`LOW()`、`HIGH()`、`COUNT()` 照常使用；另有可變參數的彙總函數 `ARRSUM`、`ARRAVG`、`ARRMAX`、`ARRMIN`、`ARRJOIN`（最後一個參數是分隔字元）、`ARRUNIQ`、`ARRCONTAINS`。

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

## 5.4 `name()` / `value()` 函數

當陣列元素是「鍵=值」格式的字串（如 `'顏色=紅色'`）時，`name()` / `value()` 可拆解鍵與值：

| 函數 | 說明 |
|---|---|
| `name(s)` | 回傳字串中 `=` 之前的部分（鍵） |
| `value(s)` | 回傳字串中 `=` 之後的部分（值） |

```xml
<setvar name="spec" value="['顏色=紅色','尺寸=XL','材質=棉']"/>
<for int="i" from="low(spec)" to="high(spec)">
  <setvar name="item" value="spec[i]"/>
  <!-- name(item) → '顏色' / value(item) → '紅色' -->
  <block name="spec-row" label="name(item)" val="value(item)"/>
</for>
```

**📱 Flutter**（`wapform_expression.dart`：`NAME()`、`VALUE()`）

```dart
List<String> specRows() {
  setvar("spec", "['顏色=紅色','尺寸=XL','材質=棉']");
  final rows = <String>[];
  setvar("i", "LOW(spec)");
  while (condition("i<=HIGH(spec)")) {
    setvar("item", "spec[i]");
    rows.add(expandText(r"$(NAME(item))：$(VALUE(item))"));   // 顏色：紅色 …
    setvar("i", "i+1");
  }
  return rows;
}
```

---

## 5.5 陣列作為計數器（報表累計）

報表輸出中最常見的陣列用途是**欄位累計**，以 crosstab 為例：

```xml
<!-- 宣告欄合計陣列與欄總計陣列 -->
<setvar name="X" value="[1..999]"/>   <!-- 群組合計，每組重置 -->
<setvar name="Y" value="[1..999]"/>   <!-- 全域總計，從不重置 -->

<!-- 在 crosstab 外層群組開始時重置欄合計 -->
<row change="xy.cno">
  <setvar name="I" value="1"/>
  <while cnd="I&lt;=99">
    <setvar name="X[I]" value="0"/>
    <setvar name="I" value="I+1"/>
  </while>
  ...
  <!-- 每個儲存格累計 -->
  <setvar name="K" value="K+1"/>
  <setvar name="X[K]" value="X[K]+N"/>
  <setvar name="Y[K]" value="Y[K]+N"/>
</row>

<!-- 輸出群組小計列 -->
<setvar name="I" value="1"/>
<while cnd="I&lt;=K">
  <td align="right">$(FORMAT('%d',X[I]))</td>
  <setvar name="I" value="I+1"/>
</while>
```

**📱 Flutter**（`wapform_report.dart`：在 `WapReport` 的區塊中累計）

```dart
// WapReport 子類別的 parseBlock() 片段：X 每組歸零、Y 從不歸零
void counterBlocks(String id) {
  switch (id) {
    case 'PREFIX':
      setvar("Y", "[1..999]");
      break;
    case 'G1_PREFIX':
      setvar("X", "[1..999]");                     // 重新宣告即歸零
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

## 5.6 陣列作為查找表

從資料集載入後用陣列作為記憶體查找表，避免重複查詢：

```xml
<!-- 從資料集載入選單資料至多個平行陣列 -->
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

<!-- 後續以索引直接存取，不需再查資料庫 -->
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

## 5.7 陣列作為色彩對照表

```xml
<!-- 依索引對應 Bootstrap 樣式類別 -->
<setvar name="btn" value="[0..9]"/>
<setvar name="btn[0]" value="'btn-primary'"/>
<setvar name="btn[1]" value="'btn-secondary'"/>
<setvar name="btn[2]" value="'btn-success'"/>
<setvar name="btn[3]" value="'btn-warning'"/>
<setvar name="btn[4]" value="'btn-danger'"/>

<!-- 使用時 -->
<block name="card-url" style="btn[I MOD 5]" link="midb(s,i+1,j-i-1)"/>
```

```xml
<!-- 月份天數表（考慮閏年時另處理 2 月） -->
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

## 5.8 資料集的陣列式存取

`<dbquery>` 資料集可以 `.FIELDS[n]` 按欄位位置存取（1-based）：

```xml
<dbquery id="ds"><![CDATA[SELECT col1, col2, col3 FROM t]]></dbquery>

<!-- 按位置取欄位值 -->
<setvar name="v1" value="ds.FIELDS[1]"/>   <!-- col1 -->
<setvar name="v2" value="ds.FIELDS[2]"/>   <!-- col2 -->
```

資料集的 `COUNT`、`EOF`、`BOF` 屬性不是陣列，但行為類似：

| 運算式 | 說明 |
|---|---|
| `ds.COUNT` | 查詢結果的總列數 |
| `ds.EOF` | 游標是否在最後一筆之後（布林） |
| `ds.BOF` | 游標是否在第一筆之前（布林） |
| `ds.FIELDS[n]` | 按欄位位置（1-based）取當前記錄的欄位值 |

**📱 Flutter**（`wapform_lazarus.dart`：`ds.FIELDS[n]`）

`ds.FIELDS[n]`（從 1 開始）、`ds.COUNT`、`ds.EOF`、`ds.BOF` 在 Flutter 一樣可用：

```dart
Future<void> fieldsByPosition() async {
  await db.query("ds", "SELECT col1, col2, col3 FROM t");
  setvar("v1", "ds.FIELDS[1]");                    // col1
  setvar("v2", "ds.FIELDS[2]");                    // col2
}
```

---

## 5.9 限制與注意事項

**無二維陣列**　WapForm 不支援 `arr[i][j]`，需以平行一維陣列模擬：

```xml
<!-- 模擬二維：用命名規則區分維度 -->
<setvar name="row1" value="[0..9]"/>
<setvar name="row2" value="[0..9]"/>
```

**索引從宣告的起始值開始**　範圍宣告 `[1..26]` 的起始索引是 `1`，而字面值宣告 `[a,b,c]` 的起始索引是 `0`。混用時要特別注意 `low()` 的回傳值。

**無動態擴充**　陣列長度在宣告時固定，無法在執行期新增元素。超出上界存取會產生錯誤。

**`while` 迴圈重置**　在同一 card 內的 `<while>` 迴圈重置陣列是標準模式，不需要重新宣告整個陣列：

```xml
<!-- 清空而非重新宣告 -->
<setvar name="I" value="1"/>
<while cnd="I&lt;=99">
  <setvar name="X[I]" value="0"/>
  <setvar name="I" value="I+1"/>
</while>
```

**📱 Flutter**（Dart 運算式引擎）

| 項目 | Windows／Web | Flutter |
|---|---|---|
| 二維陣列 | 不支援 | 不支援 |
| 起始索引 | 依宣告（範圍宣告可從 1 起） | 一律從 0 起（`[1..n]` 會多一個索引 0，`LOW()` 為 0） |
| 動態擴充 | 不可 | `setvar("X[i]", ...)` 超出長度時自動延長 |
| 重置 | `while` 逐格歸零 | 重新宣告 `setvar("X", "[1..99]")` 即可 |

---

## 第六章　運算式與函數庫

WapForm 的運算式出現在所有接受動態值的屬性中（`cnd`、`value`、`message`、`href`、`device` 等），以及 HTML 輸出中的 `$variable` 與 `$(expression)` 插值。

---

## 6.1 插值語法

| 語法 | 用途 | 範例 |
|---|---|---|
| `$varname` | 簡單變數替換 | `$total`、`$ds.field` |
| `$(expression)` | 計算任意運算式後輸出 | `$(FORMAT('%.2f',total))`、`$(IF(qty>0,'有','無'))` |

兩者可混合使用：

```xml
<td>$(sys.GSWEB+pa.pic1)</td>
<setvar name="label" value="'訂單 '+sn.order_no+' 共 '+STR(total)+'元'"/>
```

**📱 Flutter**（`wapform_lazarus.dart`：`expandText()`、`expandSql()`、`expandSqlAuto()`、`expandSqlQuoted()`）

四個展開函數都認得 `$名稱`、`$(運算式)`、`$$`（輸出一個 `$`），並把反引號 `` ` `` 換成 `'`；差別在值怎麼插入：

| 函數 | 值怎麼插入 | 適用 |
|---|---|---|
| `expandText(s)` | 原樣 | 畫面文字、報表 HTML |
| `expandSql(s)` | 原樣 | 插入整段 SQL 條件（`$S`）；`DbQuery.query()` 預設用這個 |
| `expandSqlAuto(s)` | 字串自動加單引號並跳脫，數字不加 | 插入單一值 |
| `expandSqlQuoted(s)` | 一律加單引號並跳脫 | 插入單一值 |

```dart
void expandDemo() {
  _ev.setVar("cname", "O'Brien");
  debugPrint(expandSql(r"where cname='$cname'"));            // where cname='O'Brien'   ← 會壞掉
  debugPrint(expandSqlAuto(r"where cname=$cname"));          // where cname='O''Brien'  ← 正確
  debugPrint(expandSql(r"where cname=$(AsQuoted(cname))"));  // 同上
  debugPrint(expandText(r"$(sys.GSWEB+pa.pic1) 共 $$100"));  // $$ → $
}
```

---

## 6.2 運算子

### 算術

| 運算子 | 說明 | 範例 |
|---|---|---|
| `+` | 加法；若任一運算元為字串則為字串串接 | `qty * price`、`'代號:'+sn.code` |
| `-` | 減法 | `total - discount` |
| `*` | 乘法 | `sn.qty * sn.price` |
| `/` | 除法（浮點） | `AZ/AY*100` |
| `MOD` | 取餘數（整數） | `seq MOD 2` |
| `DIV` | 整數除法 | `n DIV 3` |

### 比較

| 運算子 | XML 屬性中寫法 | 說明 |
|---|---|---|
| `=` | `=` | 等於 |
| `<>` | `&lt;&gt;` | 不等於 |
| `<` | `&lt;` | 小於 |
| `>` | `&gt;` | 大於 |
| `<=` | `&lt;=` | 小於或等於 |
| `>=` | `&gt;=` | 大於或等於 |

> XML 屬性（`cnd`、`value` 等）中的角括號**必須**以實體編碼表示。`<![CDATA[...]]>` 內則可直接寫 `<`、`>`。

### 邏輯

| 運算子 | 說明 | 範例 |
|---|---|---|
| `AND` | 邏輯且 | `qty>0 AND active='Y'` |
| `OR` | 邏輯或 | `status='A' OR status='B'` |
| `NOT(expr)` | 邏輯非（函數形式） | `NOT(ds.EOF)` |

### 字串串接

`+` 在任一運算元為字串時自動切換為串接：

```xml
<setvar name="S" value="S+' AND dept=`'+filter+'`'"/>
<setvar name="key" value="FORMAT('%3.3d',YEAR(DATE)-1911)+FORMAT('%2.2d',MONTH(DATE))"/>
```

### 優先順序（高到低）

1. 函數呼叫、括號 `()`
2. 乘除　`*`　`/`　`MOD`　`DIV`
3. 加減 / 串接　`+`　`-`
4. 比較　`=`　`<>`　`<`　`>`　`<=`　`>=`
5. `NOT`
6. `AND`
7. `OR`

**📱 Flutter**（`wapform_expression.dart`：`WapEvaluator`）

Dart 引擎與 Windows 版的差別：

- **`AND`／`OR` 兩側的比較要加括號**：`(qty>0) AND (active='Y')`。寫成 `qty>0 AND active='Y'` 時回報 `Invalid end token`，`condition()` 傳回 `false`。
- Dart 字串中直接寫 `<`、`>`，不需要 `&lt;`、`&gt;`。
- 整數與整數做 `+`、`-`、`*` 結果是整數，其餘（含 `/`）是浮點數。

直接使用引擎：

```dart
void evaluatorDemo() {
  final ev = WapEvaluator();
  ev.setVar("qty", 3);
  ev.setVar("price", 99.5);
  final total = ev.eval("qty*price");                // 298.5
  final ok = ev.cond("(qty>0) AND (price<100)");     // true
  ev.addFunction1Param("TAXED", (v) => (v as num) * 1.05); // 自訂函數
  debugPrint("$total $ok ${ev.eval("TAXED(100)")}"); // 298.5 true 105.0
}
```

| `WapEvaluator` 成員 | 說明 |
|---|---|
| `eval(expr, {nul})`／`evalNul(expr)` | 計算運算式；出錯時 `lastError` 有內容 |
| `cond(expr)` | 計算條件，傳回 `bool` |
| `setVar(name, value)`／`getVar(name)` | 讀寫變數（值不經計算） |
| `setRow(table, map)` | 一次設定一整列：`table.欄位` 與 `欄位` 兩種名稱都設 |
| `clearVars()`／`getUserVars()` | 清除／列出使用者變數 |
| `addFunction0Param`～`addFunction4Param`、`addFunctionAParam` | 註冊 0～4 個參數或可變參數的自訂函數（同名已存在時不覆蓋） |
| `datasetResolver` | 資料集解析器（`useEngine()` 會設成 `DataSetRegistry.resolveDataSet`） |
| `hasError`／`lastError` | 錯誤狀態 |

函數的 Flutter 差異見附錄 C。

---

## 第七章　資料集物件參考

WapForm 的資料集（dataset）是一個帶有游標的記錄集物件，以 `<dbquery id="ds">` 或 `<dbtable name="ds">` 宣告。宣告後，資料集的欄位值、狀態屬性和 Lookup 前綴，都可以在運算式中直接引用。

---

## 7.1 欄位值存取

### `ds.fieldname`

存取資料集 `ds` 當前記錄的 `fieldname` 欄位值。

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

運算式找得到的資料集，必須已註冊在 `useEngine()` 指定的 `DataSetRegistry`（`db.query()` 會自動註冊）。

### 寫入欄位（透過 `<setvar>`）

將資料集 id 與欄位名稱串接作為 `<setvar>` 的 `name`：

```xml
<!-- oh 資料集的 order_date 欄位 -->
<setvar name="ohorder_date" value="DATE"/>

<!-- sn 資料集的 material_name 欄位 -->
<setvar name="snmaterial_name" value="luppm.material_name"/>
```

命名規則：`{dataset_id}{fieldname}`，無分隔符號。

**📱 Flutter**（`wapform_lazarus.dart`：`setvar("ds.欄位", ...)`）

```dart
void writeFields() {
  setvar("oh.order_date", "DATE");                   // ohorder_date
  setvar("sn.material_name", "pm.material_name");    // snmaterial_name
}
```

Flutter 用 `ds.欄位`（中間有點），不用 `ohorder_date` 這種串接名稱。

---

## 7.2 資料集狀態屬性

### `ds.COUNT`

查詢結果的總列數（整數）。

```xml
<if cnd="em.COUNT=0">
  <alert message="查無資料"/>
  <exit/>
</if>
<if cnd="xx.count&gt;0">
  <!-- 有既存記錄時走此路徑 -->
</if>
```

**📱 Flutter**：`condition("em.COUNT=0")`，也可寫 `em.RECORDCOUNT`。

### `ds.EOF`

游標是否在最後一筆記錄**之後**（布林）。迭代到結尾時為 `True`。

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

游標是否在第一筆記錄**之前**（布林）。剛開啟空資料集時為 `True`。

```xml
<newpage cnd="not(cu.bof)"/>
```

**📱 Flutter**：`condition("not(cu.bof)")`。

### `ds.FIELDS[n]`

按欄位位置（1-based）取當前記錄的欄位值，不需要知道欄位名稱。

```xml
<dbquery id="ds"><![CDATA[SELECT col1, col2, col3 FROM t]]></dbquery>
<setvar name="v1" value="ds.FIELDS[1]"/>   <!-- col1 -->
<setvar name="v2" value="ds.FIELDS[2]"/>   <!-- col2 -->
```

**📱 Flutter**：`setvar("v1", "ds.FIELDS[1]")` 照常可用（從 1 開始）。

### `ds.state` *(Windows 專用)*

資料集目前的編輯狀態字串。

| 值 | 說明 |
|---|---|
| `'BROWSE'` | 瀏覽模式（唯讀） |
| `'EDIT'` | 編輯模式 |
| `'INSERT'` | 新增模式 |

```xml
<if cnd="em.state='INSERT'">
  <!-- 新增模式時自動填入建立日期 -->
  <setvar name="emcreate_date" value="DATE"/>
</if>
```

**📱 Flutter**：`ds.STATE` 在 Flutter 也可用，傳回 `BROWSE`、`EDIT`、`INSERT` 或 `INACTIVE`：`if (condition("em.state='INSERT'")) setvar("em.create_date", "DATE");`

---

## 7.3 Lookup 前綴（`lup{dataset}`）

當 `<input>` 使用 `lookup` 屬性，使用者從 Lookup 清單選取記錄後，系統自動建立一個以 `lup` 為前綴的臨時資料集，可讀取所選列的所有欄位。

```xml
<input field="material_code" lookup="pm;material_code;material_name" size="12">
  <onevent type="oncloseup">
    <!-- lup + dataset_id = luppm -->
    <setvar name="snmaterial_name" value="luppm.material_name"/>
    <setvar name="snunit_price"    value="luppm.unit_price"/>
  </onevent>
</input>
```

**格式：** `lup{dataset_id}.{fieldname}`

**Lookup 屬性格式：** `"dataset_id;key_field;display_field"`

| 部分 | 說明 |
|---|---|
| `dataset_id` | 查詢來源的資料集 id（`<dbquery id>` 或 `<dbtable name>`） |
| `key_field` | 寫回目標欄位的鍵值欄位 |
| `display_field` | 在輸入框中顯示的欄位 |

**SQL-based Lookup：**

```xml
<input field="color_no"
       lookup="sql;color_no;SELECT color_no, color_name FROM colors ORDER BY color_no"
       size="10">
  <onevent type="oncloseup">
    <setvar name="sncolor_name" value="lupyy.color_name"/>
    <!-- dataset_id 為 sql 時前綴固定為 lupyy -->
  </onevent>
</input>
```

**📱 Flutter**（`wapform_lookup_box.dart`：`WapLookupBox`）

Flutter 不另外建立 `luppm` 資料集；`onPicked` 收到所選的代號，要讀所選列的其他欄位時，把來源資料集移到那一列（範例見第 3.4 節）。`WapLookupBox` 參數：

| 參數 | 說明 |
|---|---|
| `value` | 目前的代號（必填） |
| `dataSet` ＋ `keyField` ＋ `displayFields` | 由資料集產生清單（對應 `lookup="ds;key;display"`） |
| `lookupItems` | 單欄清單 `{代號: 顯示文字}` |
| `lookupColumns` ＋ `colWidths` | 多欄清單 `{代號: [欄1, 欄2, ...]}` 與各欄寬度 |
| `onPicked` | 從下拉清單選定時呼叫（對應 `oncloseup`） |
| `onChanged` | 打字輸入或失去焦點回填時呼叫 |
| `readOnly` | 唯讀 |
| `width`／`height`／`textStyle` | 外觀（預設 130 × 28） |
| `autofocus`、`tapRegionGroupId` | 焦點控制 |
| `forGrid`、`onTab`、`onTabPrev` | 放在表格儲存格內（無框線、Tab 跳格） |

---

## 7.5 Web 環境物件

### `request.*`

存取 HTTP GET / POST 請求的參數值。參數名稱直接以欄位名稱形式引用。

| 模式 | 說明 |
|---|---|
| 讀取 | `$request.gp`、`$(val(request.pg))` |
| 存在檢查 | `DEFINE(request.gp)` |

**標準讀取模式（含預設值）：**

```xml
<setvar name="gp" value="'0001'"/>
<setvar name="gp" value="request.gp" cnd="DEFINE(request.gp)"/>

<setvar name="pg" value="1"/>
<setvar name="pg" value="val(request.pg)" cnd="DEFINE(request.pg)"/>
```

**操作分派模式：**

```xml
<if cnd="DEFINE(request.del)">
  <dbquery><![CDATA[DELETE FROM rn WHERE sno='$session.ord']]></dbquery>
  <redirect href="cart.wml"/>
  <exit/>
</if>
<if cnd="DEFINE(request.ok)">
  <!-- 確認提交 -->
</if>
```

---

### `session.*`

存取伺服器端 session 變數，跨 HTTP 請求保持使用者狀態。

| 操作 | 語法 |
|---|---|
| 讀取 | `$session.usr`、`$(session.ord)` |
| 寫入 | `<session name="usr" value="A"/>` |
| 限時寫入 | `<session name="usr" value="A" expire="480"/>`（480 分鐘後失效，需 2026-09 後引擎版本） |
| 條件寫入 | `<session name="lang" value="request.lang" cnd="DEFINE(request.lang)"/>` |
| 清除 | `<session name="usr" value="''"/>` |
| 存在檢查 | `DEFINE(session.usr)` |

**Session 生命週期管理：**

```xml
<!-- 登入：設定 session -->
<session name="usr" value="A"/>     <!-- A 為使用者輸入的帳號 -->
<session name="ord" value="''"/>    <!-- 清空舊購物車 -->
<redirect href="index.wml"/>

<!-- 登出：清除所有 session -->
<session name="usr" value="''"/>
<session name="ord" value="''"/>
<redirect href="index.wml"/>

<!-- Session 守衛：未登入導向登入頁 -->
<if cnd="NOT(DEFINE(session.usr))">
  <redirect href="login.wml"/>
  <exit/>
</if>
```

**逐變數到期（`expire`）：**

`expire` 以分鐘為單位，讓同一個 session 內的各變數有不同壽命。引擎在每次請求解析卡片之前會先清掉過期的變數，所以讀取端不必額外判斷——`DEFINE(session.usr)` 自然就是 false。

```xml
<!-- 登入狀態 8 小時、購物車暫存 2 小時 -->
<session name="usr" value="A" expire="480"/>
<session name="ord" value="S" expire="120"/>

<!-- 需要續期就重新寫入，到期時間從當下重算 -->
<session name="usr" value="session.usr" expire="480"/>
```

`expire` 之上還有 cookie 與伺服器 `SessionTimeout` 兩道上限，設得比它們長不會生效；完整說明與屬性表見第四章 4.11 節 `<session/>`，實作案例見第十五章 15.9 節。

---

## 7.6 報表環境特殊變數

這些變數由報表引擎自動維護，只在 `<report>` / `<crosstab>` 的輸出環境中有效。

### `$(PAGE)`

當前頁碼，從 `1` 開始，框架自動遞增。

```xml
<th align="right">第 $(PAGE) 頁</th>
```

**📱 Flutter**（`wapform_report.dart`：`wap.wapPageNo`）

Dart 引擎不會自動設定 `PAGE`；在 `PAGEPREFIX` 區塊把頁碼放進引擎：

```dart
// WapReport 子類別的 parseBlock() 片段
void pageNoBlock(String id) {
  if (id == 'PAGEPREFIX') {
    currentEvaluator!.setVar("PAGE", wap.wapPageNo);
    emit(expandText(r'<p align="right">第 $(PAGE) 頁</p>'));
  }
}
```

### `cell`（`<crosstab>` 內）

在 `<crosstab>` 的 `<col change>` 標籤內，`cell` 自動對應當前正在渲染的欄位值，無需手動引用 `$ds.fieldname`。

```xml
<col change="xy.area">
  <setvar name="C" value="cell"/>              <!-- cell = xy.area 的當前值 -->
  <setvar name="R" value="cell" cnd="col=1"/> <!-- 第一欄時記錄列標頭 -->
  <if cnd="row&lt;3">
    <th>$(IF(cell='',' ',cell))</th>
  <else/>
    <setvar name="N" value="VAL(cell)"/>
  </if>
</col>
```

### `row` / `col`（`<crosstab>` 內）

在 `<crosstab>` 的渲染過程中，框架維護當前的列座標（`row`）和欄座標（`col`），均為 1-based 整數。

```xml
<if cnd="(row&lt;3) or (col&lt;3)">
  <!-- 標頭區（前兩列或前兩欄） -->
  <th width="60">...</th>
<else/>
  <!-- 資料區 -->
  <td align="right">...</td>
</if>
```

| 座標 | 說明 |
|---|---|
| `row=1` | 第一個 `<row change>` 欄位的標頭行 |
| `row=2` | 第二個 `<row change>` 欄位的標頭行 |
| `row>2` | 資料列 |
| `col=1` | 第一個 `<col change>` 欄位的標頭欄 |
| `col=2` | 第二個 `<col change>` 欄位的標頭欄 |
| `col>2` | 資料欄 |

---

## 7.7 資料集方法速查

透過 `<invoke>` 呼叫。

| 方法 | Win | Web | 說明 |
|---|---|---|---|
| `First` | ✅ | ✅ | 移至第一筆記錄 |
| `Last` | ✅ | ✅ | 移至最後一筆記錄 |
| `Next` | ✅ | ✅ | 移至下一筆記錄 |
| `Prior` | ✅ | ✅ | 移至上一筆記錄 |
| `locate` | ✅ | ✅ | 依鍵值定位記錄 |
| `post` | ✅ | ⚠️ | 儲存目前記錄的修改 |
| `cancel` | ✅ | ⚠️ | 放棄目前記錄的修改 |
| `refresh` | ✅ | ⚠️ | 重新執行查詢，從資料庫重新載入 |
| `edit` | ✅ | ❌ | 切換至編輯模式 |
| `insert` | ✅ | ❌ | 新增一筆空白記錄 |
| `delete` | ✅ | ❌ | 刪除當前記錄 |
| `open` | ✅ | ⚠️ | 開啟資料集（執行查詢） |
| `close` | ✅ | ⚠️ | 關閉資料集 |
| `GetBookmark` | ✅ | ❌ | 取得當前游標位置書籤，存入 `result` 變數 |
| `GoToBookmark` | ✅ | ❌ | 回到指定書籤位置 |
| `FreeBookmark` | ✅ | ❌ | 釋放書籤記憶體 |
| `DisableControls` | ✅ | ❌ | 凍結 UI 更新（迭代期間用） |
| `EnableControls` | ✅ | ❌ | 恢復 UI 更新 |

**書籤模式**（Windows 環境迭代繫結資料集的標準做法）：

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

`First`、`Last`、`Next`、`Prior`、`post`、`cancel`、`edit`、`insert`、`delete`、`GetBookmark`、`GoToBookmark`、`FreeBookmark`、`DisableControls`、`EnableControls` 都可用 `invoke("ds", "方法")` 呼叫（不分大小寫）；`refresh`／`open` 改用 `db.query("ds", sql)` 重新查詢。書籤模式：

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

**畫面同步：**`setvar()` 改了一般變數時，會呼叫 `varChangeHooks` 裡的每個函式，畫面可以藉此更新顯示該變數的輸入框：

```dart
late final void Function(String) _onVar = (name) {
  if (name.toUpperCase() == "TOTAL" && mounted) setState(() {});
};
void hookVars() => varChangeHooks.add(_onVar);       // 畫面初始化時
void unhookVars() => varChangeHooks.remove(_onVar);  // 畫面釋放時
```

---

## 第八章　Windows 版系統登入與權限控制

🖥️ **Win 專用**

---

## 8.1 三層協同架構

WapForm for Windows 的登入與權限系統由三個層次協同運作，各司其職：

```
┌─ 層次一：資料庫 ─────────────────────────────────────────┐
│  users 資料表：帳號 / 密碼 / 群組                         │
│  mnu   資料表：選單定義（id, title, href, sub）            │
│  login 資料表：每位使用者、每個選單項目的權限值 w           │
└───────────────────────────────────────────────────────────┘
           ↓ 登入驗證通過後
┌─ 層次二：wapform.wml ────────────────────────────────────┐
│  查詢 mnu LEFT JOIN login                                 │
│  login.w 決定：                                           │
│    ① 選單項目是否可點擊（menuitem enabled）                │
│    ② 框架的執行期 LoginLevel 數值                          │
└───────────────────────────────────────────────────────────┘
           ↓ 使用者點選選單開啟功能
┌─ 層次三：各功能 .wml ────────────────────────────────────┐
│  <author level="n"> 包住一組輸入欄位                       │
│  框架比對 LoginLevel > n？                                 │
│    是 → Writable=False → 欄位唯讀                         │
│    否 → Writable=True  → 欄位可寫                         │
└───────────────────────────────────────────────────────────┘
```

---

## 8.2 登入對話框

框架內建，無需開發者撰寫 UI，應用程式啟動時自動彈出。

| 欄位 | 說明 |
|---|---|
| **Computer** | 資料庫伺服器連線位址（`http://host:port/path/`），記錄歷史連線 |
| **Username** | 使用者帳號，框架注入為全域變數 `$username` |
| **Password** | 使用者密碼，框架注入為全域變數 `$password` |
| **Connect** | 確認連線，載入 `wapform.wml` |
| **Cancel** | 取消，關閉應用程式 |

`$username` 與 `$password` 在整個 `wapform.wml` 執行期間全域有效。

---

## 8.3 身分驗證

```xml
<card id="P" title="mainmenu" device="MDI">

  <!-- 查詢帳號 -->
  <dbquery id="usr">
    select pwd from users where userid='$username'
  </dbquery>

  <!-- 帳號不存在 → 回登入對話框 -->
  <if cnd="usr.count=0">
    <alert message="Account does not exist"/>
    <prev/>
  </if>

  <!-- 密碼錯誤（UPPER() 不分大小寫比對） -->
  <if cnd="upper(usr.pwd)&lt;&gt;upper(password)">
    <alert message="Password error"/>
    <prev/>
  </if>

  ...
</card>
```

`<prev/>` 在 MDI card 中的行為是**回到登入對話框**，讓使用者重試，不關閉應用程式。

> **安全建議：** 正式環境以 `MD5()` 儲存密碼雜湊：
> ```xml
> <if cnd="usr.pwd&lt;&gt;MD5(password)">
> ```

---

## 8.4 選單建構與 LoginLevel 設定

驗證通過後，`wapform.wml` 以兩層 `<while>` 動態建構主選單，同時透過 LEFT JOIN 讀取每個選單項目對當前使用者的權限值 `w`：

```xml
<setvar name="K" value="0"/>

<!-- 查詢頂層選單群組（sub=-1） -->
<dbquery id="sub"><![CDATA[
  select id, title, href from mnu
  where active=1 and sub=-1
  order by id
]]></dbquery>

<mainmenu images="imagelist1">
  <while cnd="NOT(sub.EOF)">
    <menuitem caption="$sub.title" hint="sub">

      <!-- 子項目查詢：LEFT JOIN 取權限值 w -->
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
        <setvar name="I" value="-1"/>                              <!-- 預設無權限 -->
        <setvar name="I" value="itm.w" cnd="itm.w&gt;0"/>         <!-- 有記錄且 w>0 才更新 -->

        <setvar name="K" value="K+1"/>
        <setvar name="ID" value="'A'+FORMAT('%3.3d',K)"/>

        <menuitem name="$ID" caption="$(itm.title)"
                  hint="$itm.href" imageindex="$I" onclick="$itm.href"/>

        <setprop name="$ID" prop="enabled" value="0" cnd="I=-1"/> <!-- 無權限則停用 -->

        <invoke instance="itm" method="Next"/>
      </while>
    </menuitem>
    <invoke instance="sub" method="Next"/>
  </while>
</mainmenu>
```

### 選單項目啟用邏輯

| `login` 記錄狀態 | `itm.w` | `I` | `menuitem` |
|---|---|---|---|
| 無記錄（LEFT JOIN → NULL） | NULL | `-1` | 停用（灰色，不可點） |
| 記錄存在，`w = 0` | `0` | `-1` | 停用 |
| 記錄存在，`w > 0` | `w` 值 | `w` 值 | **啟用**，`imageindex` 顯示對應圖示 |

`imageindex` 同時承擔圖示索引與權限旗標兩個角色：`-1` 表示無圖示，同時觸發 `enabled=0`。

### LoginLevel 的來源

框架在建構選單過程中，將每次讀到的 `itm.w`（有效值）記錄為該使用者的執行期 `LoginLevel`。**`login.w` 就是 `LoginLevel` 的唯一來源。**

---

## 8.5 欄位區塊權限：`<author>` 標籤

`<author>` 將一組輸入欄位包成一個**可寫性受控的區塊**。框架渲染到 `<author>` 時，先判斷 `level` 屬性決定 `Writable` 旗標，再渲染內部的所有子節點（`<input>`、`<table>` 等）。

### 語法

```xml
<author level="n" color="#RRGGBB" yy="row" cnd="expr">
  <!-- 受控的輸入欄位群組 -->
</author>
```

### 屬性

| 屬性 | 必/選 | 說明 |
|---|---|---|
| `level="n"` | 選 | 可寫權限門檻。`LoginLevel > n` 時區塊內所有 `<input>` 唯讀；省略或 `n=0` 時一律可寫。 |
| `color="#RRGGBB"` | 選 | 暫時覆蓋區塊內標籤文字色，`</author>` 後自動還原。 |
| `yy="n"` | 選 | 設定當前列號（`Wap.CurrentLine`），控制版面位置。 |
| `cnd="expr"` | 選 | 保留屬性，目前版本不影響渲染邏輯。 |
| `id="name"` | 選 | 區塊識別碼，保留供程式定位。 |

### 權限比對規則

**數字越小，權限越高。** `LoginLevel > level` 為真時唯讀：

| 使用者 `LoginLevel` | `<author level="1">` | `<author level="2">` | `<author level="3">` | `<author>` |
|---|---|---|---|---|
| `1`（最高） | ✅ 可寫 | ✅ 可寫 | ✅ 可寫 | ✅ 可寫 |
| `2` | ❌ 唯讀 | ✅ 可寫 | ✅ 可寫 | ✅ 可寫 |
| `3` | ❌ 唯讀 | ❌ 唯讀 | ✅ 可寫 | ✅ 可寫 |
| `5`（最低） | ❌ 唯讀 | ❌ 唯讀 | ❌ 唯讀 | ✅ 可寫 |

---

## 8.6 實戰範例：訂單簽核區塊

以下是 `order.wml` 的實際用法，簽核欄位以 `<author>` 包住，確保只有特定人員能填寫：

```xml
<!-- 一般業務欄位：無 level，所有登入使用者均可編輯 -->
<author>
  <table columns="7" align="LLLLLLL"><tr>
    <td>工廠出貨日1：<input field="factory_ship_date_1" size="12"/>
                     <input field="factory_ship_qty_1"  size="12"/></td>
    <td width="10"></td>
    <td>ETD1：<input field="etd_1" size="12"/></td>
    <td width="10"></td>
    <td>INVOICE NO.1：<input field="invoice_no_1" size="20"/></td>
    <td width="10"></td>
    <td>收款日期1：<input field="payment_date_1" size="12"/></td>
  </tr></table>
</author>

<!-- 母船 / ETA：另一組業務欄位 -->
<author>
  <table columns="3" align="LLL">
    <tr>
      <td>母船1：<input field="vessel_1" size="40"/></td>
      <td>ETA1：<input field="eta_1" size="12"/></td>
      <td width="500"></td>
    </tr>
    <tr>
      <td>母船2：<input field="vessel_2" size="40"/></td>
      <td>ETA2：<input field="eta_2" size="12"/></td>
      <td></td>
    </tr>
    <tr>
      <td>母船3：<input field="vessel_3" size="40"/></td>
      <td>ETA3：<input field="eta_3" size="12"/></td>
      <td></td>
    </tr>
    <tr>
      <td>母船4：<input field="vessel_4" size="40"/></td>
      <td>ETA4：<input field="eta_4" size="12"/></td>
      <td></td>
    </tr>
  </table>
</author>

<!-- 簽核列：依業務慣例，通常搭配 level 控制只有主管才能填寫 -->
<author>
  <table columns="6" align="CCCCCC"><tr>
    <td>審核：<input field="approved_by" size="12"
          lookup="sql;approved_by;select distinct username from users where grp='A'"/></td>
    <td>業務：<input field="sales_rep" size="12"
          lookup="sql;sales_rep;select distinct username from users where grp='B'"/></td>
    <td>採購：<input field="buyer_rep" size="12"
          lookup="sql;buyer_rep;select distinct username from users where grp='C'"/></td>
    <td>製表：<input field="prepared_by" size="12"
          lookup="sql;prepared_by;select distinct username from users where grp='D'"/></td>
    <td>填表日期：<input field="form_date" size="14"/></td>
    <td>傳送日期：<input field="fax_date" size="14"/></td>
    <td><input value="生產指令表" type="button" onclick="@BOM"/></td>
  </tr></table>
</author>

<!-- 單一欄位也可獨立受控 -->
<author>
  樣品單號：<input field="sample_no" size="20"/>
</author>
```

**`<author>` 不帶 `level=` 的實際意義：**

在現有專案中，`<author>` 幾乎全部不帶 `level=` 屬性——`Level` 預設為 `0`，Delphi 端 `if Level > 0` 不成立，`Writable` 始終為 `True`。此時 `<author>` 的作用是**語意標記**：明確標示哪些欄位在業務上屬於「需授權才應修改」的簽核區域，為日後啟用 `level=` 機制預留架構位置。

---

## 8.7 完整資料流

```
使用者輸入帳號 / 密碼
          ↓
framework 注入 $username, $password
          ↓
wapform.wml 執行：
  ① 查詢 users WHERE userid='$username'
     → 驗證 pwd（UPPER 比對 或 MD5）
     → 失敗 → <alert> + <prev/>（回對話框）
  ② 查詢 mnu LEFT JOIN login WHERE uid='$username'
     → login.w > 0  → menuitem enabled，imageindex=w
     → login.w 缺/0 → menuitem disabled，imageindex=-1
     → 框架記錄 LoginLevel = w
          ↓
使用者點選選單項目，開啟 xxx.wml
          ↓
框架渲染到 <author level="n"> 時：
  比對 Wap.LoginLevel > n ？
  True  → Writable=False → 區塊內 <input> 全部唯讀（灰底）
  False → Writable=True  → 區塊內 <input> 全部可編輯（白底）
  </author> → Writable 恢復 True
          ↓
使用者操作表單（可寫欄位正常存取，唯讀欄位只能查看）
```

---

## 8.8 資料庫設計參考

```sql
-- 使用者帳號表
CREATE TABLE users (
  userid  VARCHAR(20) PRIMARY KEY,
  pwd     VARCHAR(100),   -- MD5 雜湊
  grp     VARCHAR(5)      -- 功能群組：A=審核 B=業務 C=採購 D=製表
);

-- 選單定義表
CREATE TABLE mnu (
  id      VARCHAR(10) PRIMARY KEY,
  sub     VARCHAR(10),    -- 父選單 id；-1 = 頂層群組
  title   VARCHAR(50),
  href    VARCHAR(100),
  active  INT DEFAULT 1
);

-- 使用者選單權限表
CREATE TABLE login (
  uid     VARCHAR(20),    -- 對應 users.userid
  id      VARCHAR(10),    -- 對應 mnu.id
  w       INT             -- 權限值（1=最高，數字越大權限越低）
);

-- 建議的 w 值配置
-- w=1：系統管理員（可編輯 level="1" 以下所有區塊）
-- w=2：主管 / 審核（可編輯 level="2" 以下區塊）
-- w=3：一般作業員（可編輯 level="3" 以下區塊）
-- w=5：唯讀查詢帳號（僅無 level 的 <author> 可寫）

-- 範例：三個使用者，三種權限
INSERT INTO users VALUES ('admin',  MD5('admin123'), 'A');
INSERT INTO users VALUES ('mgr01',  MD5('mgr001'),   'A');
INSERT INTO users VALUES ('sales1', MD5('sales001'), 'B');

-- 選單群組
INSERT INTO mnu VALUES ('10', '-1', '銷售管理', '',            1);
INSERT INTO mnu VALUES ('20', '-1', '庫存管理', '',            1);
INSERT INTO mnu VALUES ('11', '10', '訂單查詢', 'order.wml',  1);
INSERT INTO mnu VALUES ('12', '10', '訂單建檔', 'order.wml',  1);
INSERT INTO mnu VALUES ('21', '20', '庫存查詢', 'inv.wml',    1);

-- admin（w=1）：全功能
INSERT INTO login VALUES ('admin', '11', 1);
INSERT INTO login VALUES ('admin', '12', 1);
INSERT INTO login VALUES ('admin', '21', 1);

-- mgr01（w=2）：可查詢與建檔，但 order.wml 中 level="1" 的區塊唯讀
INSERT INTO login VALUES ('mgr01', '11', 2);
INSERT INTO login VALUES ('mgr01', '12', 2);

-- sales1（w=3）：只能查詢訂單；order.wml 中 level="2" 以上區塊唯讀
INSERT INTO login VALUES ('sales1', '11', 3);
-- sales1 沒有 '12' 的 login 記錄 → 「訂單建檔」選單項目停用
```

---

## 8.9 設計要點總結

| 機制 | 控制範圍 | 判斷條件 |
|---|---|---|
| `login.w = 0` 或無記錄 | 選單項目停用（不可點進功能） | `I=-1` → `<setprop enabled=0>` |
| `login.w > 0` | 選單項目啟用，同時設定 `LoginLevel` | `itm.w` 寫入 `I` 與 `Wap.LoginLevel` |
| `<author>` 無 `level` | 所有使用者均可編輯 | `Level=0`，`if Level>0` 不成立 |
| `<author level="n">` | `LoginLevel > n` 的使用者唯讀 | Delphi：`Writable := False` |
| `imageindex="$I"` | 圖示 + 權限雙重旗標 | `-1` 無圖示且觸發停用 |
| `UPPER()` 密碼比對 | 帳號不分大小寫 | 建議升級為 `MD5()` |
| `<prev/>` 驗證失敗 | 回登入對話框，允許重試 | MDI card 的 `<prev/>` 語意 |

---

## 第九章　Web 模板系統

第八章　套表機制（Template Binding）

🌐 **Web 專用**

---

## 9.1 概念：WML 驅動 HTML 模板

WapForm for Web 的核心特色之一是**套表機制**：一份靜態的 HTML 模板（如 `wapform.html`）定義完整的視覺骨架，WML 程式則負責邏輯、資料查詢與內容輸出。兩者在執行期由框架合體，最終輸出完整的 HTML 頁面。

用一句話說清楚它的本質：

> **WapForm 的套表機制實現了版面驅動的組件注入——不是程式主動組裝頁面，而是模板定義頁面結構，程式只需宣告版面，框架自動完成串接。**

這帶來幾個關鍵優點：

- **視覺與邏輯徹底分離**：前端設計師維護 HTML/CSS，後端邏輯只在 `.wml` 中撰寫，互不干擾。
- **一套模板，全站共用**：換模板就換整個網站外觀，WML 邏輯完全不需改動。
- **版面可以獨立演進**：設計師把側欄從右移到左、增加新區域，WML 邏輯零修改；後端改了查詢，HTML 也零修改。
- **可接入任何 HTML 框架**：Bootstrap、Metronic、Tailwind——只要是靜態 HTML 都能套用。

---

## 9.2 觸發區塊（Triggered Block）——套表機制的大特色

觸發區塊是 WapForm 在同類框架中最獨特的設計，也是「版面驅動的組件注入」這個概念的具體實現。

### 問題：傳統框架的程式碼知道太多

大多數框架（PHP、Django、Rails、Laravel Blade）的頁面組裝是**程式主導**的：

```php
// 程式碼決定要組裝什麼、放在哪裡
$this->render('layout', [
    'header'   => $this->renderHeader(),
    'sidebar'  => $this->renderSidebar($category),
    'content'  => $this->renderContent($articles),
    'footer'   => $this->renderFooter(),
]);
```

程式碼必須知道版面有哪些區域、每個區域傳什麼資料。版面改了（比如增加一個「相關推薦」欄），程式碼就要跟著改。前後端實際上是耦合的。

### WapForm 的做法：模板主導，程式只宣告版面

```xml
<!-- WML 程式碼只需宣告版面名稱 -->
<block name="onnote"/>
<!-- 完畢。框架自動完成剩下的一切 -->
```

這一行觸發了 `wapform.html` 中 `onnote` 區塊的輸出，而該區塊裡已經安排好所有的 `#(card_id)` 注入點——框架看到 `#(breadcrumb)` 就去執行 `breadcrumb` sub card，看到 `#(content)` 就去執行 `content` sub card，看到 `#(side)` 就去執行 `side` sub card。**程式碼完全不知道、也不需要知道版面有幾個區域、各放在哪裡。**

```
傳統框架需要寫：               WapForm 只需要一行：

  include('header.php')
  include('breadcrumb.php')    →    <block name="onnote"/>
  include('sidebar.php')
  include('content.php')
  include('footer.php')
```

### 這帶來真正的工程優勢

因為版面結構只存在於 `wapform.html` 一個地方，所以：

- 設計師把 `onnote` 的側欄從右移到左——WML 零修改
- 設計師在 `onnote` 中增加 `#(related)` 推薦區塊——只需新增對應的 sub card，WML 主流程零修改
- 後端改了 `content` card 的查詢邏輯——HTML 零修改

前後端可以真正獨立演進，而不只是「分開放在不同檔案」。

### 隱性命名契約

這個設計有一個需要誠實說明的代價：**模板中的 `#(card_id)` 名稱與 WML 中的 sub card `id` 必須完全一致**，這是一個隱性的命名契約，沒有靜態型別系統幫你檢查。如果 sub card 的 `id` 打錯字，那個區域就靜默地空白，不會拋出錯誤。

開發時的建議：先確認模板裡用了哪些 `#(...)` 注入點名稱，再照著建立 sub card，而不是反過來。

### note.wml 完整範例解析

`note.wml` 是觸發區塊機制的最佳示範：一個知識庫文件頁面，包含麵包屑、右側目錄欄、左側文章內容，三個區域完全獨立，僅靠一行觸發：

```xml
<?xml version="1.0"?>
<wml>
  <card id="P" device="wapform.html">

    <!-- 1. 讀取 URL 參數 -->
    <setvar name="gp" value="'note'"/>
    <setvar name="gp" value="request.gp" cnd="DEFINE(request.gp)"/>

    <!-- 2. 向上追溯分類層級，找到最上層分類 id（最多三層） -->
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

    <!-- 3. 組裝頁面 -->
    <block name="wapform.aa"/>
    <block name="wrapper.aa"/>
    <include name="header"/>

    <!-- ★ 關鍵：一行觸發 onnote 版面，自動串接三個 sub card -->
    <block name="onnote"/>

    <include name="footer"/>
    <include name="footer2"/>
    <block name="wrapper.zz"/>
    <block name="wapform.zz"/>
  </card>

  <!-- sub card 1：麵包屑 -->
  <card id="breadcrumb" device="sub">
    <block name="breadcrumb" one="category"/>
  </card>

  <!-- sub card 2：右側目錄欄 -->
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

  <!-- sub card 3：主內容區 -->
  <card id="content" device="sub">
    <dbquery id="pa"><![CDATA[
      select pno, gid, des, typ, topic
      from pa where gid='$gp' and active>0 order by pno
    ]]></dbquery>
    <if cnd="pa.count&gt;0">
      <!-- 有子項目：輸出文章列表卡片 -->
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
      <!-- 無子項目：AJAX 載入文章內文 -->
      <![CDATA[<div id="note"></div>
      <script>loadDoc('note','note-js.wml?pg=$gp');</script>]]>
    </if>
  </card>

</wml>
```

### 觸發區塊的執行流程

`<block name="onnote"/>` 這一行觸發了以下完整流程：

```
<block name="onnote"/>
         │
         ▼
wapform.html 中 <!-- onnote.aa --> 區塊開始輸出
┌─────────────────────────────────────────────────────┐
│  #(breadcrumb)                                      │
│      └─► 執行 <card id="breadcrumb" device="sub">  │
│           <block name="breadcrumb" one="category"/> │
│           輸出「首頁 > 操作手冊」麵包屑 HTML         │
│                                                     │
│  <div class="d-flex flex-column flex-xl-row">       │
│    <div class="flex-lg-row-fluid">                  │
│      #(content)                                     │
│          └─► 執行 <card id="content" device="sub"> │
│               查詢 pa where gid='$gp'              │
│               if 有子項目 → 輸出文章卡片列表        │
│               else        → 輸出 AJAX 載入腳本      │
│    </div>                                           │
│    <div class="mw-lg-300px">                        │
│      #(side)                                        │
│          └─► 執行 <card id="side" device="sub">   │
│               查詢選單資料庫，while 輸出目錄樹      │
│    </div>                                           │
│  </div>                                             │
└─────────────────────────────────────────────────────┘
<!-- onnote.zz -->
```

對應 `wapform.html` 中的模板定義：

```html
<!-- onnote.aa -->
#(breadcrumb)
<div class="d-flex flex-column-fluid align-items-start container-xxl xyz">
    <div class="content flex-row-fluid py-10 xyz">
        <div class="d-flex flex-column flex-xl-row p-7 xyz">

            <div class="flex-lg-row-fluid me-xl-15 mb-20 xyz">
                #(content)      ← 主內容：文章列表或 AJAX 文章
            </div>

            <div class="flex-column flex-lg-row-auto mw-lg-300px mw-xxl-350px">
                <div class="card-rounded bg-primary bg-opacity-5 p-10 cls">
                    #(side)     ← 側邊欄：目錄樹
                </div>
            </div>

        </div>
    </div>
</div>
<!-- onnote.zz -->
```

**重點**：三個 sub card（`breadcrumb`、`content`、`side`）各自獨立撰寫邏輯，完全不需要知道彼此的存在，也不需要知道自己被放在頁面的哪個位置——版面配置完全由模板決定。

---

## 9.3 HTML 模板的結構：區塊標記

`wapform.html` 用 HTML 註解標記所有**具名區塊**的邊界，命名慣例為 `blockname.aa`（開始）/ `blockname.zz`（結束）：

```html
<!-- wapform.aa -->
<head>
  <title>...</title>
  <link rel="stylesheet" href="assets/css/style.bundle.css"/>
  <!-- $(var('idx',-1)) -->  ← 初始化跨區塊計數器
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
  $(menu)                    ← varblock 注入點

  <!-- onnote.aa -->
  #(breadcrumb)              ← sub card 注入點
  <div ...>
    #(content)               ← sub card 注入點
    #(side)                  ← sub card 注入點
  </div>
  <!-- onnote.zz -->

  <!-- footer.aa -->
  <div>
    $(sys.company)
    <!-- footer-item.aa --><a href="$(app).wml?gp=$(itm.pno)">$itm.des</a><!-- footer-item.zz -->
  </div>
  <!-- footer.zz -->
  $(footer)                  ← varblock 注入點

<!-- wrapper.zz -->
<!-- wapform.zz -->
<script src="assets/js/scripts.bundle.js"></script>
```

### 標記語法說明

| 語法 | 說明 |
|---|---|
| `<!-- blockname.aa -->` | 具名區塊開始 |
| `<!-- blockname.zz -->` | 具名區塊結束 |
| `#(card_id)` | Sub card 注入點，框架自動呼叫對應 sub card |
| `$(varname)` | 變數或 varblock 累積結果注入點 |

---

## 9.4 版面模式：`<block name="on..."/>` 的選擇

`wapform.html` 內預先定義多種版面，每種版面內的 `#(...)` 注入點排列不同。WML 只需呼叫一行，版面就確定：

| `<block name="..."/>` | 版面說明 | 注入點 |
|---|---|---|
| `onreport` | 標準版面：麵包屑 + 全寬內容 | `#(breadcrumb)` `#(content)` |
| `onshop` | 電商版面：麵包屑 + 左側欄 + 主內容 | `#(breadcrumb)` `#(side)` `#(content)` |
| `onfull` | 全寬版面：麵包屑 + 無側欄 | `#(breadcrumb)` `#(content)` |
| `onnote` | 文件版面：麵包屑 + 主內容 + 右側欄 | `#(breadcrumb)` `#(content)` `#(side)` |
| `onzero` | 最小版面：僅麵包屑 + 內容 | `#(breadcrumb)` `#(content)` |
| `onpage` | 文章版面：帶 padding 卡片框 | `#(breadcrumb)` `#(content)` |
| `onlogin` | 登入版面：居中卡片，無頂部導覽 | `#(content)` |

**同一套 sub card，搭配不同版面區塊，就能產生完全不同的頁面結構**，WML 邏輯完全不用改：

```xml
<block name="onnote"/>    → 文件版面：左主文 + 右目錄
<block name="onfull"/>    → 全寬版面：主文無側欄
<block name="onlogin"/>   → 登入版面：居中卡片
```

---

## 9.5 notebar 目錄樹：side sub card 詳解

`note.wml` 的 `side` card 示範了在 sub card 內執行**雙層巢狀查詢**，動態組裝可展開的目錄樹：

```xml
<card id="side" device="sub">
  <block name="notebar.aa"/>        ← 目錄容器開頭（含分類標題 $category）

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
      <!-- 有子項目：可展開的群組 -->
      <block name="notebar-list.aa"/>
      <while cnd="not(itm.eof)">
        <block name="notebar-item"/>
        <invoke instance="itm" method="next"/>
      </while>
      <block name="notebar-list.zz"/>
    <else/>
      <!-- 無子項目：葉節點連結 -->
      <block name="notebar-mark"/>
    </if>

    <invoke instance="mnu" method="next"/>
  </while>

  <block name="notebar.zz"/>
</card>
```

對應 `wapform.html` 中的四個目錄區塊：

```html
<!-- notebar.aa -->
<div class="menu menu-column" id="kt_docs_aside_menu" data-kt-menu="true">
    <div class="menu-item">
        <h4 class="menu-content text-muted mb-0 fs-7">$category</h4>
    </div>

    <!-- notebar-mark.aa -->
    <!-- 葉節點：直接連結，點擊 AJAX 載入文章 -->
    <div class="menu-item">
        <a class="menu-link py-2"
           href="javascript:loadDoc('note','note-js.wml?pg=$mnu.pno')">
            <span class="menu-title">$mnu.des</span>
        </a>
    </div>
    <!-- notebar-mark.zz -->

    <!-- notebar-list.aa -->
    <!-- 群組節點：可展開，含子項目 -->
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

目錄的每個連結都是 `javascript:loadDoc(...)`，點擊時不跳頁，直接用 AJAX 替換主內容區的文章——這是下一節的重點。

---

## 9.6 AJAX 按需載入與 `<wap>` 標籤

### content sub card 的兩種路徑

`note.wml` 的 `content` card 依資料情況分兩條路徑：

```xml
<card id="content" device="sub">
  <dbquery id="pa"><![CDATA[
    select pno, gid, des, typ, topic
    from pa where gid='$gp' and active>0 order by pno
  ]]></dbquery>

  <if cnd="pa.count&gt;0">
    <!-- 路徑 A：gp 是分類節點，有子項目 → 輸出文章卡片列表 -->
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
    <!-- 路徑 B：gp 是葉節點，直接是文章 → AJAX 載入內文 -->
    <![CDATA[
    <div id="note"></div>
    <script>loadDoc('note','note-js.wml?pg=$gp');</script>
    ]]>
  </if>
</card>
```

**路徑 A**：`gp` 指向分類，下面還有子文章，輸出文章卡片讓使用者選擇。

**路徑 B**：`gp` 直接指向一篇文章，為了不讓主頁框架等待長文章的載入，改用 AJAX 按需取得。

### `loadDoc()` — 模板內建的 AJAX 函數

`wapform.html` 在 `<head>` 中預先宣告：

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

兩種使用場景：

**場景一**：content card 路徑 B，頁面載入完成後立即呼叫：

```html
<div id="note"></div>
<script>loadDoc('note', 'note-js.wml?pg=$gp');</script>
```

**場景二**：notebar 目錄連結，使用者點擊時呼叫，替換同一個 `<div id="note">`：

```html
<a href="javascript:loadDoc('note', 'note-js.wml?pg=$itm.pno')">
    $itm.des
</a>
```

兩處都指向 `note-js.wml`，只是觸發時機不同。頁面框架只建立一次，文章內文可以無限次替換。

### `note-js.wml` 與 `<wap>` 標籤

`note-js.wml` 是專為 AJAX 回應設計的極簡 WML：

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

**`device="wapform-js.html"`** — 使用輕量模板，不含完整頁面骨架（無 header、footer、選單），只輸出純 HTML 片段。

**`<wap>` 標籤** — Web 環境專用，標記「僅在 Web 模式下輸出此段內容」。查詢資料庫取得 `pa.topic`（文章 HTML 內文），包在 `<article>` 中回傳。

AJAX 請求 `note-js.wml?pg=500120001` 的回應是純 HTML 片段：

```html
<article>
  （文章 HTML 內文）
</article>
```

`loadDoc()` 收到後直接填入 `<div id="note">`，頁面不重新載入，框架結構（header、目錄欄）保持不動。

### 整體資料流

```
使用者進入 note.wml?gp=500100
        │
        ▼
主 card：向上追溯三層分類，設定 id, category
        │
        ▼
<block name="onnote"/> 觸發

  ├─ #(breadcrumb) → breadcrumb card
  │    <block name="breadcrumb" one="category"/>
  │    → 輸出「首頁 > 操作手冊」
  │
  ├─ #(content) → content card
  │    查詢 pa where gid='500100'
  │    if pa.count > 0
  │      → 輸出文章卡片列表（shop-note 區塊）
  │    else
  │      → 輸出空 div + loadDoc('note','note-js.wml?pg=500100')
  │         │  頁面載入後 AJAX 呼叫
  │         └─► note-js.wml?pg=500100
  │               查詢 pa where pno='500100'
  │               <wap> 輸出 <article>$pa.topic</article>
  │               ↩ 回傳純 HTML 片段，填入 <div id="note">
  │
  └─ #(side) → side card
       查詢 mnu where gid='$id'（最上層分類的子項）
       while 每個一級項目
         查詢 itm（二級項目）
         if itm.count > 0
           → notebar-list.aa + notebar-item × N + notebar-list.zz
             每個 notebar-item 連結：
             javascript:loadDoc('note','note-js.wml?pg=$itm.pno')
         else
           → notebar-mark（葉節點，同樣指向 loadDoc）
       → 目錄樹完成

使用者點擊目錄連結
  → loadDoc('note','note-js.wml?pg=500120001')
  → AJAX 取得新文章 HTML
  → 填入 <div id="note">（不重新載入整頁）
```

---

## 9.7 三種內容注入機制

WapForm 套表共有三種注入方式，各有適用場景：

### `#(card_id)` — Sub Card 同步注入

框架輸出模板 HTML 時，遇到 `#(card_id)` 立即執行對應 sub card：

```html
#(breadcrumb)   ← 同步執行 <card id="breadcrumb" device="sub">
#(content)      ← 同步執行 <card id="content"    device="sub">
#(side)         ← 同步執行 <card id="side"       device="sub">
```

### `$(varname)` — varblock 預累積注入

在 WML 流程中，`<varblock>` 逐段累積 HTML 到具名變數，模板末尾的 `$(varname)` 一次插入：

```xml
<report dataset="mnu">
  <varblock name="footer" block="footer.aa"/>
    <varblock name="footer" block="footer-item"/>
  <varblock name="footer" block="footer.zz"/>
</report>
```

```html
$(footer)    ← 插入累積完成的整段 footer HTML
$(footer2)
```

### `loadDoc()` — AJAX 非同步注入

預留空 div，頁面載入後或使用者點擊時，非同步從輕量 WML 取得 HTML 片段填入：

```html
<div id="note"></div>
<script>loadDoc('note', 'note-js.wml?pg=$gp');</script>
```

**三種機制對照：**

| 機制 | 觸發時機 | 適用場景 | 宣告方式 |
|---|---|---|---|
| `#(card_id)` | 框架輸出模板時同步執行 | 主內容區、麵包屑、側欄 | sub card + 模板注入點 |
| `$(varname)` | WML 流程預累積，一次輸出 | 選單、頁尾等累積型結構 | `<varblock>` + 模板變數 |
| `loadDoc()` | 頁面載入後或使用者點擊 | 長文章、按需替換 | 空 div + JS + 輕量 WML |

---

## 9.8 兩種 HTML 模板

| 特性 | `wapform.html` | `wapform-js.html` |
|---|---|---|
| 用途 | 完整頁面骨架 | AJAX 回應的純內容片段 |
| 包含 | CSS/JS/header/footer/選單 | 僅最小包裝 |
| WML `device` 值 | `"wapform.html"` | `"wapform-js.html"` |
| 搭配標籤 | `<block>`、sub card、`<varblock>` | `<wap>` |
| 注入機制 | `#(card_id)`、`$(varname)` | `loadDoc()` AJAX |

---

## 9.9 `<block>` 呼叫時的參數傳遞

`<block>` 呼叫模板區塊時，可附帶任意屬性作為具名參數，區塊 HTML 中以 `$attributename` 取用：

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
    <li><a href="index.wml">首頁</a></li>
    <li>$one</li>       ← 取用傳入的 one 參數（= category 變數的值）
    <li>$category</li>
</ul>
<!-- breadcrumb.zz -->
```

參數值支援完整 WapForm 運算式，呼叫時求值後傳入。

---

## 9.10 模板內的運算式與狀態函數

`wapform.html` 中可直接使用 WapForm 運算式，框架套表時一併求值：

```html
<h6>$(sys.company)</h6>
<a href="$(app).wml?gp=$(itm.pno)">$itm.des</a>
<ins class="$(IF(pa.pricec&gt;0,'text-red',''))">
    特價$(IF(pa.pricea&gt;pa.price1,99999,pa.price1))
</ins>
<section style="background-color:$('#'+COLOR2HEX(color[inc('idx',1) mod 5]));">
```

### `var()` 和 `inc()` — 模板跨區塊狀態函數

| 函數 | 說明 |
|---|---|
| `var('name', default)` | 讀取狀態變數；不存在則以 `default` 初始化並回傳 |
| `inc('name', step)` | 遞增狀態變數 `step` 後回傳新值 |

```html
<!-- wapform.aa 中初始化 -->
<!-- $(var('idx',-1)) -->

<!-- 每個輸出區塊自動遞增，產生 5 色循環背景 -->
<section style="background-color:$('#'+COLOR2HEX(color[inc('idx',1) mod 5]));">
```

`var()` / `inc()` 的狀態在整個頁面請求週期內持續有效，跨越多個 sub card 的輸出也能共享計數。

---

## 9.11 完整對應關係：note.wml ↔ wapform.html

```
note.wml                               wapform.html
─────────────────────────────────────────────────────────────────────
<card id="P" device="wapform.html">    ← 指定模板

向上追溯三層分類                       （主 card 純流程，不涉及模板）
設定 id, category

<block name="wapform.aa"/>             <!-- wapform.aa -->
                                       <head>CSS/JS</head><body>
                                       <!-- $(var('idx',-1)) -->

<block name="wrapper.aa"/>             <!-- wrapper.aa -->
                                       <div class="d-flex flex-column...">

<include name="header"/>               ← header.wml 執行，輸出導覽列
                                       模板 $(menu) 插入選單 varblock 結果

<block name="onnote"/>                 ← ★ 觸發區塊
                                       <!-- onnote.aa -->
                                       #(breadcrumb)
  <card id="breadcrumb" device="sub">  ├─ breadcrumb card 執行
    <block name="breadcrumb"           │    <!-- breadcrumb.aa -->
           one="category"/>            │    首頁 > $one（= category）
                                       │    <!-- breadcrumb.zz -->
                                       <div class="flex-xl-row">
                                         <div class="flex-lg-row-fluid">
                                           #(content)
  <card id="content" device="sub">     ├─ content card 執行
    if pa.count > 0                    │    路徑 A：輸出文章卡片列表
      <block name="shop-note"/> × N    │    路徑 B：輸出空 div + loadDoc()
    else                               │            ↓ AJAX
      loadDoc('note','note-js.wml')    │      note-js.wml
                                       │      <wap> <article>$pa.topic
                                         </div>
                                         <div class="mw-lg-300px">
                                           #(side)
  <card id="side" device="sub">        └─ side card 執行
    notebar.aa                              目錄樹 HTML
    while mnu                               每個連結：loadDoc(...)
      if itm.count > 0
        notebar-list + notebar-item × N
      else
        notebar-mark
    notebar.zz
                                       </div>
                                       <!-- onnote.zz -->

<include name="footer"/>               footer card → varblock → $footer
<include name="footer2"/>              footer2 card → varblock → $footer2
                                       模板末尾 $(footer)$(footer2) 插入

<block name="wrapper.zz"/>             <!-- wrapper.zz --> </div>
<block name="wapform.zz"/>             <!-- wapform.zz --> JS </body>
```

---

## 9.12 套表機制小結

| 規則 | 說明 |
|---|---|
| `device="wapform.html"` | 主 card 指定模板，框架以此 HTML 為骨架 |
| `device="wapform-js.html"` | AJAX 片段專用輕量模板，搭配 `<wap>` 使用 |
| `device="sub"` | 注入點對應的 sub card，只輸出 HTML 片段 |
| `<block name="on..."/>` | 觸發版面區塊，一行自動串接所有 `#(...)` 注入點 |
| `<block name="x"/>` | 呼叫模板中 `<!-- x.aa -->` 到 `<!-- x.zz -->` 的 HTML |
| `#(card_id)` | 模板注入點，框架同步執行對應 sub card |
| `$(varname)` | 插入 WapForm 變數或 varblock 累積結果 |
| `<varblock>` | 迴圈中逐段累積 HTML 到具名變數 |
| `loadDoc(id, url)` | AJAX 按需載入，填入指定 div |
| `<wap>` | AJAX 回應 WML 中，標記只輸出此段 HTML |
| 區塊參數 | `<block name="x" param="val"/>` 傳入，區塊內以 `$param` 取用 |
| `var()` / `inc()` | 模板內跨區塊計數狀態，用於循環色彩等場景 |

---

## 第十章　圖表

第九章　圖表功能（Chart）

🖥️ **Win** ✅ | 🌐 **Web** ✅

---

## 10.1 概觀

WapForm 的 `<chart>` 元素讓開發者不需撰寫任何 JavaScript，即可在 WML 中直接宣告產生互動式圖表。圖表資料來源有兩種方式：

- **資料集驅動**：綁定 `<dbquery>` 資料集，欄位自動對應軸線。
- **程式產生**：在 `<serie>` 內以 `<while>` 或 `<for>` 迴圈搭配 `<point>` 逐筆注入資料點。

兩種方式可混用，且同一張 `<chart>` 支援多個 `<serie>`（多數列），能在同一圖表中疊加不同圖型。

---

## 10.2 基本結構

```xml
<chart title="圖表標題" ...圖表屬性...>
  <serie type="圖型" ...數列屬性...>
    <!-- 資料來源：二選一 -->

    <!-- 方式一：程式產生資料點 -->
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(100,300)"/>
    </while>

    <!-- 方式二：綁定資料集（在 <chart> 層宣告 dataset，此處省略 <point>） -->
  </serie>

  <!-- 可加入第二條數列 -->
  <serie type="line" ...>...</serie>
</chart>
```

---

## 10.3 `<chart>` — 圖表容器屬性

| 屬性 | 必/選 | 說明 |
|---|---|---|
| `title` | 選 | 圖表標題文字 |
| `dataset` | 選 | 綁定資料集名稱（資料集驅動模式） |
| `rangeto` | 選 | X 軸最大刻度值（用於資料集模式的軸範圍） |
| `legend` | 選 | `"yes"` 顯示圖例 |
| `autocolor` | 選 | `"yes"` 自動為各資料點套用不同顏色（圓餅類圖表常用） |
| `xaxisposition` | 選 | X 軸位置；設為 `"none"` 隱藏 X 軸 |
| `yaxisposition` | 選 | Y 軸位置；設為 `"none"` 隱藏 Y 軸 |
| `titlefontsize` | 選 | 標題字型大小（點數） |
| `xresult` | 選 | 將圖表輸出結果存入指定變數（如 `"s"`） |

---

## 10.4 `<serie>` — 數列屬性

### 通用屬性（所有圖型）

| 屬性 | 必/選 | 說明 |
|---|---|---|
| `type` | 必 | 圖型種類（見 10.6 節完整列表） |
| `color` | 選 | 填充色（`#RRGGBB`），用於 bar、area、pie 等有面積的圖型 |
| `linecolor` | 選 | 線條色（`#RRGGBB`），用於 line、digitalline |
| `linewidth` | 選 | 線條寬度（像素） |
| `opacity` | 選 | 透明度（0–255，用於 area 類型） |
| `marker` | 選 | `"yes"` 在資料點顯示標記點（用於 line） |
| `valuewidth` | 選 | 資料點寬度（像素，用於 bar） |
| `title` | 選 | 數列名稱（顯示於圖例） |

### 資料集綁定屬性

| 屬性 | 必/選 | 說明 |
|---|---|---|
| `fieldnamevalue` | 選 | 數值欄位名稱（資料集驅動模式） |
| `fieldnamexaxis` | 選 | X 軸標籤欄位名稱；設為 `"no"` 使用自動序號 |

### 圓餅 / 環圈類專屬屬性

| 屬性 | 必/選 | 說明 |
|---|---|---|
| `pielegend` | 選 | `"yes"` 顯示圓餅圖例 |
| `pieposition` | 選 | `"custom"` 自訂圓餅位置 |
| `pieleft` | 選 | 圓餅中心 X 座標（像素） |
| `pietop` | 選 | 圓餅中心 Y 座標（像素） |
| `piesize` | 選 | 圓餅半徑（像素） |
| `pieshowvalues` | 選 | `"yes"` 在切片上顯示數值 |
| `pieshowlegendonslice` | 選 | `"yes"` 在切片上顯示標籤 |
| `pievalueposition` | 選 | `"outside"` 數值標籤顯示在切片外側 |

---

## 10.5 `<point>` — 資料點

```xml
<point label="標籤文字" value="數值" color="C[I mod 5]"/>
```

| 屬性 | 必/選 | 說明 |
|---|---|---|
| `label` | 必 | X 軸標籤或圖例名稱；支援運算式 |
| `value` | 必 | Y 軸數值；支援運算式（含函數、變數） |
| `color` | 選 | 個別資料點顏色（陣列索引或 `#RRGGBB`） |

`<point>` 通常放在 `<while>` 或 `<for>` 迴圈內動態產生，也可靜態逐筆列出。

---

## 10.6 圖型完整列表

WapForm 支援 12 種圖型，依類別分組：

### 折線類

#### `line` — 折線圖

連續數值趨勢，支援多數列疊加。

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

- `dataset="xy"` 綁定查詢結果，`fieldnamevalue` 指定數值欄位。
- `marker="yes"` 在每個資料點加上標記圓點。
- 多個 `<serie>` 自動疊加在同一圖表。

#### `digitalline` — 數位折線圖

階梯狀折線，適合表達離散狀態切換（如開關、0/1 值）。負值支援。

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

### 長條類

#### `bar` — 群組長條圖

並排長條，適合多類別比較。

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

- `valuewidth` 控制每根長條的寬度。
- 多個 `<serie>` 並排顯示（群組模式）。

#### `stackedbar` — 堆疊長條圖

多數列數值垂直堆疊，適合呈現組成比例與總量。

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

#### `histogram` — 直方圖

單數列長條，支援負值（長條向下延伸），適合頻率分布。

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

### 面積類

#### `area` — 面積圖

折線下方填色，`opacity` 控制透明度，適合趨勢與量的視覺化。

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

- `opacity="150"` 設定填色透明度（0=全透明，255=不透明），多數列交疊時可看到底層。

#### `stackedarea` — 堆疊面積圖

多數列面積垂直堆疊，適合同時呈現個別量與合計趨勢。

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

### 圓餅類

圓餅類圖表通常隱藏 X/Y 軸（`xaxisposition="none" yaxisposition="none"`），並透過一組 `pie*` 屬性控制外觀。

#### `pie` — 圓餅圖

各切片面積等比例，適合占比呈現。每個 `<point>` 可以個別指定顏色。

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

- 顏色陣列 `C[]` 在圖表外預先宣告，`<point color="C[I mod 5]">` 逐一套用。
- `pievalueposition="outside"` 將數值標籤顯示在切片外側。

#### `donut` — 環圈圖

圓餅中央挖空，適合搭配中央文字說明。`autocolor="yes"` 讓框架自動配色。

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

#### `sizedpie` — 比例圓餅圖

切片面積以圓的大小表示（非角度），適合強調絕對量差異。

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

#### `sizeddonut` — 比例環圈圖

`sizedpie` 的環圈版本。

```xml
<chart title="sizeddonut" autocolor="yes" xaxisposition="none" yaxisposition="none">
  <serie type="sizeddonut" ...>
    ...
  </serie>
</chart>
```

---

### 雷達類

#### `spider` — 蜘蛛圖（雷達圖）

多維度指標比較，各軸從中心向外放射。同樣使用 `pie*` 屬性群控制佈局。

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

## 10.7 圖型速查表

| 圖型 `type` | 中文名稱 | 負值 | 多數列 | 自動色 | 適用場景 |
|---|---|---|---|---|---|
| `line` | 折線圖 | ✅ | ✅ | ❌ | 趨勢、時序 |
| `digitalline` | 數位折線圖 | ✅ | ✅ | ❌ | 狀態切換、0/1 訊號 |
| `bar` | 群組長條圖 | ❌ | ✅ | ❌ | 類別比較 |
| `stackedbar` | 堆疊長條圖 | ❌ | ✅ | ❌ | 組成比例 + 總量 |
| `histogram` | 直方圖 | ✅ | ❌ | ❌ | 頻率分布、正負值 |
| `area` | 面積圖 | ❌ | ✅ | ❌ | 趨勢 + 量感 |
| `stackedarea` | 堆疊面積圖 | ❌ | ✅ | ❌ | 組成趨勢 |
| `pie` | 圓餅圖 | ❌ | ❌ | ⚠️ 手動 | 占比（個別配色） |
| `donut` | 環圈圖 | ❌ | ❌ | ✅ | 占比（自動配色） |
| `sizedpie` | 比例圓餅圖 | ❌ | ❌ | ✅ | 絕對量差異 |
| `sizeddonut` | 比例環圈圖 | ❌ | ❌ | ✅ | 絕對量差異（環圈） |
| `spider` | 蜘蛛圖 | ❌ | ❌ | ❌ | 多維度雷達 |

---

## 10.8 資料來源：兩種模式

### 模式一：資料集驅動

`<chart>` 綁定 `<dbquery>` 資料集，`<serie>` 透過 `fieldnamevalue` / `fieldnamexaxis` 指定欄位，無需 `<point>`：

```xml
<dbquery id="xy"><![CDATA[
  SELECT TOP 12 no, a, b FROM zp
]]></dbquery>

<chart title="月銷售趨勢" rangeto="11" dataset="xy" legend="yes">
  <serie type="line" linecolor="#f37735" linewidth="2"
         fieldnamevalue="a" fieldnamexaxis="no">
  </serie>
  <serie type="line" linecolor="#00aedb" linewidth="2"
         fieldnamevalue="b" fieldnamexaxis="no" marker="yes">
  </serie>
</chart>
```

- `fieldnamexaxis="no"` 使用自動整數序號作為 X 軸標籤；填欄位名稱則使用該欄位值。
- `rangeto="11"` 指定 X 軸最大顯示刻度。

### 模式二：程式產生資料點

在 `<serie>` 內用 `<while>` / `<for>` 迴圈 + `<point>` 動態注入，適合需要即時計算或不依賴固定查詢格式的場景：

```xml
<chart title="隨機分布" rangeto="11">
  <serie type="bar" color="#f37735" valuewidth="60">
    <setvar name="I" value="0"/>
    <while cnd="I&lt;=11">
      <setvar name="I" value="I+1"/>
      <point label="$(STR(I))" value="RandomRange(100,300)"/>
    </while>
  </serie>
</chart>
```

- `RandomRange(min, max)` 產生範圍內的隨機整數（🌐 **Web** 環境函數）。
- `label` 和 `value` 均支援完整的 WapForm 運算式。

### 混用範例：資料庫 + 動態計算

```xml
<dbquery id="sales"><![CDATA[
  SELECT month, amount FROM monthly_sales WHERE year=$year
]]></dbquery>

<chart title="銷售 vs 目標" dataset="sales" legend="yes">
  <!-- 數列一：從資料集讀取實際銷售 -->
  <serie type="bar" color="#00aedb"
         fieldnamevalue="amount" fieldnamexaxis="month">
  </serie>
  <!-- 數列二：目標值（固定常數，以迴圈注入） -->
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

## 10.9 顏色陣列技巧

圓餅圖的個別資料點配色，透過預先宣告顏色陣列再以索引引用：

```xml
<!-- 在 card 頂層宣告顏色陣列 -->
<setvar name="C" value="[0..9]"/>
<setvar name="C[0]" value="#00aedb"/>
<setvar name="C[1]" value="#a200ff"/>
<setvar name="C[2]" value="#f47835"/>
<setvar name="C[3]" value="#d41243"/>
<setvar name="C[4]" value="#8ec127"/>

<!-- 在 <point> 中以 mod 循環取色 -->
<while cnd="I&lt;5">
  <point label="$('類別'+STR(I))"
         value="RandomRange(100,300)"
         color="C[I mod 5]"/>
  <setvar name="I" value="I+1"/>
</while>
```

`color="C[I mod 5]"` 傳入陣列元素（字串 `"#RRGGBB"`），`mod 5` 使顏色循環不超出陣列範圍。

`autocolor="yes`（在 `<chart>` 層宣告）則讓框架自動配色，不需手動管理陣列。

---

## 10.10 多圖表並排：`<table>` 版面

使用 `<table columns="N">` 將多張圖表排列成格線：

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

`columns="4"` 告知引擎此表格有 4 欄，`align="LLLL"` 設定各欄靠左對齊。

---

## 10.11 平台差異

| 功能 | 🖥️ Win | 🌐 Web |
|---|---|---|
| 全部 12 種圖型 | ✅ | ✅ |
| 資料集驅動（`dataset=`） | ✅ | ✅ |
| 程式產生（`<point>`） | ✅ | ✅ |
| `RandomRange(min,max)` | ❌ | ✅ |
| 內嵌於報表 card（`device="prv"`） | ✅ | ❌ |
| 內嵌於 Web sub card | ❌ | ✅ |
| `autocolor="yes"` | ✅ | ✅ |
| `<table columns="N">` 並排 | ✅ | ✅ |

Windows 環境中圖表通常出現在 `device="prv"`（列印預覽）的輸出 card 內；Web 環境則放在 `device="sub"` 的內容 card 中直接輸出 HTML。

---

## 10.12 常見模式速覽

```xml
<!-- 折線圖：資料庫查詢驅動，雙數列 -->
<dbquery id="xy"><![CDATA[SELECT TOP 12 no, a, b FROM zp]]></dbquery>
<chart title="趨勢" rangeto="11" dataset="xy" legend="yes">
  <serie type="line" linecolor="#f37735" linewidth="2"
         fieldnamevalue="a" fieldnamexaxis="no"/>
  <serie type="line" linecolor="#00aedb" linewidth="2"
         fieldnamevalue="b" fieldnamexaxis="no" marker="yes"/>
</chart>

<!-- 長條圖：程式產生，雙數列並排 -->
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

<!-- 圓餅圖：手動顏色陣列 -->
<setvar name="C" value="[0..4]"/>
<setvar name="C[0]" value="#00aedb"/>
<setvar name="C[1]" value="#a200ff"/>
<setvar name="C[2]" value="#f47835"/>
<setvar name="C[3]" value="#d41243"/>
<setvar name="C[4]" value="#8ec127"/>
<chart title="占比" xaxisposition="none" yaxisposition="none">
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

<!-- 環圈圖：自動配色 -->
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

## 第十一章　Web 檔案上傳實戰：`<upload>` 與 `<multiupload>`

——兩種形狀完全不同的上傳請求，收檔邏輯各自獨立

🌐 **Web 專用**

瀏覽器送檔案到伺服器，其實有兩種完全不同的 HTTP 請求形狀，WapForm for Web 用兩個不同的標籤分別對應，彼此不能互換：

| | `<multiupload>` | `<upload>` |
|---|---|---|
| 對應的請求格式 | `multipart/form-data`（`<form>` 表單送出） | 原始 PUT（整個 body 就是檔案本身） |
| 一次幾個檔案 | 可多檔 | 單檔 |
| 檔名來源 | 請求本身夾帶原始檔名 | 請求裡沒有檔名，需由伺服器端決定 |
| 典型情境 | 使用者在網頁上按「選擇檔案」上傳 | 程式（Windows client、curl）直接把檔案位元組當 body 送出，相容傳統 `upload.php` 的收法 |

兩者都內建副檔名白名單過濾、`.wml` 一律封鎖（避免上傳目錄若落在網站根目錄下，被引擎當樣板執行）、以及對「認得的格式」做檔頭魔術位元組驗證，防止只是把副檔名改掉的偽裝檔案闖關。

---

### 11.1 `<multiupload>`：多檔 multipart 上傳

`<multiupload>` 對應瀏覽器 `<form enctype="multipart/form-data">` 送出的請求。它是一個**容器元素**：每存好一個檔案，就把子節點內容跑一次，讓頁面可以逐檔顯示縮圖、寫資料庫記錄等。

#### 屬性

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `filefield` | (必) | 對應 `<input type="file" name="...">` 的欄位名稱 |
| `destination` | (必) | 存檔目錄，結尾需含路徑分隔符 |
| `filename` | (必) | 存檔後的檔名要寫入哪個變數（迴圈內逐檔更新） |
| `srcname` | (選) | 使用者端原始檔名要寫入哪個變數 |
| `index` | (選) | 目前是第幾個檔案（從 1 起算）要寫入哪個變數 |
| `count` | (選) | 上傳結束後，總共成功存檔的檔案數要寫入哪個變數 |
| `result` | (選) | 錯誤訊息要寫入哪個變數，全部成功則為空字串 |
| `accept` | (選) | 允許的副檔名白名單，逗號分隔；留空代表不限制 |
| `nameconflict` | (選) | 撞名處理策略，`unique` 表示自動加時間戳與序號避免覆蓋 |

子節點內可直接引用 `filename`／`srcname`／`index` 對應的變數，逐檔渲染。

#### 完整範例：`multiupload.wml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<wml>

  <card id="upload" title="檔案上傳">

    <div class="narrow">

    <div class="wf-head">
      <div class="wf-badge">WapForm for Web · 範例</div>
      <div class="wf-title">檔案上傳</div>
      <div class="wf-sub">可一次選取多個檔案，伺服器端自動去重新命名並回報結果。</div>
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
          要逐檔寫進資料庫，把下面這行的註解拿掉並改成你自己的資料集。

        <dbquery id="q" sql="insert into upfile (fname, oname, utime) values ('$(fn)', '$(src)', now())"/>
        -->

      </multiupload>

      <if cnd="n > 0">
        <div class="res-bar">
          <span>✓</span>
          <span>共上傳 <b>$(n)</b> 個檔案<if cnd="memo &lt;> ''">，說明：$(memo)</if></span>
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

      <div class="card-title">選擇要上傳的檔案</div>
      <div class="card-note">支援多選。同名檔案會自動加上時間戳與序號，不會互相覆蓋。可接受 jpg / png / gif / pdf / txt / csv / xlsx / docx / zip。</div>

      <form action="multiupload.wml" method="post" enctype="multipart/form-data">

        <input type="hidden" name="card" value="upload"/>

        <div class="drop">
          <div class="drop-ic">⬆</div>
          <div class="drop-main">點這裡選擇檔案</div>
          <div class="drop-hint">可按住 Ctrl 或 Shift 一次選取多個</div>
          <operator><![CDATA[<input type="file" name="myfile" multiple="multiple"/>]]></operator>
        </div>

        <operator><![CDATA[<div class="picked" id="picked"></div>]]></operator>

        <div class="field" style="margin-top:1.25rem;">
          <span class="field-label">說明文字（選填）</span>
          <input type="text" name="memo" size="40"/>
        </div>

        <div class="actions">
          <input type="submit" value="開始上傳"/>
          <span class="actions-note">上傳後會列出每個檔案的存檔名稱</span>
        </div>

      </form>

    </div>

    <div class="foot">
      版面由 <code>wapform.htm</code> 提供，流程與資料由 <code>multiupload.wml</code> 定義。<br/>
      設計師改版面不動 wml，工程師改邏輯不動 htm。
    </div>

    </div>

  </card>

</wml>
```

#### 幾條會踩到的引擎規則

| # | 規則 |
|---|---|
| 1 | `<form>` / `<div>` 不是引擎標籤，會原樣輸出，屬性（含 `class`）保留。 |
| 2 | 檔案欄位不能用 `<input>`，因為引擎的 `_input` 不會輸出 `multiple`；改用 `<operator>` 直接寫原始 HTML 出口（內容仍會做 `$()` 展開）。 |
| 3 | `_input` 不輸出 `class`，所以外面要包一層 `<div class="field">`，CSS 用後代選擇器（`.field input`）去套。 |
| 4 | `<multiupload>` 的子節點是每存好一個檔案就跑一次。 |
| 5 | `cnd=` 與 `value=` 收的是運算式，字串字面值要自己包單引號。 |
| 6 | 只有這次請求送上來的欄位才存在於變數表；範例中的 `memo` 在第一次 `GET` 時不存在，要引用得放在確定發生過 `POST` 的區塊裡。`filename`／`srcname`／`index`／`count`／`result` 這五個對應的變數則由 `<multiupload>` 自己建立，隨時可引用。 |
| 7 | 沒有子節點的元素會被輸出成 `<div/>`，在 HTML 裡是未閉合的開始標籤，後面內容會被吃進去；空容器（內容交給前端 JS 填）一律改用 `<operator>` 直接寫定原始 HTML。 |
| 8 | `destination` 若落在網站根目錄底下（範例中的 `C:\Wapform\wap\` 即是），上傳後的檔案就能直接用網址打到，不必另外寫下載用的 wml；`.wml` 已由引擎一律擋掉，其餘型別交給 `accept` 白名單收斂。要完全隔離存取，就把 `destination` 指到根目錄以外，再另寫一支下載用的 wml 控管。 |
| 9 | 圖片預覽：用 `ExtractFileExt`／`LOWER` 這兩個引擎內建的運算式函式判斷副檔名是不是圖片類型，是的話直接用 `<img src="upload/$(fn)">` 顯示。 |

---

### 11.2 `<upload>`：原始 PUT 單檔上傳

`<upload>` 收的是完全不同形狀的請求：整個 request body 就是檔案本身的位元組，沒有 multipart 外包裝、沒有欄位名、也沒有檔名。這個標籤是為了相容傳統 `upload.php`（`fopen('php://input')` 直接讀 body、原樣寫成檔案）那種收法而設計的。它是一個**空元素**。

#### 屬性

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `destination` | (必) | 存檔目錄 |
| `filename` | (選) | 固定存檔檔名；留空時改由 `Content-Disposition` 標頭或時間戳決定（見下） |
| `accept` | (選) | 允許的副檔名白名單，逗號分隔；留空代表不限制 |
| `unique` | (選) | `yes` 時，若目錄內已有同名檔案，自動加 `_01`、`_02`……避免互相覆蓋（與 `nameconflict="unique"` 等義，兩種寫法都認得） |
| `result` | (選) | 錯誤訊息／狀態要寫入哪個變數；沒有 body 時會收到 `'empty body'` |
| `size` | (選) | 收到的位元組數要寫入哪個變數 |
| `savedname` | (選) | 實際存檔後的檔名要寫入哪個變數（因為動態檔名只有標籤自己知道，畫面要靠它才能顯示預覽圖） |

#### 檔名決定順序

原始 PUT 請求裡沒有檔名可用，`<upload>` 依序決定實際存檔名：

1. **有寫 `filename`** → 固定用該檔名（與 `upload.php` 行為一致，重複上傳即覆蓋同一個檔；若同時搭配 `unique="yes"`，撞名時才在後面加序號）。
2. **沒寫 `filename`，但請求帶了 `Content-Disposition: attachment; filename="..."`** → 直接沿用該檔名（`<webcopy>` 的 `httpupload` 會自動帶上這個標頭，見第十二章）。
3. **兩者都沒有** → 用時間戳（`yymmddhhnnsszzz`）產生檔名，副檔名依請求的 `Content-Type` 推斷（見下表）；認不出來的型別一律當成 `.jpg`。

`filename` 也可以接受外部輸入，例如 `filename="$(name)"` 搭配網址上的 `?name=...`；標籤內部會去掉路徑、擋掉 `..` 與磁碟機代號，再比對副檔名白名單，避免路徑穿越攻擊。

`unique="yes"` 負責的是撞名：目錄裡已經有同名檔案時在後面加 `_01`、`_02`……直到不重複，不會互相覆蓋；它跟「檔名怎麼決定」是兩個獨立的機制。

#### Content-Type → 副檔名推斷表

| Content-Type | 副檔名 |
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
| 其他 | `.jpg`（預設） |

送出時的 `Content-Type` 一定要跟實際檔案類型對得上——例如傳 PDF 卻宣告 `image/jpeg`，會被推斷成 `.jpg`，接著檔頭驗證發現內容其實是 PDF、跟 `.jpg` 對不上，就會被拒絕存檔。不想依賴推斷的話，直接用 `filename` 屬性指定副檔名最可靠。

#### ★ 最容易踩的坑：一定要指定正確的 Content-Type

送出端呼叫 `<upload>` 時，**一定要指定 `Content-Type`，而且不能是 `application/x-www-form-urlencoded`**（許多 HTTP 函式庫的預設值，包含 curl 的 `--data-binary` 與 ICS 的 `THttpCli`）。

這個坑症狀很隱晦：伺服器會「收到東西」、長度也完全正確，但檔案開頭的位元組被悄悄改掉，存出來的圖打不開。原因是伺服器端的 HTTP 元件看到 `application/x-www-form-urlencoded` 就認定 body 是表單文字，在交給任何處理邏輯之前，先把它當成字串處理了一次，過程中做了一次 Windows 的 best-fit 字元轉換：把位元組當 Latin-1 字元，再轉成 ANSI 字碼頁，對應不到的位元組就換成「長得最像」的 ASCII 字母（例如 `FF` → `y`、`D8` → `O`、`E0` → `a`）。JPEG 檔頭的 `FF D8 FF E0` 就這樣被換成別的位元組，而 `< 0x80` 的位元組不受影響，所以看起來像是「只有前面幾個位元組壞掉」。這一步發生在伺服器端讀取之前，`<upload>` 標籤本身完全無法補救，只能由送出端一開始就指定正確的 `Content-Type`（`image/jpeg`、`image/png`、`application/octet-stream` 等皆可）。

#### 完整範例：`upload.wml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<wml>

  <card id="upload" title="原始 PUT 單檔上傳">

    <div class="narrow">
      <div class="wf-head">
        <div class="wf-badge">WapForm for Web · 範例</div>
        <div class="wf-title">原始 PUT 單檔上傳</div>
        <div class="wf-sub">整個 request body 就是一個檔案，沒有 multipart 外包裝，相容 upload.php 的收法。</div>
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
          <span>已存檔 <b>$(up_name)</b>，共 $(up_size) 位元組。</span>
        </div>
        <div class="card">
          <div class="card-title">存檔結果</div>
          <img class="up-preview" src="upload/$(up_name)" alt="$(up_name)"/>
        </div>
      </if>

      <if cnd="up_err &lt;> ''">
        <div class="alert">
          <span>!</span>
          <span>這次沒有存檔：$(up_err)</span>
        </div>
      </if>

      <div class="card">
        <div class="card-title">怎麼測試</div>
        <div class="card-note">
          這頁不是表單頁，沒有選檔案的按鈕——原始 PUT 沒辦法用瀏覽器的一般表單送出，
          要用程式（或 curl）直接把檔案內容當成 request body 送過來。
        </div>

        <div class="alert">
          <span>!</span>
          <span>
            送出時<b>一定要指定 Content-Type</b>（例如 <code>image/jpeg</code>），
            不能用預設的 <code>application/x-www-form-urlencoded</code>。
          </span>
        </div>

        <div class="card-note">
          <b>用 Windows client（Unit2.pas 的 UploadFile）：</b>
        </div>
        <div class="code-block">
          HttpCli.URL := 'http://localhost:8080/wap/upload.wml';<br/>
          HttpCli.ContentTypePost := 'image/jpeg';<br/>
          HttpCli.SendStream := Stream;<br/>
          HttpCli.RequestVer := '1.1';<br/>
          HttpCli.Put;
        </div>

        <div class="card-note">
          <b>用 curl：</b>
        </div>
        <div class="code-block">
          curl -X PUT --data-binary "@C:\Wapform\a02.jpg" -H "Content-Type: image/jpeg" http://localhost:8080/wap/upload.wml<br/>
          <br/>
          傳 PDF 就要換成對應的型別，不能沿用 image/jpeg：<br/>
          curl -X PUT --data-binary "@C:\Wapform\aaa.pdf" -H "Content-Type: application/pdf" http://localhost:8080/wap/upload.wml<br/>
          <br/>
          想指定存檔名稱的話，加上 Content-Disposition 標頭：<br/>
          curl -X PUT --data-binary "@C:\Wapform\a02.jpg" -H "Content-Type: image/jpeg" -H "Content-Disposition: attachment; filename=\"a02.jpg\"" http://localhost:8080/wap/upload.wml
        </div>
      </div>

    </div>

    <div class="narrow">
      <div class="foot">
        版面由 <code>wapform.htm</code> 提供，收檔邏輯由 <code>&lt;upload&gt;</code> 標籤提供。<br/>
        跟 <code>multiupload.wml</code> 是兩種不同的上傳形狀——那頁走瀏覽器表單的
        multipart，這頁走原始 PUT，兩邊的標籤不能互換。
      </div>
    </div>

  </card>

</wml>
```

這頁若用瀏覽器直接打開（`GET`）不會出錯，只是因為沒有 body，`result` 會拿到 `'empty body'`，畫面顯示的就是使用說明區塊。

---

### 11.3 安全機制小結

不論 `<upload>` 或 `<multiupload>`，都內建三層防護：

| 層次 | 機制 |
|---|---|
| 副檔名白名單 | `accept` 屬性列出允許的副檔名，逗號分隔；留空代表不限制 |
| 樣板一律封鎖 | `.wml` 不受 `accept` 控制，永遠拒絕——上傳目錄若落在網站根目錄底下，`.wml` 會被引擎「執行」，等於誰能上傳誰就能跑任意樣板 |
| 檔頭魔術位元組驗證 | 對「認得的格式」再驗一次真實內容：`jpg/jpeg`、`png`、`gif`、`bmp`、`pdf`、`zip`（`docx`/`xlsx`/`pptx` 本體就是 zip，檔頭都是 `PK`）、`doc/xls/ppt`（Office 97-2003 的 OLE2 複合文件，檔頭都是 `D0 CF 11 E0`）。沒有固定檔頭的格式（`txt`、`csv` 等）不做這項檢查，直接放行 |

這是為了擋掉「把別種東西改個副檔名送上來」——例如把 PDF 改名成 `.jpg` 會被拒絕存檔。

---

### 11.4 本章小結

| 情境 | 用哪個標籤 |
|---|---|
| 網頁上的「選擇檔案」表單，可能多選 | `<multiupload>`（`multipart/form-data`） |
| 程式或 curl 直接把檔案位元組當 body PUT 上去，相容 `upload.php` | `<upload>`（原始 PUT） |
| Windows 端要把本機檔案送到這兩支收檔頁 | 見第十二章 `<webcopy protocol="httpupload">`——它送出的請求形狀跟 `<upload>` 對得上，並且會自動帶 `Content-Disposition` 與正確的 `Content-Type` |

---

## 第十二章　Windows 檔案搬運實戰：`<open>` 與 `<webcopy>`

——本機檔案的選取、搬移、上傳與下載

🖥️ **Win 專用**

Windows 端沒有瀏覽器的 `<form>`，本機檔案要進出系統靠兩個標籤搭配：`<open>` 彈出系統檔案選擇對話框，`<webcopy>` 依 `protocol` 屬性在檔案系統、HTTP、FTP 之間搬運檔案。兩者常常成對出現：使用者選檔案 → 上傳或搬移到目的地。

---

### 12.1 `<open/>`：系統檔案選擇對話框

空元素，彈出作業系統原生的「開啟舊檔」對話框，讓使用者挑選本機檔案。

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `filename` | (必) | 使用者選取的完整路徑要寫入哪個變數 |
| `result` | (必) | 使用者是否按下確認要寫入哪個變數，`1` 表示確認，其餘表示取消 |

```xml
<setvar name="I" value="0"/>
<setvar name="F" value="''"/>
<open filename="F" result="I"/>
<if cnd="I=1">
  <!-- 使用者選好了檔案，F 是完整路徑 -->
</if>
```

務必先判斷 `result`（範例中的 `I=1`）再使用 `filename` 變數的內容，否則使用者按取消時，變數可能還是先前殘留的值。

---

### 12.2 `<webcopy/>`：五種協定的檔案搬運

空元素，依 `protocol` 屬性決定行為，在「本機檔案系統」「HTTP」「FTP」之間搬運檔案，是 Windows 端唯一內建的檔案傳輸手段（Web 端沒有對應標籤，改用第十一章的 `<upload>` / `<multiupload>` 在伺服器端收檔）。

#### 屬性總表

| 屬性 | 必／選 | 說明 |
|---|---|---|
| `protocol` | (選，預設 `file`) | `file`／`httpupload`／`httpdownload`／`ftpupload`／`ftpdownload` 之一 |
| `host` | 依協定而定 | 意義隨 `protocol` 改變，見下表 |
| `url` | 依協定而定 | 意義隨 `protocol` 改變，見下表 |
| `dir` | 依協定而定 | 意義隨 `protocol` 改變，見下表 |
| `username` / `password` | FTP 協定必填 | FTP 登入帳號密碼 |
| `unique` | (選) | 出現此屬性即代表 `true`：以時間戳（`yyyymmddhhnnsszzz`）產生檔名；若 `dir` 目錄下仍撞名，再加 `_01`、`_02`……直到不重複（上限 999 次嘗試） |
| `result` | (選) | 成功時寫入實際存檔／上傳後的檔名；失敗時寫入錯誤訊息 |
| `errmsg` | (選) | 失敗時寫入錯誤訊息；成功時清空為空字串 |
| `response` | (選，僅 `httpupload` 有效) | 寫入伺服器回應的原始內容（HTTP response body） |

#### 五種協定的 `host` / `url` / `dir` 對照表

| `protocol` | `host` | `url` | `dir` |
|---|---|---|---|
| `file` | 目標目錄（結尾需含 `\`） | 來源完整路徑 | — |
| `httpupload` | 目標網址 | 本機檔案路徑 | — |
| `httpdownload` | 來源網址 | — | 存放目錄 |
| `ftpupload` | FTP 主機 | 本機檔案路徑 | FTP 上的目錄 |
| `ftpdownload` | FTP 主機 | FTP 上的檔名 | 本機存放目錄 |

各協定的行為細節：

- **`file`**：本機檔案系統內複製。來源（`url`）不存在時回傳錯誤；目的地（`host` + 檔名）若已存在同名檔案，**不會覆蓋**，直接跳過並回報「檔案已存在」。
- **`httpupload`**：以 HTTP `PUT` 將本機檔案（`url`）上傳到 `host`。會自動依副檔名設定正確的 `Content-Type`（涵蓋 `.jpg/.png/.gif/.bmp/.pdf/.zip/.txt/.csv/.doc/.xls/.ppt/.docx/.xlsx/.pptx`，其餘型別一律送 `application/octet-stream`），並自動帶上 `Content-Disposition: attachment; filename="..."` 標頭，同時在網址上附加 `?name=` 或 `&name=`——這正是與第十一章 `<upload>` 標籤搭配時，對方能拿到原始檔名的原因。HTTP 狀態碼非 `200` 視為失敗。
- **`httpdownload`**：以 HTTP `GET` 從 `host` 下載到 `dir` 目錄。若沒有指定或推斷不出檔名，退回以來源網址的檔名，再退回時間戳。HTTP 狀態碼非 `200` 視為失敗。
- **`ftpupload`** / **`ftpdownload`**：透過 FTP 協定搬運，`username`／`password` 為必要登入資訊。

#### 完整範例：`webcopy.wml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<wml>

  <card id="webcopy" title="檔案搬運測試" width="960">

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
        <td width="900"><label name="R">（尚未執行）</label></td>
      </tr>
      <tr>
        <td>errmsg: </td>
        <td><label name="E">（尚未執行）</label></td>
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

    <do type="prev" label="關閉">
      <prev/>
    </do>

  </card>

</wml>
```

這頁把六種協定各做成一顆按鈕，按下去立即在 `result` / `errmsg` 兩個 label 上看到結果，適合當作接新專案時的協定行為驗證頁——`host`／`url`／`dir` 三個屬性的意義每種協定都不一樣，實測一輪比背表格可靠。

---

### 12.3 實戰整合：`<open>` + `<webcopy httpupload>` 圖片上傳與預覽

`app002.wml`（產品主檔）示範了 Windows 端最常見的圖片管理組合：使用者按「開啟」選圖 → `<webcopy protocol="httpupload">` 立即上傳到 Web 端的 `upload.wml` → 上傳成功後用回傳的檔名組出圖片網址，即時刷新畫面上的預覽圖。

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
      <log message="上傳失敗: $R"/>
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

畫面上的觸發點與 `afterscroll` 事件的搭配：

```xml
<td>圖示：<a href="@A0">開啟</a>|<a href="@B0">清除</a><br/><br/>
    <img id="g0" width="300" height="300" src="$('http://localhost:8080/wap/upload/'+paicon)"/>
</td>
```

```xml
<onevent type="afterscroll">
  <log message="$(paicon)"/>
  <setprop name="g0" prop="img" value="'$('http://localhost:8080/wap/upload/'+paicon)'"/>
</onevent>
```

**流程拆解：**

| 步驟 | 說明 |
|---|---|
| 1. `<open filename="F" result="I"/>` | 彈出檔案選擇對話框，`I=1` 表示使用者確認選取，`F` 是本機完整路徑 |
| 2. `<webcopy protocol="httpupload" ...>` | 把 `F` 指向的本機檔案，以 `httpupload` 上傳到 Web 端的 `upload.wml`（即第十一章的 `<upload>` 標籤所在頁）；`R` 收到的是成功時的存檔檔名，失敗時是含 `failed` 字樣的錯誤訊息 |
| 3. `Pos('failed', R)=0` | 用字串搜尋判斷上傳是否成功——因為 `SetErr` 系列的錯誤訊息都以協定名稱開頭、含 `failed` 字樣，是 `<webcopy>` 慣用的判斷寫法 |
| 4. 成功：`paicon` 存下檔名，`<setprop img>` 重設圖片網址 | Web 端上傳目錄若在網站根目錄下（見第十一章 11.1 節），存好的檔案本來就能直接用網址打到，不必另外寫下載用的 wml |
| 5. `B0`／清除 | 改把 `paicon` 設回固定的預設圖檔名，達到「還原成預設圖」的效果 |
| 6. `afterscroll` | 換頁（`navigator`／捲動記錄游標）時重新套用 `paicon` 對應的網址，確保切換到別筆記錄時圖片同步更新 |

> 這個組合正是第十一章與第十二章互相銜接的地方：`<webcopy protocol="httpupload">` 送出的請求（`Content-Type` 依副檔名自動設定、`Content-Disposition` 帶原始檔名、網址上附 `?name=`），跟第十一章 `<upload>` 標籤收檔時預期的格式完全對得上，兩邊不需要額外轉換。

**📱 Flutter**

`<open>` 與 `<webcopy>` 在 WapForm for Flutter 沒有對應標籤。同一份 `.wml` 要在 Flutter 也能上傳圖片時，用 `<platform>` 把 Windows 的寫法與 Flutter 的 Dart 寫法分開，完整範例（`app002.wml`）見第 4.5 節 `<platform>`。

---

### 12.4 本章小結

| 技術 | 用途 |
|---|---|
| `<open filename result/>` | 彈出系統檔案選擇對話框，取得本機檔案路徑 |
| `<webcopy protocol="file">` | 本機檔案系統內複製，目的地已存在同名檔案時不覆蓋 |
| `<webcopy protocol="httpupload">` | 以 HTTP PUT 上傳本機檔案，自動帶 `Content-Type` 與 `Content-Disposition`，與第十一章 `<upload>` 標籤直接對接 |
| `<webcopy protocol="httpdownload">` | 以 HTTP GET 下載檔案到本機目錄 |
| `<webcopy protocol="ftpupload">` / `protocol="ftpdownload">` | 透過 FTP 上傳／下載 |
| `unique="yes"` | 五種協定共通的撞名保護：加時間戳與序號，不覆蓋既有檔案 |
| `result` / `errmsg` | 成功回傳檔名、失敗回傳錯誤訊息的慣用配對 |
| `Pos('failed', R)=0` | 判斷 `<webcopy>` 是否執行成功的慣用寫法 |

---

## 第十三章　交叉列表實戰

——業務銷售分析實戰

🌐 **Web 版**

---

## 13.1 WapForm 交叉列表的本質

WapForm 的交叉列表（Crosstab）讓開發者以純宣告式 XML 描述樞紐分析——列群組、欄群組、交叉格彙總、小計列、總計行——全部透過 `<crosstab>`、`<row change>`、`<col change>`、`<setvar>` 的組合完成。

`<crosstab>` 底層跟 `<report>`（見第四章 4.7 節）共用同一套列/欄群組機制，但多了一個維度：`<report>` 只有「列」（分組＋明細），`<crosstab>` 是「列 x 欄」的二維矩陣，每個交叉格是一個彙總值。

本章的輸出目標是**瀏覽器渲染的 HTML `<table>`**，也就是 `card` 標籤不指定 `device=` 屬性時的預設路徑。WapForm 另外也支援 `device="prv"`（列印預覽）、`device="prn"`（直接列印）等輸出模式，走的是不同的程式碼分支，本章不涵蓋——那幾條路徑我們沒有實際測試過，不確定的地方寧可不寫，避免內容看起來很完整卻是錯的。

本章以業務銷售分析的「銷貨交叉表」（`crosstab.wml`）為例：橫軸為年度與年月兩層群組，縱軸為業務員與客戶兩層群組，交叉格為銷貨金額，並自動產生各行、列的小計與總計。這份範例目前實際跑在 WapForm for Web 的線上範例站台（`example.wml` 首頁的「交叉分析」卡片），不是紙上談兵的示意稿。

> **關於這一章的可信度**：交叉列表是 WapForm 整套引擎裡邏輯最複雜、也最容易寫錯的功能。這份文件的每一段程式碼、每一個變數的作用，都是實際部署、實際崩潰、實際修正、實際截圖驗證過的結果，不是憑原始碼推測出來的。過程中我們踩過的坑（尤其是 13.8 節的變數選擇）特別花篇幅說明，因為那正是最容易讓人重蹈覆轍的地方。

---

## 13.2 系統概覽

```
銷貨交叉表（crosstab.wml）

執行流程：
  card crosstab — 主報表（瀏覽器渲染，無 device= 屬性）
    ↓
  dbquery xy — 從 sh（銷貨單頭）+ cu（客戶）查詢銷貨明細，SQL 端先 group by 加總
    ↓
  <crosstab> — 交叉列表引擎

資料結構：
  列軸（Row，用 <row change> 巢狀兩層）：
    eno   — 業務員代碼（第一層群組）
    cno   — 客戶代碼（第二層群組）
  欄軸（Column，用 <col change> 巢狀兩層）：
    yy    — 年度（第一層群組）
    ym    — 年度＋月份（第二層群組，例如 202006）
  值欄位：
    amount — 銷貨金額，SQL 端已用 group by 加總，交叉格只需要填一次

控制變數：
  I, J, K     — 迴圈與欄位計數器
  N           — 當前儲存格數值（VAL 轉換後）
  T           — 保留欄位，目前未使用
  C, R        — 當前欄標頭值、當前列群組名稱
  A, B        — 列小計（年度小計）、整列橫向合計
  X[1..999]   — 目前業務員群組的欄合計陣列
  Y[1..999]   — 全部業務員的欄總計陣列（Grand Total）
```

---

## 13.3 資料查詢：SQL 端先加總

交叉列表的資料集要同時提供**列軸欄位**、**欄軸欄位**與**值欄位**。這份範例額外做了一件事——**用 `group by` 在 SQL 端先把金額加總好**，而不是把明細一筆一筆丟給引擎、指望 `<crosstab>` 自己的累加邏輯處理重複：

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

**為什麼要先 group by**：每個 `(年月, 業務員, 客戶)` 組合經過 SQL 加總後只會回傳一筆，交叉列表的內部累加邏輯（`Cell()` 函式）只需要處理「這一格第一次被寫入」的情況，不必依賴它正確處理同一格被寫入好幾次的累加——行為更可預期，也比較快。

**`order by` 不是可有可無**：`<row change="...">` / `<col change="...">` 是靠「跟上一筆資料比對有沒有變」判斷分組邊界的，資料沒有照分組鍵排序，同一組就會被拆成好幾段、標題重複印。這裡的 `order by` 順序（`yy, ym, eno, cno`）刻意跟分組層級的巢狀順序一致：外層欄鍵在前、內層欄鍵在後；外層列鍵在前、內層列鍵在後。

**日期範圍刻意跨年度**：`2020-06-01` 到 `2021-04-01` 橫跨了 2020、2021 兩個年度，用來驗證 `yy`（外層欄，年）→`ym`（內層欄，年月）兩層欄位分組在跨年份時也正確。只放單一年度的話，外層的 `yy` 分組永遠只有一個值，測不出跨年份的分組邊界對不對。

---

## 13.4 `<crosstab>` 根元素屬性

```xml
<crosstab dataset="xy" dialog="cno;sdate" field="amount" autospan="yes">
```

| 屬性 | 值 | 實際狀態 |
|---|---|---|
| `dataset` | `xy` | **有作用**，指定資料來源（`<dbquery>` 的 id） |
| `field` | `amount` | **有作用**，交叉格的值欄位名稱 |
| `dialog` | `cno;sdate` | **目前這版引擎只解析、不使用**，寫了也不會彈出任何對話框 |
| `autospan` | `yes` | **有作用**，把標頭區裡相鄰、內容相同的儲存格合併（`colspan`/`rowspan`） |

`dialog=` 這個屬性的名字聽起來像會做「執行前彈窗篩選」，但實際追過 `_report`／`_crosstab` 的原始碼，`Dlg` 是一個區域變數，讀進來之後從頭到尾沒有任何地方再讀取它的值——等於是形同虛設的程式碼，寫了不會彈出任何對話框，篩選還是要自己寫在 SQL 的 `where` 條件裡。

**`autospan=` 則是真的有效果**，只是它不在 `_crosstab` 自己的程式碼裡，而是 `TCard` 的一個欄位——`_crosstab` 只負責依屬性值設定它，真正讀取並套用的是渲染儲存格的 `_td`。運作方式是標準的「先量後併」兩階段：

1. **量測階段**（`Printable=0`）：逐格比對相鄰儲存格的內容是不是相同，相同就把「連續相同的格數」累計進內部陣列。
2. **渲染階段**（`Printable=1`）：讀回這個累計值，大於 1 就在 `<th>`／`<td>` 上輸出 `colspan="N"` 或 `rowspan="N"`，把這些格子合併成一格。

這個機制**只在標頭區生效**（業務員／客戶／年／年月那幾欄或列，判斷依據是 13.8 節提到的同一組 `Row.Count`／`Col.Count` 門檻），資料格不受影響。實際效果就是：同一個業務員底下有好幾個客戶時，業務員代碼只會在合併後的儲存格裡顯示一次、垂直置中，不會每一列都重複印——這是瀏覽器對 `rowspan` 儲存格的預設呈現方式，不是額外的樣式設定。

---

## 13.5 狀態變數初始化

`<crosstab>` 根元素下的 `<setvar>` 宣告整個報表週期共享的狀態變數：

```xml
<setvar name="I" value="0"/>    <!-- 通用迴圈計數器 -->
<setvar name="J" value="0"/>    <!-- 保留，目前未使用 -->
<setvar name="K" value="0"/>    <!-- 目前欄格計數（含小計欄），用來對齊小計/總計列 -->
<setvar name="N" value="0"/>    <!-- 當前儲存格數值（VAL 轉換後） -->
<setvar name="T" value="0"/>    <!-- 保留，目前未使用 -->
<setvar name="C" value="''"/>   <!-- 當前欄群組標頭（年度值） -->
<setvar name="R" value="''"/>   <!-- 當前列群組標頭（業務員代碼） -->
<setvar name="A" value="0"/>    <!-- 目前這一列、目前這一年的小計 -->
<setvar name="B" value="0"/>    <!-- 目前這一列（單一客戶）全期間合計 -->
<setvar name="X" value="[1..999]"/>  <!-- 目前業務員的欄合計陣列 -->
<setvar name="Y" value="[1..999]"/>  <!-- 全部業務員的欄總計陣列 -->
```

`X`、`Y` 宣告成 `[1..999]` 陣列，代表最多可以處理 999 個欄位（含 TOTAL/AMOUNT 小計欄），實務上遠遠夠用。`I`、`K` 是索引用的整數，`C`、`R` 是字串，`A`、`B`、`N` 是數字——這些型別是靠**第一次 `<setvar>` 給的值**決定的，之後同一個變數只能存放同型別的東西，塞進不同型別的值時框架會嘗試強制轉換，轉不過去就會讓伺服器丟出例外（詳見 13.8 節的除錯故事）。

---

## 13.6 表格容器與分頁設定

```xml
<page>
  <table class="xtab-table" rows="20" cols="15">
```

`rows=`／`cols=` **是真的有作用**的兩個屬性，會驅動框架內部的 `Wap.LinesPerPage`／`CrossRow`／`CrossCol`，資料的列數或欄數超過這個數字時自動觸發換頁（`NewPage()`）。

> **已知問題：網頁瀏覽情境下的換頁會讓 HTML 結構不合法。**
>
> `NewPage()` 換頁時會做兩件事：先印一段 `<p class="newpage"></p>`，然後**重新打開一次 `<table>` 標籤，但沒有先把前一個 `<table>` 關閉**。瀏覽器收到「表格裡面又開一個表格」這種不合法的 HTML，會自己想辦法修正，修正的結果通常是表頭莫名跑到資料中間、前後兩段表格視覺上黏在一起，不會乾淨地分頁。
>
> 這是引擎本身的行為，不是 CSS 能完全解決的問題。網頁版通常本來就有橫向／縱向捲動可用，不一定需要自動分頁；如果不需要分頁效果，最簡單的作法是**不要寫 `rows=`／`cols=` 這兩個屬性**（或給一個大到不會被觸發的數字），整張交叉表就會是一個連續、乾淨的 `<table>`。這兩個屬性比較適合用在 `device="prn"`／`device="prv"` 那種輸出到印表機、預覽列印的情境，那邊「分頁」是有意義的實體概念；瀏覽器裡通常不需要。

---

## 13.7 列軸定義：`<row change>`

列軸的結構由兩層 `<row change>` 巢狀定義，從外層（業務員）到內層（客戶）：

```xml
<row change="xy.eno">
  <setvar name="I" value="1"/>
  <while cnd="I&lt;=99">
    <setvar name="X[I]" value="0"/>    <!-- 每次新業務員群組時清空欄合計 -->
    <setvar name="I" value="I+1"/>
  </while>

  <row change="xy.cno">
    <setvar name="K" value="0"/>       <!-- 重置本列格計數器 -->
    <setvar name="B" value="0"/>       <!-- 重置本列橫向合計 -->
    <tr>
      ...
    </tr>
  </row>
</row>
```

`<row change="xy.eno">` 在業務員代碼改變時觸發，職責是重置欄合計陣列 `X[1]`～`X[99]`，準備重新累計下一個業務員群組的數值。`<row change="xy.cno">` 在客戶代碼改變時觸發（即輸出報表的每一列），`K`、`B` 在這裡歸零，作為本列累計的起點。

---

## 13.8 儲存格渲染：`cellrow`／`cellcol`／`cell`，不是 `row`／`col`

這是整套交叉列表機制裡**最容易寫錯、也是我們實際踩過的坑**，值得完整說明。

引擎在渲染每個儲存格時，同時維護**兩組完全不同的位置變數**：

| 變數 | 起始值 | 來源 | 用途 |
|---|---|---|---|
| `AROW` / `ACOL` | 0 起算 | crosstab 內部的格線索引（`ARow`/`ACol` 變數） | 引擎內部使用，**樣板不建議直接引用** |
| `cellrow` / `cellcol` | 1 起算 | `Wap.RowNumber` / `Wap.ColNumber`，`<tr>`／`<td>` 渲染時自然遞增的計數器，跟一般表格共用 | **樣板要用這一組** |

兩組是各自獨立、完全不相關的變數，不是大小寫的問題——`cell`（小寫）能對應到引擎內部的 `CELL`（大寫），是因為框架的 `SetVar`/`GetVar` 內部都會先把識別字轉大寫再查找，識別字本來就不分大小寫；但 `cellrow`/`cellcol` 跟 `AROW`/`ACOL` 是兩個名字完全不同的變數，沒有這層大小寫等價關係。

樣板裡如果誤用 `AROW`/`ACOL` 當作標頭／資料分界的判斷依據，輕則畫面標題跟資料對不齊，重則把交叉格的文字標籤（例如年度標頭 `'2020'`）誤判成資料格，送進數字轉換函式，直接讓伺服器丟出例外崩潰。這正是我們在實際部署這份範例時真實發生過的錯誤——`EConvertError`（`'Q1' is not a valid integer value`）跟 `EVariantInvalidArgError`（`Invalid argument`）兩次不同型態的例外，根因都是同一件事：用錯了位置變數。

正確的寫法（實際部署的版本，含一個額外的樣式判斷）：

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

**門檻數字「3」怎麼來的**：`cellrow`／`cellcol` 是 1 起算，標頭列數等於欄群組層數（本例兩層：`YY`、`YM`），標頭欄數等於列群組層數（本例兩層：`eno`、`cno`）——都是 2 層，所以標頭區佔第 1、2 列與第 1、2 欄，`cellrow<3`／`cellcol<3` 剛好涵蓋這個範圍，資料從第 3 列、第 3 欄開始。如果分組層數不是兩層，這個門檻數字要跟著層數調整（門檻＝層數＋1）。

**`(cellrow<3) or (cellcol<3)` 這種複合條件是可以用的**：實際測試過，`Condiction()` 支援 `or`／`and` 關鍵字組合條件，不需要拆成 `<elseif>` 巢狀寫法。

**巢狀的 `(cellrow=2) and (cellcol<3)` 是額外的樣式判斷**：標頭區裡再細分一層——第 2 列、且落在列標頭欄（`cellcol<3`）的儲存格用 `<i>` 斜體、固定寬度 120px 呈現，其餘標頭儲存格用一般樣式。這不是必要的邏輯，純粹是這份範例對特定位置的標頭文字做的排版微調，可以依需求拿掉或調整。

**`<debug message="...">` 目前不會輸出任何東西**：這個標籤對應到框架的 `_log` 函式，該函式目前只解析 `message=` 屬性、完全沒有把內容寫到任何地方（沒有 Echo、沒有寫檔）。這份範例裡的 `<log message="$cellrow $cellcol $cell"/>` 保留著，是因為它完全不會影響輸出，拿掉或留著都一樣；想在開發期真的確認 `cellrow`/`cellcol`/`cell` 目前的值，要改用真正會輸出內容的標籤，例如暫時插一段 `<label>[$(cellrow),$(cellcol),$(cell)]</label>`。

---

## 13.9 欄末小計欄（TOTAL 欄）

每個年度群組的最右側自動追加一個小計欄，由 `<if cnd="cellcol>3">` 觸發輸出：

```xml
<if cnd="cellcol&gt;3">
  <if cnd="cellrow=1">
    <th width="60" align="center">$C</th>       <!-- 標頭第一列：顯示年度值 -->
  </if>
  <if cnd="cellrow=2">
    <th width="60" align="center">TOTAL</th>    <!-- 標頭第二列：固定顯示 "TOTAL" -->
  </if>
  <if cnd="cellrow&gt;2">
    <td align="right">$(FORMAT('%d',A))</td>    <!-- 資料列：輸出本年度橫向小計 -->
  </if>
  <setvar name="K" value="K+1"/>
  <setvar name="X[K]" value="X[K]+A"/>          <!-- 小計欄也納入欄合計陣列 -->
  <setvar name="Y[K]" value="Y[K]+A"/>
</if>
```

這段內容放在**外層** `<col change="xy.YY">` 裡面、內層 `<col change="xy.YM">` 之後——引擎的巢狀 `<col>` 標籤內容，位於巢狀子層之後的部分只會在外層分組鍵即將變動時觸發一次，剛好對應「一個年度的所有月份跑完，印一次該年度小計」的時機。

---

## 13.10 列末 AMOUNT 欄（橫向總合計）

每一列的最右側輸出整列橫向總合計，位置在 `<col change="xy.YY">` 之外、`</tr>` 之前：

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

`B` 在本列掃描過程中逐格累計（每個資料格都會 `B := B+N`），這裡直接輸出最終值。`K` 繼續推進以記錄這一欄在陣列中的位置，確保後面的小計列／總計列也能正確對齊輸出這一欄。

---

## 13.11 群組末小計列（TOTAL 列）

在內層 `<row change="xy.cno">` 結束後，若已經進入資料列（`cellrow>3`），輸出以業務員為群組的橫向小計列：

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

`R` 在每一列的 `cellcol=1` 時存入當前列群組的名稱（`<setvar name="R" value="cell" cnd="cellcol=1"/>`），此處直接引用輸出。`X[1]`～`X[K]` 的迴圈確保小計列的每一欄都跟對應的資料欄對齊，包含年度群組的 TOTAL 欄與最右側的 AMOUNT 欄。

**`cellrow>3` 這個門檻的意義**：對照 13.8 節，資料從 `cellrow=3` 開始，這個判斷式排除了第一次觸發（`cellrow=3`，還沒有累計出任何東西前的初始狀態），只在真正「換到下一個業務員之前」才印出小計——這是控制斷點報表的標準寫法，不是隨意挑的數字。

---

## 13.12 最終總計列（Grand Total）

在所有 `<row change>` 結束後，輸出整張報表的縱向總計列：

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

`Y[1]`～`Y[K]` 累計自所有列的所有儲存格，從頭到尾只在最開始歸零一次，因此這裡輸出的是整張報表的 Grand Total，不會因為換業務員群組而被重置。

---

## 13.13 完整 WML 原始碼

```xml
<?xml version="1.0" encoding="utf-8"?>
<wml>

  <card id="crosstab" title="銷貨交叉分析">

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

`class="xtab-table"`、`class="xtab-total-row"`、`class="xtab-grand-row"` 是 WapForm for Web 範例站台自己的 CSS 樣式（定義在共用的 `wapform.htm` 版面外殼裡），跟 `<crosstab>` 引擎本身無關，換一套自己的樣式表也完全不影響交叉列表的運算邏輯——版面與邏輯是分開的兩件事，這也是整個範例站台的設計原則。

---

## 13.14 設計模式總結

| 技術 | 實際狀態 | 在本例的應用 |
|---|---|---|
| `<crosstab dataset= field=>` | 有作用 | 指定資料集與交叉格值欄位 |
| `dialog=` | **目前這版引擎不使用** | 寫了不會出錯，但也不會有任何效果，不要依賴 |
| `autospan=` | **有作用** | 標頭區相同內容的相鄰儲存格自動合併為 `colspan`/`rowspan`，見 13.4 節 |
| 雙層 `<row change>` | 有作用 | eno（業務員，外層）→ cno（客戶，內層） |
| 雙層 `<col change>` | 有作用 | yy（年度，外層）→ ym（年月，內層） |
| `cellrow` / `cellcol` / `cell` | **要用這組，不是 AROW/ACOL/CELL** | 標頭／資料分界判斷、標籤擷取，見 13.8 節 |
| 複合條件 `(A) or (B)` | 有作用 | `Condiction()` 支援 `or`／`and` 關鍵字，不需要拆 `<elseif>` |
| `<debug message="...">` | **目前不會輸出任何內容** | 對應到 `_log`，該函式目前是空函式 |
| SQL 端 `group by` 先加總 | 建議做法 | 讓交叉格累加邏輯更可預期，也比較快 |
| `order by` 對齊分組層級 | **必要** | 沒排序會讓同一組被拆成好幾段、標題重複印 |
| `rows=` / `cols=` 自動分頁 | 有作用，但網頁情境下有已知的 HTML 結構問題 | 見 13.6 節；不需要分頁時建議不寫這兩個屬性 |
| 動態欄合計陣列 `X[]` | 有作用 | 每個業務員群組清空後重新累計 |
| 跨群組總計陣列 `Y[]` | 有作用 | 從不重置，最終輸出為 Grand Total 列 |
| 群組末小計列 | 有作用 | `<if cnd="cellrow>3">`，控制斷點報表標準寫法 |
| 零值空白處理 | 有作用 | `$(IF(N=0,' ',FORMAT('%d',N)))` 讓空白格更易讀 |

---

## 第十四章　建構銷貨管理系統

*（以「文具百貨」銷貨／收款 ERP 系統為例，解說 WapForm for Windows 的架構與關鍵程式碼）*

本章拆解一套正在生產環境運作的真實 Windows 桌面 ERP：涵蓋基礎資料建檔、出貨單主從結構、動態查詢、雙聯式連續報表列印、分組彙總對帳單，以及帳號權限管理，共 12 支 `.wml` 檔案。

### 14.1 系統概觀

| 檔案 | 角色 | 型態 |
|---|---|---|
| `app001.wml` | 系統參數建檔 | 單筆表單 |
| `app002.wml` | 產品資料建檔 | 清單＋建檔＋敘述三頁籤，含動態查詢 |
| `app003.wml` | 廠牌資料建檔 | 清單＋快速篩選 |
| `app004.wml` | 客戶資料建檔 | 清單＋快速篩選＋批次列印 |
| `app005.wml` | 員工資料建檔 | 清單＋快速篩選 |
| `app006.wml` | 出貨單建檔 | **主從結構＋動態查詢＋連續報表列印**（本章核心） |
| `app007.wml` | 客戶資料表列印 | 批次分組報表 |
| `app012.wml` | 應收對帳單列印 | 多層分組彙總＋期初餘額結轉 |
| `app023.wml` | 收款單查詢 | 動態查詢（唯讀清單） |
| `app037.wml` | 貨運資料建檔 | 最簡清單 CRUD |
| `app901.wml` | 帳號管理作業 | 主表＋自動展開子表 |
| `app902.wml` | 密碼（權限）資料建檔 | 巢狀主從＋內嵌子表格 |

資料表關聯以出貨單為核心放射狀展開：

```
sys（系統參數） ─┐
cu（客戶） ───────┼── sh（出貨單頭）── sn（出貨單身，明細）
em（員工） ───────┤         │
fm（貨運） ───────┤         └── num（依日期流水號計數器）
ve（廠牌） ───────┘
pa（產品，主從 sn.pno → pa.pno）

users（帳號） ── login（權限，主從 mnu.id → login.id）
```

### 14.2 單表 CRUD 的三種寫法

同樣是「維護一張表」，這套系統依資料量與使用情境採用了三種不同寫法，而不是統一套用同一個樣板：

**(1) 單筆表單**（`app001.wml`，系統參數，全系統只有一列資料）——`<dbquery>` 直接搭 `<datasource>` 輸出欄位，沒有 `<dbgrid>`、沒有 `<navigator>`，因為根本不需要換筆：

```xml
<dbquery id="sys">
  <![CDATA[select * from sys]]>
  <field fieldname="Company" displaylabel="公司名稱"/>
  ...
</dbquery>
<datasource dataset="sys">
  <p><fieldset>
    公司名稱:<input field="Company" size="30"/><br/>
    ...
  </fieldset></p>
</datasource>
```

**(2) 清單＋快速篩選**（`app003`/`app004`/`app005`/`app037`，主檔資料量中等）——`<dbgrid>` 列表配合 `<dbfilter>`，篩選條件由框架自動產生輸入框，`onfilter` 事件把使用者輸入的條件組成 `$R` 交回查詢：

```xml
<dbfilter result="R">
  <item field="cno" size="20" />
  <item field="cname" size="20" />
  <onevent type="onfilter">
    <dbquery id="cu"><![CDATA[select * from cu where $R order by cno]]></dbquery>
  </onevent>
</dbfilter>
```

這是 WapForm 內建的宣告式篩選，能滿足八成的簡單條件查詢，開發者不必手寫任何字串拼接。

**(3) 動態 WHERE 三函式**（`app002`／`app006`／`app023`，欄位多、條件組合複雜）——當篩選條件超過 `<dbfilter>` 能表達的範圍（例如「未收款」核取方塊、「含稅金額等於」精確比對、多組 起訖 區間），就得手寫 `xyz`／`clr`／`set` 三個 `<function>`，詳見下一節。

### 14.3 動態查詢三劍客：`xyz` / `clr` / `set`

`app002`、`app006`、`app023` 三支檔案裡，各自重複出現同一組手寫模式，是這套系統裡最具代表性的「重型搜尋」寫法。以 `app006.wml` 的出貨查詢頁籤為例：

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

三個函式各司其職：

| 函式 | 作用 |
|---|---|
| `xyz` | 依目前條件輸入框的值，逐條 `cnd` 判斷是否有填，有填才串接進 `SQL_WHERE`，最後重新查詢 |
| `clr` | 把所有條件輸入框清空，再呼叫 `@xyz` 重新查詢（等於「清除並重查」） |
| `set` | 查詢執行後，把目前條件值另存到 `_` 開頭的影子變數，畫面重繪時用影子變數回填輸入框，讓使用者切換頁籤或雙擊列表後，條件不會消失 |

**`QUERYGUARD` 是這段程式碼裡最值得注意的細節**：`xyz` 開頭先把 `QUERYGUARD` 加一，只有等於 1 時才真正執行查詢，結束後歸零。這是防止「查詢過程中觸發的事件又反過來呼叫 `xyz`」造成無窮遞迴或重複查詢的重入鎖（re-entrancy guard）——同樣的手法在 `app002.wml` 的產品查詢裡也一字不差地重複出現，是這套系統的固定慣例，而非單一頁面的巧合。

`CUSTNO_TO` 是否為空，決定查詢邏輯從「單一前綴比對」切成「起訖區間比對」，也是常見的實務彈性：使用者只填「起」欄位時，系統把它當成 `LIKE '前綴%'` 處理；起訖都填才切成真正的區間查詢。

**📱 Flutter**（`wapform_filter.dart`：`WapFilter`）

`xyz`（查詢）與 `clr`（清除）可以直接由 `WapFilter` 的 **Search**／**Clear** 兩個按鈕取代（第 4.2 節 `<dbfilter>`）。需要自訂條件時，維持手寫的函式：

```dart
Future<void> xyz(String cnoFilter) async {          // 查詢
  _ev.setVar("cno_f", cnoFilter.trim());
  setvar("S", "'1=1'");
  if (condition("cno_f<>''")) setvar("S", "S+' AND cno LIKE `'+AsSqlStr(cno_f)+'%`'");
  await db.query("sh", r"select * from sh where $S order by sno");
}

Future<void> clr() async {                          // 清除
  setvar("cno_f", "''");                            // 會通知 varChangeHooks，畫面可同步清空
  await xyz('');
}
```

### 14.4 出貨單主從結構：流水號與明細合計連動

`app006.wml` 的「出貨建檔」頁籤是本章份量最重的範例：`sh`（單頭）／`sn`（明細）兩層 `<datasource masterfields="sno">` 巢狀，同一張畫面同時維護抬頭與逐行明細。

**依日期產生流水號**（`onnewrecord`）：

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

`num` 表以民國年月日（`DOCDATE`）為鍵，每天從 0 開始重新累計序號；新增單頭時，先確保當天的計數列存在（不存在就 `insert`），再用 `UPDATE ... SET sno=sno+1` 取號，最後把「日期＋4 位流水號」組成單號，例如 `1150817` 那天的第 3 張單即為 `1150817` + `0003`。**先 `UPDATE` 累加、再 `SELECT` 取值，是單機／小型多人環境下常見的取號模式**——多人同時新增時仍有交錯風險，正式高併發場景通常需要資料庫層的鎖定或序列（sequence）機制補強，但在門市規模的出貨頻率下，這個簡化寫法足以穩定運作超過二十年。

**明細變動即時回寫合計金額**：

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

`sn`（明細）資料集的 `afterpost` 與 `afterdelete` 事件都會呼叫 `@UpdateTotal`：每新增/修改/刪除一筆明細，就重新遍歷整個明細資料集加總 `Total` 欄，寫回單頭的 `shAmount`。這裡示範了 `GetBookmark`／`DisableControls`／`GoToBookmark` 三件套的標準用法——在背景重新掃描資料集時**先記住目前游標位置、關閉畫面重繪，跑完迴圈後再把游標還原、重新開啟畫面重繪**，避免使用者在畫面上看到游標亂跳，也避免逐筆更新時的畫面閃爍。

`beforeedit`／`beforeinsert`／`beforedelete` 三個明細事件都呼叫 `<invoke instance="sh" method="Edit"/>`：這是**明細異動前，強制把單頭資料集切進編輯狀態**的連鎖鎖定，確保單頭與明細在同一個交易語境下被修改，避免「明細已存檔、但單頭合計欄位仍是舊值」的不一致狀態。

### 14.5 動態聯動：條碼掃描與客戶歷史售價回填

明細列的「料號」欄位（`sn.pno`）示範了兩段串接的 `onchange` 邏輯：

```xml
<field fieldname="PNo" displaylabel="料號">
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

第一段：使用者可以直接掃條碼槍輸入條碼到料號欄，系統會先查 `pa.barcode` 是否命中，命中就把欄位值**改寫成真正的貨號**——但改寫欄位值本身又會觸發同一個 `onchange` 事件，若不加保護就會無窮遞迴。`BARCODEGUARD` 在改寫前設為 1、改寫後立刻歸零，讓遞迴進來的那一次因為 `BARCODEGUARD=0` 判斷失敗而跳過條碼比對邏輯，這與 14.3 節 `QUERYGUARD` 是同一種「事件重入鎖」手法，只是用在不同場景。

第二段：料號確定後，系統回頭查「這個客戶過去買這個產品的最近一次成交價」（`vp` 查詢，`ORDER BY sdate DESC` 只取最新一筆），有歷史價就帶入歷史價，沒有就退回產品主檔的建議售價 `price1`。這是相當實用的業務邏輯：熟客的老客戶價自動延續，新客戶則套用牌價，業務員不需要每次手動查價。

### 14.6 跳窗式資料選取：四種 lookup 對話卡片

除了輸入框內建的 `lookup="表;鍵;顯示欄"` 語法，這套系統還大量使用**獨立的 sub card 當彈出式選取視窗**，`accept`／`prev` 決定「確定帶回」還是「取消」：

| 卡片 | 用途 | 回傳方式 |
|---|---|---|
| `#PC`（`app006.wml`） | 客戶清單選取視窗，展開自 `cu1`（`cno<'D'` 篩選過的客戶子集） | `<prev><setvar name="shcno" value="cu1.cno"/></prev>` |
| `#PRICE`（`app006.wml`） | 顯示同一客戶同一產品的歷史售價清單，供人工比對後手動填價 | 唯讀顯示，`<prev/>` 直接關閉 |
| `#mysub` / `#mygrp`（`app002.wml`） | 產品分類／細分類二層選取，`invoke ... method="locate"` 先定位到目前值再顯示清單 | `<prev><setvar name="SUBCAT_ID" value="su.id"/></prev>` |

以 `#mygrp` 為例：

```xml
<card id="mygrp" title="">
  <dbquery id="gr">
    <![CDATA[select id,title from web where sub='$pa.sid' order by id]]>
  </dbquery>
  <invoke instance="gr" method="locate" arg1="'id'" arg2="[pa.gid]" arg3="[loCaseInsensitive,loPartialKey]"/>
  <datasource dataset="gr">
    ...
  </datasource>
  <do type="accept" label="確定">
    <prev><setvar name="GROUPCAT_ID" value="gr.id"/></prev>
  </do>
  <do type="accept" label="取消"><prev/></do>
</card>
```

`invoke ... method="locate"` 在彈出視窗一開啟就把游標定位到「目前欄位值對應的那一列」，讓使用者一眼就看到目前選的是哪一項，而不是每次都從清單最上方開始找——這是提升可用性的小細節，但在頻繁操作的資料建檔畫面裡差異很大。

### 14.7 雙聯式連續報表：出貨單／進貨單列印

`app006.wml` 的 `P1`（出貨單）與 `P2`（進貨單）兩張列印卡片，示範傳統點矩陣式連續報表最經典的「固定行數換頁」寫法。以 `P1` 為例，五個 `<function>` 分工：

| 函式 | 職責 |
|---|---|
| `header` | 每頁頁首：公司抬頭、客戶資訊、表格欄名 |
| `normal` | 一般明細列 |
| `space` | 湊滿固定行數的空白列（維持連續報表對齊） |
| `footer` | 分頁時的頁尾（未印完，先收合表格、換頁） |
| `summary` | 最後一頁的頁尾（含金額合計、稅額、總計） |

主流程手動控制換頁：

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

固定「每頁 9 行」對應連續報表紙的實際列印格線；印到第 10 行前先收尾（`@footer`）、`<newpage/>` 換頁、重印頁首（`@header`），頁碼 `PAGENO` 遞增。列印完最後一筆明細後，若行數不滿 9 行，用 `@space` 補空白列，確保表格底線永遠對齊在紙張同一個位置，接著才輸出 `@summary`（含金額合計）收尾。**這種手動控制行數的寫法，是配合特定連續報表紙張規格的正常作法**，與現代 A4 自由流版的報表（如本章 14.8 節應收對帳單用 `<group>` 搭配的動態分頁）目的相同、手段不同——固定行距紙張需要精準對齊，動態版面則靠框架自動分頁。

值得注意的是，`P1`／`P2` 進場時都先確保資料已存檔：

```xml
<if cnd="sn.state&lt;&gt;'BROWSE'"><invoke instance="sn" method="post"/></if>
<if cnd="sh.state&lt;&gt;'BROWSE'"><invoke instance="sh" method="post"/></if>
```

避免使用者在明細還沒存檔的狀態下直接按「出貨單」列印，印出的內容跟資料庫不同步。

**📱 Flutter**（`wapform_report.dart`：`WapReport`、`WapPage(paper: "8.5x5.5")`）

中一刀連續報表紙（8.5 × 5.5 英吋）用自訂紙張；每聯固定行數由 `wap.wapLpp` 控制，滿了自動換頁並重印 `PAGEPREFIX` 的表頭：

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
        emit(expandText(r'<p>出貨單 $(sn.sno)　客戶：$(sn.cname)</p><table class="wap">'));
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
        forcePageBreak();                           // 每張單從新的一頁開始
        break;
      case 'PAGESUFFIX':
        emit('</table>');
        break;
    }
  }
}

Widget slipPage() => WapPage(title: "出貨單", report: ShipmentSlip(), paper: "8.5x5.5");
```

### 14.8 分組彙總報表：應收對帳單與期初餘額結轉

`app012.wml`（應收對帳單）是本章邏輯最深的報表：三層巢狀 `<group>`（客戶 → 日期 → 單號）疊加「期初餘額結轉」，是典型的財務對帳單寫法。

```xml
<report dataset="sh" dialog="cno;sno">
  <group change="sh.cno">
    <setvar name="AMOUNT_SUM" value="0"/>
    <setvar name="TAX_SUM" value="0"/>
    <setvar name="PAID_SUM" value="0"/>
    <page>
      ... 頁首：客戶資訊 ...
      <group change="datetostr(sh.sdate)">
        <group change="datetostr(sh.sdate)+sh.sno">
          <group>
            <tr>... 單筆明細列 ...</tr>
          </group>
          <setvar name="AMOUNT_SUM" value="AMOUNT_SUM+sh.amount"/>
          <setvar name="TAX_SUM" value="TAX_SUM+sh.tax"/>
          <setvar name="PAID_SUM" value="PAID_SUM+sh.paid"/>
        </group>
      </group>
    </page>
    <!-- 每位客戶群組結束後，另外查詢「本期以前」的歷史餘額 -->
    <dbquery id="R"><![CDATA[
      select cno, SUM(Amount) as A, SUM(Tax) as B, SUM(Paid) as C
      from sh where sh.sdate < '$(SHIPDATE_FROM)' and cno='$sh.cno' group by cno
    ]]></dbquery>
    <setvar name="BAL_BEGIN" value="R.A+R.B-R.C"/>
    <setvar name="BAL_END" value="BAL_BEGIN+AMOUNT_SUM+TAX_SUM-PAID_SUM"/>
    ... 頁尾：上期未收 + 本期銷貨 + 本期稅額 - 本期已收 = 本期應收 ...
  </group>
</report>
```

外層 `<group change="sh.cno">` 每換一位客戶就重置三個累計變數並另起一頁（`<page>` 包住整個客戶區塊）；中層依日期分組、內層依單號分組，是第十三章交叉列表用過的「多層 `group change` 累計」手法在報表輸出上的直接應用。**真正的關鍵在客戶群組結束後那段獨立的 `<dbquery id="R">`**：它另外查詢「查詢區間開始日之前」該客戶的歷史合計，算出 `BAL_BEGIN`（期初餘額），再與本期加總的 `AMOUNT_SUM`／`TAX_SUM`／`PAID_SUM` 合併算出 `BAL_END`（期末應收）。這正是對帳單「上期未收＋本期銷貨＋本期稅額－本期已收＝本期應收」的標準會計公式，用一組獨立於主查詢之外的輔助查詢達成，而不是把所有歷史資料都撈進主查詢再篩選——對資料量較大的正式環境，這種「群組內按需查詢」的作法能顯著減少單次查詢的資料量。

`app007.wml`（客戶資料表）與 `app012.wml` 共用同一種批次列印骨架，但只有單層分組；差異在於 `app007` 額外提供「垂直／水平」和「螢幕預覽／直接列印」兩組下拉選單，並用 `device="$(IF(SP='S','PRV','PRN'))"` 動態決定輸出裝置——**同一張報表卡片，靠一個運算式就能在「列印預覽」與「直接送印表機」之間切換**，不需要為兩種輸出各寫一張卡片。

**📱 Flutter**（`wapform_report.dart`：`onGroupPrepare()`）

`parseBlock()` 是同步的，不能在裡面等待查詢；每位客戶的期初餘額在 `onGroupPrepare()`（換組前、可 `await`）先查好：

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
        setvar("BAL", "VAL(ob.bal)");                 // 期初餘額結轉
        emitRow(expandText(r"<tr><th colspan='3'>$(sh.cname)　期初 $(FORMAT('%.0n',BAL))</th></tr>"),
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

使用：`WapPage(title: "應收對帳單", report: ArStatement(db))`。

### 14.9 郵件整合：一鍵通知客戶出貨

出貨單建檔頁面的「寄信」按鈕直接呼叫作業系統的預設郵件程式：

```xml
<do type="accept" label="寄信">
  <setvar name="SQL_WHERE" value="
'訂單 ['+sh.sno+'] 貨品已經寄出，貨運寄送預計需要1~3天工作天，%0A'+
...
'%0A'"/>
  <shellexecute operation="open" file="mailto:$(sh.email)?subject=文具百貨出貨通知&amp;body=$(trim(SQL_WHERE))"/>
</do>
```

`shellexecute` 呼叫作業系統層級的 `mailto:` 協定，帶上收件人（客戶 email）、主旨與內文，開啟使用者本機安裝的郵件軟體並預填好內容，改由業務員按下送出——**不需要 WapForm 自行處理 SMTP 連線**（對照第十五章 Web 環境用 `<mail>` 標籤直接寄信，是伺服端與客戶端兩種截然不同、但同樣務實的整合方式）。內文用字串變數手動組成，`%0A` 是 mailto URL 裡的換行編碼。

### 14.10 帳號與權限管理：巢狀主從＋自動展開子表

`app901.wml`（帳號管理）與 `app902.wml`（權限管理）是一組互補的管理功能。

**新增帳號時自動展開全選單的權限記錄**（`app901.wml`）：

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

新建一個帳號時，先確認這個帳號還沒有任何權限記錄，然後**把全選單表 `mnu` 逐筆掃過一遍，用 `<report>...<group>` 迴圈為每一個選單項目各自 `INSERT` 一筆權限記錄**（預設可讀不可寫）。這是「新增主檔時，自動展開一整批對應明細」的批次建立模式，跟第六章 6.6 節「背景批次採購單展開」是同一種設計思路，只是這裡用來初始化權限而非展開訂單。

**巢狀主從直接內嵌子表格**（`app902.wml`）：

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
      <item field="itm" title="序" size="10"/>
      <item field="uid" size="30" lookup="users;userid"/>
      <item field="w" title="啟動" type="checkbox" range="1;0" size="10"/>
    </dbgrid>
  </datasource>
</datasource>
```

外層 `<dbgrid>` 是選單清單，內層 `<datasource mastersource="mnu" masterfields="id">` 直接巢狀在外層 `<datasource>` 裡面，兩個 `<dbgrid>` 同時顯示在畫面上——點選左邊選單，右邊子表格自動只顯示該選單項目底下的使用者權限清單，不需要另外寫 `onselect` 事件手動重查，主從關聯完全由 `masterfields` 宣告驅動。這與第三章 3.2 節「模式：主從結構」的單層寫法相比，差異只在於這裡的子表格是直接以 `<dbgrid>` 呈現、允許就地勾選 `w`（啟用）欄位，讓管理者可以在同一張畫面上快速調整多位使用者對單一功能的讀寫權限。

### 14.11 本章小結

| 手法 | 對應章節 | real-world 用途 |
|---|---|---|
| 三種單表 CRUD 寫法依資料型態取捨 | 14.2 | 單筆表單／清單快速篩選／重型動態查詢並存，不強求統一樣板 |
| `QUERYGUARD` 重入鎖 | 14.3 | 避免動態查詢函式在事件鏈中被重複觸發 |
| 日期序號表 `num` 取號 | 14.4 | `UPDATE...SET sno=sno+1` 後 `SELECT`，簡化版流水號產生 |
| `GetBookmark`/`DisableControls` 三件套 | 14.4 | 背景重新掃描資料集時避免畫面閃爍與游標亂跳 |
| `BARCODEGUARD` 遞迴保護 | 14.5 | `onchange` 改寫欄位值時避免事件無窮遞迴 |
| 客戶歷史成交價回填 | 14.5 | `ORDER BY sdate DESC` 取最新一筆，無歷史價則退回牌價 |
| 彈出式 lookup 卡片＋`locate` 定位 | 14.6 | 選取視窗開啟時游標自動停在目前值上 |
| 固定行數手動換頁 | 14.7 | 配合連續報表紙張規格的頭尾五段式列印函式 |
| 群組內按需查詢期初餘額 | 14.8 | 對帳單「期初＋本期－已收＝應收」的標準會計公式落地 |
| `shellexecute mailto:` | 14.9 | 免寫 SMTP，直接喚起本機郵件軟體 |
| 主檔新增時批次展開明細 | 14.10 | 新帳號自動產生全選單的預設權限記錄 |
| 巢狀 `datasource` 直接內嵌子表格 | 14.10 | 主從關聯完全宣告式，免寫 `onselect` |

這十二支檔案共同描繪出一套典型製造／零售業銷貨系統的骨架：從基礎資料建檔、業務單據的主從結構與序號產生，到列印輸出與權限治理，每一段程式碼都是為了解決真實的業務問題而寫，也因此保留了條碼掃描、歷史比價、mailto 通知這類「教科書範例不會出現，但正式系統離不開」的細節。

---

---

## 第十五章　建構動態網路交易平台（WapForm for Web）

本章不使用虛構範例，而是直接拆解一個**正在生產環境運作的真實站台**：WapForm 官網本身的「商店＋操作手冊」站台。這個站台身兼二職——對外是有分類瀏覽、搜尋、購物車的線上商店，對內同時是本書讀者正在閱讀的操作手冊系統——是 WapForm 用自己蓋自己（dogfooding）的實戰案例，共 11 支 `.wml` 檔案協同運作。

### 15.1 系統概覽

與典型電商教學範例不同，這個站台**沒有獨立的「商品表」和「手冊目錄表」**：分類、商品、操作手冊主題、購物須知，全部混合存放在同一張 `pa` 資料表中，靠 `mnu`、`typ`、`gid` 三個欄位互相區分角色：

| 欄位 | 作用 |
|---|---|
| `mnu='m'` | 標記這筆資料同時也要出現在全站選單樹中 |
| `typ` | 決定這筆選單項目點下去要導向哪一種頁面：`b`=手冊（book）、`n`=須知（note）、`p`=靜態頁（page）、`s`=商店（shop）、其餘=分類格狀導覽（grid） |
| `gid` | 父分類代碼，用來組出選單的父子階層 |

這個設計的好處是：新增一筆商品分類，同時也等於新增一個選單節點，不需要另外維護選單表；代價是查詢邏輯必須非常小心地用 `mnu`/`typ`/`gid` 過濾，否則手冊主題會混進商店列表。

站台由五種頁面型態＋三個共用元件組成：

```
┌───────────────────────────────────────────────────────────┐
│  header.wml / footer.wml / asider.wml   ← 全站共用元件      │
│  ├── index.wml (= shop.wml)   商店首頁／清單／搜尋／分頁    │
│  ├── grid.wml                 分類格狀導覽                  │
│  ├── book.wml + book-js.wml   操作手冊（AJAX 局部載入）     │
│  ├── note.wml + note-js.wml   購物須知（AJAX 局部載入）     │
│  └── page.wml                 純靜態內容頁                  │
└───────────────────────────────────────────────────────────┘
```

完整檔案相依總表：

| 檔案 | 角色 | include 的元件 | 主要資料表 |
|---|---|---|---|
| `header.wml` | 全站選單建構＋購物車彙總 | 無（被所有頁面 include） | `pa`（`mnu='m'`）、`rn`、`cu` |
| `footer.wml` | 頁尾熱銷捷徑 | 無（被所有頁面 include） | `pa`（`mnu='m'`、`qty>8600`） |
| `asider.wml` | 側浮動選單（重用 header 建好的陣列） | 無自己的 `dbquery` | 無 |
| `index.wml`（= shop.wml） | 商店首頁／清單／搜尋 | header、footer、asider | `sys`、`counter`、`pa`、`web`、`sn` |
| `grid.wml` | 分類格狀導覽 | header、footer、asider | `sys`、`pa` |
| `book.wml` | 操作手冊選單頁 | header、footer、asider；AJAX → `book-js.wml` | `sys`、`pa` |
| `book-js.wml` | 手冊內文（AJAX 局部載入） | 被 `book.wml` 呼叫（`loadDoc`） | `pa`（單筆 `topic`） |
| `note.wml` | 購物須知選單頁 | header、footer、asider；AJAX → `note-js.wml` | `sys`、`pa` |
| `note-js.wml` | 須知內文（AJAX 局部載入） | 被 `note.wml` 呼叫（`loadDoc`） | `pa`（單筆 `topic`） |
| `page.wml` | 靜態內容頁 | header、footer（**不含 asider**） | `sys`、`pa` |

`page.wml` 是唯一不 include `asider` 的頁面——它是純內容頁，不需要側浮動選單搶版面，這是刻意的設計取捨，而非遺漏。

### 15.2 一次查詢、全站共用的選單樹

五個頁面都要顯示同一份分類選單，若各自查詢一次，等於同一份資料被查了五次。`header.wml` 的作法是：**只在 `header` 這個 sub card 裡查一次，用陣列把結果攤平存起來**，其餘元件（`asider.wml`、`index.wml` 的 sidebar）直接讀陣列，完全不再碰資料庫。

```xml
<card id="menu" device="sub">
  <setvar name="mnu_id" value="[0..1023]" />
  <setvar name="mnu_typ" value="[0..1023]" />
  <setvar name="mnu_title" value="[0..1023]" />
  <setvar name="mnu_icon" value="[0..1023]" />
  <setvar name="mnu_count" value="[0..1023]" />

  <!-- 第一層：頂層分類（gid='0000'） -->
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

    <!-- 第二層：以第一層的 pno 當 gid，查子項目 -->
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
    <setvar name="mnu_count[p]" value="i" />   <!-- 記下這個父節點有幾個子項 -->
    <invoke instance="mnu" method="next" />
  </while>
  <setvar name="mnu_count[k]" value="999999" /> <!-- 哨兵值：陣列終止標記 -->
```

這是一個「父子兩層 `mnu_count[]` 索引陣列」的手動攤平寫法：`mnu_id[]`/`mnu_typ[]`/`mnu_title[]` 把父節點與子節點**依序**接連放進同一個一維陣列，`mnu_count[p]` 只記在父節點的索引位置上，記錄「這個父節點後面緊接著幾個子項目」。之後任何元件只要拿到這份陣列，就能用一個 `while cnd="not(mnu_count[k]=999999)"` 迴圈重建整棵樹，不必再查資料庫，也不必用遞迴——這是刻意用「查一次、陣列共用」換取「後續元件零查詢」的效能策略（詳見第五章陣列作為查找表）。

### 15.3 元件重用：asider.wml 完全不查資料庫

`asider.wml` 示範了共用元件之間如何靠陣列傳遞資料，而不是重複查詢：

```xml
<card id="asider" device="sub">
  <setvar name="i" value="0"/>
  <setvar name="k" value="0"/>
  <block name="asider.aa"/>
  <while cnd="not(mnu_count[k]=999999)">
    <!-- 直接讀 header.wml 建好的 mnu_id[]/mnu_typ[]/mnu_count[]，無自己的 dbquery -->
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

前提是 `<include name="header"/>` 必須排在 `<include name="asider"/>` 之前，讓 `mnu_id[]` 等陣列先被建好——這是 include 順序即資料相依順序的實例，也是本節相依總表中 `asider.wml` 那一列「無自己的 `dbquery`」的由來。

### 15.4 依內容類型動態決定連結目標

選單項目點下去該連到哪個頁面，不是寫定的，而是依 `pa.typ` 動態判斷。`header.wml`、`asider.wml`、`grid.wml`、`index.wml` 四個檔案裡都各自寫了一份幾乎相同的 `switch`：

```xml
<switch exp="mnu_typ[k]">
  <case value="b"><setvar name="app" value="'book'" /></case>
  <case value="n"><setvar name="app" value="'note'" /></case>
  <case value="p"><setvar name="app" value="'page'" /></case>
  <case value="s"><setvar name="app" value="'shop'" /></case>
  <default>       <setvar name="app" value="'grid'" /></default>
</switch>
```

`app` 算出來後，模板裡的連結就寫成 `href="$(app).wml?gp=$(mnu_id[k])"`。這段 `switch` 在四支檔案裡重複了六次以上——這是實際生產程式碼中常見的權衡：對外連結規則簡單穩定，重複內嵌比抽成共用 `block` 更直覺、修改風險更低；但如果日後要新增第六種內容類型（例如影片頁 `typ='v'`），就必須記得同步改六個地方。**這是本章刻意保留的真實瑕疵，而非教學示範**：如果你在自己的專案裡看到同一段 `switch` 出現三次以上，通常就是該抽成共用 `block` 的訊號。

### 15.5 AJAX 局部載入：手冊與須知的雙檔設計

`book.wml`／`note.wml` 只負責畫選單框架，真正的內文由 `book-js.wml`／`note-js.wml` 用 AJAX 局部載入，兩者結構完全對稱。以手冊為例：

```xml
<!-- book.wml：content sub card 只吐出一個容器 + JS 呼叫 -->
<card id="content" device="sub">
  <![CDATA[
    <div id="xyz"></div>
    <script>loadDoc('book-js.wml?pg=$id');</script>
  ]]>
</card>
```

```xml
<!-- book-js.wml：獨立的一支 wml，device="wapform-js.html" -->
<card id="P" title="文具百貨" device="wapform-js.html">
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

`loadDoc()` 定義在共用的 `wapform.html` 模板裡，是一段標準的 `XMLHttpRequest`：

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

`book.wml` 側邊欄每個選單項目都是 `<a href="javascript:loadDoc('book-js.wml?pg=$itm.pno')">`，點擊時只重新請求 `book-js.wml`（單一 `topic` 欄位），**不整頁重新整理，也不重新跑選單建構邏輯**。這是「選單框架頁」與「內容頁」拆成兩支 `.wml` 的核心價值：內容頁可以獨立被快取、獨立測試，甚至未來換成其他語言實作也不影響外層框架。`device="wapform-js.html"` 是專為這類局部片段準備的精簡模板，不含 `<head>`／選單／頁尾，只輸出內容本身。

### 15.6 商店首頁：三種操作模式與安全的動態查詢組裝

`index.wml` 用 `op` 參數在同一支檔案裡切換三種語意完全不同的模式：

| `op` 值 | 語意 | 對應 `content` card 查詢 |
|---|---|---|
| `s` | 搜尋 | 依關鍵字動態組 `WHERE` |
| `g` | 本期特價商品 | `web` 表 JOIN `pa` |
| `i` | 分類清單 | `pa.gid = 指定分類` |

其中 `op='s'` 的搜尋最值得拆解，因為它示範了**用字串函數手動解析多關鍵字，並用固定的引號逃脫方式組裝安全的 SQL 條件**：

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

`gp='貓 罐頭'` 這種以空白或 `+` 分隔的多關鍵字輸入，會被逐字掃描切成片段，每一段都拼成一組 `pno LIKE '%...%' OR des LIKE '%...%'`，最後串接成完整的 `WHERE` 子句片段 `s`，交給下方的 `dbquery` 使用。**注意 SQL 字串裡兩個連續單引號 `''` 才是逃脫後的一個單引號**——這是手動組字串拼接查詢時最容易出錯、也最需要留意注入風險的地方；正式環境建議搭配欄位白名單或參數化查詢進一步收斂風險。

`az` 參數則決定排序策略：`az`／`za` 是依 `pno` 正序／倒序，`aa` 是依歷史銷量（`LEFT JOIN sn` 加總 `qty` 後 `ORDER BY amount DESC`）由熱賣到冷門排序，`zz` 則是僅限管理者（`session.usr='admin'`）用的資料檢視模式，用來檢查 `active>1` 的異常商品。這種「用同一個查詢入口，靠一個模式參數切換完全不同的排序／過濾邏輯」的寫法，好處是分頁、搜尋框、排序按鈕都共用同一支 `content` card，不必為每種排序各寫一支頁面。

### 15.7 分頁列產生器：`navigator` sub card

分頁按鈕本身也是一個獨立的 sub card，只依賴 `PG`（目前頁碼）與 `PAGES`（總頁數，`CEIL(總筆數/20)`），動態算出「目前頁前後各顯示 5 頁」的視窗：

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

`navigator` 完全重跑一次與 `content` card 相同的查詢條件組裝邏輯（只是不撈欄位、只取 `count`），這是「查詢條件邏輯必須在兩張 card 裡各自維護一份」的真實成本——資料筆數與內容清單分屬兩支獨立查詢，一旦搜尋條件改變寫法，兩處都要同步修改，這也是為什麼 15.4 節提到的「重複邏輯」判斷準則同樣適用在這裡。

### 15.8 購物車彙總：`header.wml` 內建的金流試算

有趣的是，購物車小計並非獨立頁面，而是內建在**每一頁都會 include 的 `header.wml`** 裡，讓任何頁面的頁首購物車圖示都能即時顯示品項數與金額：

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

購物車是否有內容，完全由 `session.ord`（是否已建立訂單流水號）決定；未達 1000 元加收 90 元運費、稅金抓固定 5%，這兩條業務規則直接寫在 `header.wml`，代表任何頁面都能反映「加入購物車後總金額是否跨過免運門檻」——這正是第三章 3.8 節「Web 會員登入與 Session 管理」模式在真實站台裡的落地版本。

### 15.9 Session 存活期：三層壽命與逐變數到期

購物站台有兩種必須跨頁保留的狀態：登入身分（`session.usr`）與購物車流水號（`session.ord`）。兩者該活多久，答案並不一樣——身分關乎安全，放太久有風險；購物車流水號放太久則會佔著未結帳的暫存資料。這一節說明能控制到什麼程度。

**先認清狀態的壽命是分層的**

| 層級 | 控制方式 | 目前行為 |
|---|---|---|
| session 變數 | `<session expire="分鐘"/>` | 不設＝不會自己過期 |
| 瀏覽器 cookie | 伺服器設定 | 發出後 1 天 |
| 伺服器 session | 伺服器設定 | 最後一次請求後閒置 7 天回收 |
| 伺服器行程 | 無 | 重啟即全部消失 |

**最先到期的那一層說了算**。現況是 cookie 的 1 天最短，所以實際上「登入後最多記住 1 天」——即使把 `expire` 寫成 7 天也沒有用，使用者第 2 天回來時瀏覽器已經沒有 session ID，伺服器找不到對應的 session。

這一點在設計時要從最短的那一層往回推算，不要假設自己寫的數字就是最終行為。

**逐變數到期**

同一個 session 裡的變數可以有各自的壽命：

```xml
<!-- 登入身分 8 小時 -->
<session name="usr" value="A" expire="480"/>

<!-- 購物車流水號只留 2 小時，逾時自動釋放 -->
<session name="ord" value="S" expire="120"/>
```

引擎會在每次請求解析卡片之前先清掉過期的變數，所以讀取端不必自己判斷逾時：

```xml
<!-- session.usr 過期後，這個守衛自然就會把人導去登入頁 -->
<if cnd="NOT(DEFINE(session.usr))">
  <redirect href="login.wml"/>
  <exit/>
</if>
```

需要續期就重新寫入同一個變數，到期時間從當下重新計算：

```xml
<session name="usr" value="session.usr" expire="480"/>
```

**不設 `expire` 的情況**

省略 `expire` 不代表「不儲存」，而是「不設定自己的到期時間」——變數會一直存在，直到整個 session 消失為止。既有的 WML 完全不需要改寫。

**重要的狀態不要只放 session**

上表最後一列值得留意：session 資料存在伺服器記憶體，行程重啟就全部消失，這不是 WML 能控制的。因此未結帳的購物車內容應該寫進資料庫（本站是寫入 `rn` 資料表，`session.ord` 只保存流水號），session 裡只放「指向資料的鍵」而不是資料本身。這樣即使 session 消失，使用者重新登入後訂單仍在。

**順帶一提：不要在 session 裡存密碼**

本站的 `login.wml` 驗證成功後寫入了兩個變數：

```xml
<session name="usr" value="A"/>
<session name="pwd" value="B"/>
```

其中 `pwd` 存的是密碼原文，但全站沒有任何頁面讀取 `session.pwd`，驗證時用的是 `MD5(B)` 比對。這種只寫不讀的敏感值應該直接移除——它沒有任何用途，只是讓密碼多在記憶體裡停留一份。

### 15.10 本章小結

| 手法 | 對應章節 | real-world 用途 |
|---|---|---|
| 一次查詢建陣列、多元件共用 | 15.2 / 15.3 | 選單樹只查一次資料庫，`asider.wml` 零查詢 |
| `typ` 欄位驅動路由 | 15.4 | 一張表身兼分類、商品、手冊、須知，靠型態欄位分流 |
| 框架頁／內容頁雙檔 AJAX | 15.5 | 手冊、須知內文可獨立更新、不觸發整頁重繪 |
| 手動字串解析組動態 WHERE | 15.6 | 多關鍵字搜尋，需留意單引號逃脫與注入風險 |
| 獨立分頁 sub card | 15.7 | 分頁邏輯與內容查詢解耦，但查詢條件需雙處同步 |
| Session 驅動的頁首購物車彙總 | 15.8 | 全站共用元件內嵌業務規則（運費門檻、稅率） |
| Session 三層壽命與逐變數到期 | 15.9 | 登入身分與購物車流水號各自設定存活期 |

這些手法沒有一個是「教科書寫法」，全部來自同一組正在對外服務的檔案——包含它們的重複、取捨與已知的維護成本。本章逐節拆解的原始檔案為 `header.wml`、`footer.wml`、`asider.wml`、`index.wml`、`grid.wml`、`book.wml`、`book-js.wml`、`note.wml`、`note-js.wml`、`page.wml`、`wapform.html` 共十一支，讀者可對照完整脈絡。

---

---

## 第十六章　同一份定義，落地到 Flutter（WapForm for Flutter）

*（沿用第十四章「文具百貨」銷貨管理系統的 `app001`～`app902` 共 12 支 `.wml`，解說同一套定義如何落地成 Flutter）*

第十四章看到的 12 支 `.wml` 檔案，並不是只能落地成 Windows 桌面程式。WapForm for Flutter 讓**同一份 WML 定義**不改一行，就能由 WapForm Toolkit 的產生器展開成一整套 Flutter 頁面；產生出來的 Dart 程式碼，呼叫的就是本書各節 📱 Flutter 段落介紹的 `wapform_flutter` 模組。

### 16.1 為什麼需要另一個 Runtime

多平台開發真正昂貴的地方，從來不是「元件長什麼樣子」，而是**每換一個平台，就得重新開發一次應用程式邏輯**。WapForm 要解決的不是元件的移植，而是**應用程式定義方式**的移植：資料來源、欄位、查找、事件、表單、報表，全部用 WML 描述，不綁定任何平台的語法。

> **定義一次，落地多次。**

`wapform_flutter` 就是 WML 落地到 Flutter 所需要的 Runtime；它同時也是一般的 Dart 套件，可以不經產生器直接手寫使用。

### 16.2 套件架構：WapForm 模組

| 模組 | 角色 | 對應的 WML |
|---|---|---|
| `wapform_expression.dart` | 運算式引擎 `WapEvaluator`：近 600 個內建函數、可註冊自訂函數；不依賴資料庫 | 第六章、附錄 B、附錄 C |
| `wapform_lazarus.dart` | 標籤引擎：`useEngine()`、`setvar()`、`expression()`、`condition()`、`expand*()`、`invoke()`、`varChangeHooks`；資料集註冊表 `DataSetRegistry`；查詢 `DbQuery` | `<setvar>`、`<if>`、`<while>`、`<invoke>`、`<dbquery>`、`$(...)` |
| `wapform_lookup_box.dart` | 查找下拉框 `WapLookupBox` | `<input lookup>`、`<item lookup>` |
| `wapform_filter.dart` | 查詢列 `WapFilter`／`FilterItem` | `<dbfilter>` |
| `wapform_report.dart` | 分組報表引擎 `WapReport`、報表預覽頁 `WapPage`、紙張與方向工具 | `<report>`、`<group>`、`<page>`、`<newpage>`、`device="PRV"` |
| `wapform_report_style.dart` | 報表 CSS：`reportCssScreen`、`reportCssPrint`、`reportCssSrc` | 報表的 `class="wap"` 等樣式 |
| `report_web.dart` | 依平台自動切換的列印實作（Web：新分頁列印） | Web 上的列印 |
| `wapform_colors.dart` | `WapColors`：從 `assets/wapform.htm` 讀取共用色彩 | `class="row1"`／`"row2"` 隔行色 |

### 16.3 WML 標籤如何逐一映射成 Dart 類別

| WML | Dart |
|---|---|
| `<dbquery id="em">` | `await db.query("em", sql)` |
| `<setvar name= value=>` | `setvar(name, value)` |
| `<if cnd=>`／`<while cnd=>` | `if (condition(...))`／`while (condition(...))` |
| `<invoke instance= method=>` | `invoke(instance, method)` |
| `$(...)` | `expandText()`；SQL 中 `expandSql()` |
| `<input lookup=>` | `WapLookupBox` |
| `<dbfilter>` | `WapFilter` |
| `<report>`／`<group change=>` | `WapReport` 子類別、`expression(idx)` |
| `device="PRV"` | `WapPage` |
| `<platform name="flutter">` | CDATA 內容原樣成為 Dart 程式碼 |

各標籤的完整對照見第四章每個標籤的 📱 Flutter 段落與第 4.13 節的對照表。這種一對一映射，讓產生器輸出可以完全機械化。

### 16.4 主從結構映射：出貨單與明細

`masterfields="sno"` 這個宣告式主從關聯，在 Flutter 展開成「表頭游標移動 → 以表頭單號重查明細」，新增明細時帶入表頭單號：

```dart
Future<void> onShipmentScroll() =>
    db.query("sn", r"select * from sn where sno=$(AsQuoted(sh.sno)) order by itm");

void onNewItem() => setvar("sn.sno", "sh.sno");
```

這與第 3.2 節「模式：主從結構」在 Windows 端的行為一致，只是事件掛勾點不同。`<item lookup="pa;pno;des">` 則由 `WapLookupBox(forGrid: true)` 在表格儲存格內提供查找清單。

### 16.5 報表引擎映射：分組小計如何變成 `parseBlock`/`emitRow`

`<group change="sh.cno">` 的三段結構（分組開始、逐列輸出、分組結束），展開成 `WapReport.parseBlock()` 的 `G1_PREFIX`、`RECORD`、`G1_SUFFIX`；`change=` 的運算式就是 `expression(0)` 的傳回值（完整程式見第 4.7 節 `<group>` 的 📱 Flutter 段落）。

`emitRow()` 每輸出一行就檢查一次行數，滿 `wap.wapLpp` 行就輸出 `PAGESUFFIX` → `PAGEBREAK` → `PAGEPREFIX`——不管這一列是從 WML 的 `<group>` 產生還是手寫，呼叫端都不必追蹤印了幾行。子報表（`device="sub"`）輸出的列也算在同一個頁面流裡，巢狀多層也不會把版面撐破。

`WapPage` 參數：

| 參數 | 說明 |
|---|---|
| `title` | 標題 |
| `report` | `WapReport` 物件（與 `src` 二擇一） |
| `src` | 直接給 HTML，會先經過 `expandText()`（與 `report` 二擇一） |
| `paper` | `A4`（預設）、`A3`、`A5`、`B5`、`letter`、`legal`，或自訂英吋 `"8.5x5.5"` |
| `orient` | `P`（預設）；`L`、`landscape`、`1`、`橫`、`水平` 為橫式 |
| `showPrint` | 是否顯示列印按鈕 |
| `fontAsset` | 產生 PDF 時用的中文字型（預設 `assets/fonts/NotoSansTC-Regular.ttf`） |
| `padding`、`htmlStyle` | 版面邊距與自訂 HTML 樣式 |

紙張工具函數：`isLandscape(orient)`、`normalizePaper(paper)`、`customPaperSizeInches(paper)`（`"8.5x5.5"` → `(8.5, 5.5)`）、`pageSizeOf(paper, orient)`（CSS `@page size` 的值）。

### 16.6 檔案架構：一個檔案一個獨立單元

`wapform_flutter.dart` 是 barrel file，`import 'package:wapform_flutter/wapform_flutter.dart'` 會把所有檔案一次拉進來；每個檔案也能單獨匯入，例如只要運算式引擎時匯入 `package:wapform_flutter/wapform_expression.dart` 即可。檔案扁平放在 `lib/` 底下、不藏進 `lib/src/`，就是為了保留單獨匯入的路。

| 檔案 | 依賴 |
|---|---|
| `wapform_expression.dart` | 只依賴 `crypto`，可單獨使用 |
| `wapform_lazarus.dart` | 運算式引擎 ＋ 套件的資料集 |
| `wapform_lookup_box.dart`、`wapform_filter.dart` | Flutter |
| `wapform_report.dart` | 標籤引擎 ＋ `wapform_report_style.dart` ＋ `report_web.dart` |
| `wapform_colors.dart` | Flutter（讀 asset） |

### 16.7 實例驗證：`app001`～`app902` 一次全部轉譯

`example/lib/pages/` 底下的 12 支 `.dart` 檔案，由 WapForm Toolkit 從第十四章的 `app001.wml`～`app902.wml` 自動產生：

| Flutter 頁面 | 對應第十四章 | 資料表 |
|---|---|---|
| `app001.dart` | 14.2　系統參數建檔 | `sys` |
| `app002.dart` | 14.2／14.6　產品資料建檔（含 `<platform>` 圖片上傳） | `pa`（`web`／`ve` 為查找來源表） |
| `app003.dart` | 14.2　廠牌資料建檔 | `ve` |
| `app004.dart` | 14.2　客戶資料建檔 | `cu` |
| `app005.dart` | 14.2　員工資料建檔 | `em` |
| `app006.dart` | 14.4～14.7、14.9　出貨單建檔 | `sh`／`sn`／`cu`／`em` |
| `app007.dart` | 14.8　客戶資料表列印 | `cu` |
| `app012.dart` | 14.8　應收對帳單（分組報表） | `sh`（`sys` 提供抬頭設定值） |
| `app023.dart` | 14.3　收款單查詢 | `sh`／`cu`／`fm` |
| `app037.dart` | 14.2　貨運資料建檔 | `fm` |
| `app901.dart` | 14.10　帳號管理作業 | `users` |
| `app902.dart` | 14.10　密碼（權限）資料建檔 | `mnu`／`login`／`users` |

`example/` 也附上對應的 `*.wml`，可以逐一比對每個標籤產生了什麼。

### 16.8 平台現況與已知限制

- **支援平台**：Web 與 Android。
- **資料庫一律經 HTTP 閘道**：瀏覽器不能直接開資料庫連線，套件的 `example/server/` 附有 Node.js 閘道。
- **列印**：Web 交給瀏覽器的列印；Android 由系統 WebView 排版後產生向量 PDF。
- **沒有對應模組的 WML 功能**：交叉列表、圖表、Web 模板與 Session、`<open>`／`<webcopy>`、寄信等；需要時以 `<platform name="flutter">` 嵌入 Dart 程式碼（第 4.5 節）。
- **運算式引擎差異**：見附錄 C。

### 16.9 安裝與授權

```yaml
dependencies:
  wapform_flutter: ^1.6.7
```

```dart
import 'package:wapform_flutter/wapform_flutter.dart';
```

授權採 **LGPL-2.1 附靜態連結例外**（「Modified LGPL」）：可以在閉源 App 裡使用這個套件；只有重新散布「套件本身原始檔案」的修改版時，那些修改才需要用同一份授權公開。這與 WapForm Toolkit（產生器）的商業授權是分開的兩件事。

### 16.10 本章小結

| 手法 | 對應章節 | 用途 |
|---|---|---|
| WapForm 模組架構 | 16.2、16.6 | 運算式、標籤引擎、查找、查詢列、報表各自獨立，可個別匯入 |
| WML 標籤到 Dart 的一對一映射 | 16.3 | 讓產生器輸出完全機械化 |
| `masterfields` → 表頭移動時重查明細 | 16.4 | 宣告式主從關聯，展開成父層事件連動 |
| `<group change>` → `parseBlock`／`emitRow` | 16.5 | 分組報表引擎橫跨 Windows／Flutter 兩個 Runtime 的同一套設計 |
| `<platform>` | 4.5 | Flutter 尚無對應標籤的功能，以 Dart 程式碼補上 |
| 同一套 12 支 `.wml` 產生 12 支 `.dart` | 16.7 | 銷貨管理系統在 Windows 與 Flutter 兩個平台的具體對照 |

第十四章與本章合起來看，是同一句話的兩次示範：**WapForm 是應用程式的 Source of Truth，Runtime 只是落地層**。

---

## 附錄 A　快速參考卡

### Card `device` 值

| `device` | Windows | Web | 視窗/渲染類型 |
|---|---|---|---|
| *(省略)* / `wap` | ✅ | ❌ | 輸入表單 |
| `MDI` | ✅ | ❌ | MDI 父視窗 |
| `prv` | ✅ | ❌ | 列印預覽 |
| `prn` | ✅ | ❌ | 直接列印 |
| `SUB` / `sub` | ✅ | ✅ | 背景執行——無 UI |
| `XYZ` | ✅ | ❌ | 帶副作用模型的背景執行 |
| `wapform.html` | ❌ | ✅ | Web 主頁 card，套用 HTML 模板 |
| `wapform-js.html` | ❌ | ✅ | Web 主頁 card，套用含 JS 模板 |

### 導覽

| 元素 | Win | Web | 動作 |
|---|---|---|---|
| `&lt;go href="#id"/&gt;` | ✅ | ✅ | 跳轉至 card |
| `&lt;go href="@id"/&gt;` | ✅ | ✅ | 呼叫函式 |
| `&lt;prev/&gt;` | ✅ | ❌ | 返回上一張 card |
| `&lt;exit/&gt;` | ✅ | ✅ | 離開目前 SUB 或流程 |
| `&lt;redirect href="url"/&gt;` | ❌ | ✅ | HTTP 重新導向 |

### Web 專用物件

| 運算式 | 說明 |
|---|---|
| `request.param` | HTTP GET/POST 參數值 |
| `session.var` | 伺服器端 session 變數 |
| `DEFINE(request.foo)` | 檢查 request 參數是否存在 |
| `DEFINE(session.foo)` | 檢查 session 變數是否存在 |

### Session 寫入與存活期

| 寫法 | 作用 |
|---|---|
| `&lt;session name="usr" value="A"/&gt;` | 寫入，跟隨整個 session 的壽命 |
| `&lt;session name="usr" value="A" expire="480"/&gt;` | 寫入，480 分鐘後自動失效（需 2026-09 後引擎版本） |
| `&lt;session name="usr" value="''"/&gt;` | 刪除（連同到期戳） |
| `&lt;session name="usr" value="A" expire="0"/&gt;` | 保留值，清除到期設定 |
| `&lt;session name="k" value="'1'" cnd="運算式"/&gt;` | 條件成立時才寫入 |

`expire` 常用換算：`60`＝1 小時、`480`＝8 小時、`1440`＝1 天、`10080`＝7 天、`43200`＝30 天。

| 壽命層級 | 控制方式 | 預設 |
|---|---|---|
| session 變數 | `expire` 屬性 | 無到期 |
| 瀏覽器 cookie | 伺服器設定 | 關閉瀏覽器即失效 |
| 伺服器 session | 伺服器設定 | 閒置 7 天 |

session 資料存於伺服器記憶體，重啟即全部失效。詳見 4.11、7.4 與 15.9 節。

### 資料集方法

| `&lt;call name="ds" method="..."/&gt;` | Win | Web | 動作 |
|---|---|---|---|
| `first` / `last` / `next` / `prior` | ✅ | ✅ | 游標移動 |
| `locate` params=`"'field';value"` | ✅ | ✅ | 依鍵值尋找 |
| `post` / `cancel` | ✅ | ⚠️ | 儲存 / 放棄 |
| `refresh` | ✅ | ⚠️ | 從資料庫重新載入 |
| `edit` / `insert` / `delete` | ✅ | ❌ | 狀態切換 |
| `DisableControls` / `EnableControls` | ✅ | ❌ | 迭代期間凍結 UI |
| `GetBookmark` / `GoToBookmark` / `FreeBookmark` | ✅ | ❌ | 書籤操作 |

### 運算式中的資料集屬性

| 運算式 | 值 |
|---|---|
| `ds.field_name` | 目前列的欄位值 |
| `ds.COUNT` | 總列數 |
| `ds.EOF` / `ds.BOF` | 游標位置旗標 |
| `ds.state` | `'BROWSE'` / `'EDIT'` / `'INSERT'`（Win）|

### 事件快速參考（Windows 專用）

| 事件 | 宣告位置 | 觸發時機 |
|---|---|---|
| `onnewrecord` | `&lt;dbquery&gt;` / `&lt;dbtable&gt;` | 新增記錄時 |
| `beforedelete` | `&lt;dbquery&gt;` / `&lt;dbtable&gt;` | 刪除前 |
| `afterpost` | `&lt;dbquery&gt;` / `&lt;dbtable&gt;` | 儲存後 |
| `afterscroll` | `&lt;dbquery&gt;` / `&lt;dbtable&gt;` | 游標移動後 |
| `onchange` | `&lt;input&gt;` | 值變更時 |
| `oncloseup` | 帶 lookup 的 `&lt;input&gt;` | Lookup 選取後 |
| `onexit` | `&lt;input&gt;` | 失去焦點時 |
| `ondblclick` | `&lt;dbgrid&gt;` | 列雙擊時 |
| `oncalccellcolors` | `&lt;dbgrid&gt;` | 儲存格繪製時 |

### 函數速查

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

**📱 Flutter 速查**

| 需求 | Dart |
|---|---|
| 指定目前 card 的引擎 | `useEngine(_ev, _reg)` |
| 開查詢（`<dbquery id>`） | `await db.query("x", r"select ... where a='$v'")` |
| 帶參數查詢 | `await db.query("x", "... where a=:a", params: {"a": v})` |
| 不傳回資料列的 SQL | `await db.exec(r"update ...")` |
| 設定變數或欄位 | `setvar("TOTAL", "pa.qty*pa.price")`、`setvar("pa.icon", "'a.jpg'")` |
| 原樣存入 Dart 值 | `_ev.setVar("NAME", userInput)` |
| 計算／條件 | `expression("TOTAL*1.05")`、`condition("(qty>0) AND (price<100)")` |
| 文字／SQL 插值 | `expandText(r"$(pa.des)")`、`expandSql(r"where $S")`、`expandSqlAuto(r"where a=$v")` |
| 資料集方法 | `invoke("pa", "first")` |
| 查找 | `WapLookupBox(dataSet:, keyField:, displayFields:, value:, onPicked:)` |
| 查詢列 | `WapFilter(items: [FilterItem(...)], sqlTemplate: r"... where $R", onQuery:)` |
| 報表 | `WapReport` 子類別 ＋ `WapPage(title:, report:, paper:, orient:)` |
| 換頁 | `forcePageBreak()` |
| 自訂函數 | `_ev.addFunction1Param("TAXED", (v) => (v as num) * 1.05)` |

### 常見模式速覽

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

## 附錄 B　函數完整參考

> 本附錄完整收錄 WapForm 運算式核心（`TmyParser`）的全部標準函式庫，共 **398 個函式**，
是 WapForm 語言最基礎的一層，Windows、Web、Flutter、COBOL 各平台皆共通支援。

> 呼叫方式：在 WapForm 運算式中直接以函式名稱呼叫，不需任何前綴，例如 `$(ABS(v1))`、`$(UPPER(name))`。

---

### 目錄

1. 數學運算（55 個）
2. 統計集合（12 個）
3. 字串處理（86 個）
4. 數值轉換（55 個）
5. 日期與時間（62 個）
6. 條件與邏輯（21 個）
7. 地區化（9 個）
8. 隨機數（1 個）
9. 加解密與安全（5 個）
10. 系統與環境（27 個）
11. 路徑處理（6 個）
12. 動態變數與陣列（14 個）
13. 財務函數（8 個）
14. 其他內建函式（本次新增測試涵蓋）（34 個）
15. 其他內建函式（不適合自動化測試）（10 個）

---

### B.1　數學運算

| 函式 | 說明 | 範例 |
|---|---|---|
| `ABS(x)` | 絕對值 | `ABS(-5)=5` |
| `ACOS(x)` | 反餘弦 | `ACOS(0)=1.5708` |
| `ASIN(x)` | 反正弦 | `ASIN(1)=1.5708` |
| `ATAN(x)` | 反正切 | `ATAN(1)=0.7854` |
| `COS(x)` | 餘弦 | `COS(0)=1` |
| `SIN(x)` | 正弦 | `SIN(0)=0` |
| `TAN(x)` | 正切 | `TAN(0)=0` |
| `SQRT(x)` | 平方根 | `SQRT(16)=4.0` |
| `EXP(x)` | e 的次方 | `EXP(1)=2.71828` |
| `LN(x)` | 自然對數 | `LN(2.71828)=1` |
| `LOG(x)` | 以 10 為底的對數 | `LOG(100)=2` |
| `POWER(x,n)` | x 的 n 次方 | `POWER(2,10)=1024` |
| `PI` | 圓周率常數 | `PI=3.14159` |
| `INT(x)` | 取整數部分（向零截斷） | `INT(9.8)=9` |
| `FIX(x)` | 取整數（向負無窮取整） | `FIX(-9.8)=-10` |
| `CEIL(x)` | 無條件進位 | `CEIL(2.1)=3` |
| `TRUNC(x)` | 截去小數部分，向零方向取整數（不論正負） | `TRUNC(3.9)=3` |
| `FLOOR(x)` | 無條件捨去 | `FLOOR(2.9)=2` |
| `ROUND(x,d)` | 四捨五入到 d 位小數（標準四捨五入） | `ROUND(3.456, 2)=3.46` |
| `FRAC(x)` | 取小數部分 | `FRAC(3.75)=0.75` |
| `MAX(a,b)` | 回傳兩者中較大值 | `MAX(3,7)=7` |
| `MIN(a,b)` | 回傳兩者中較小值 | `MIN(3,7)=3` |
| `MOD(a,b)`（運算子） | 取餘數運算子 | `MOD(7,3)=1` |
| `GreatestCommonDivisor(a, b)` | 最大公因數（Euclidean algorithm） | `GreatestCommonDivisor(12,18)=6` |
| `ClampValue(value, lo, hi)` | 將值限制在 [lo, hi] 範圍 | `ClampValue(15,0,10)=10` |
| `LerpValue(a, b, t)` | 線性插值 a + (b-a)*t | `LerpValue(0,10,0.5)=5` |
| `IsBetween(value, lo, hi)` | 判斷值是否在 [lo, hi] 範圍內 | `IsBetween(5,1,10)=True` |
| `PercentOf(part, total)` | 百分比計算，total=0 時回傳 0 | `PercentOf(25,200)=12.5` |
| `RoundBankers(value, decimals)` | 銀行家捨入（四捨六入五取偶） | `RoundBankers(2.5,0)=2` |
| `IsPrimeNumber(n)` | 判斷是否為質數 | `IsPrimeNumber(7)=True` |
| `Fibonacci(n)` | 第 n 個費波那契數（0-based：F(0)=0, F(1)=1） | `Fibonacci(10)=55` |
| `Log2Value(x)` | 以 2 為底的對數 | `Log2Value(8)=3` |
| `LogNValue(base, x)` | 以 base 為底的對數 | `LogNValue(3,9)=2` |
| `HypotOf(a, b)` | 直角三角形斜邊 sqrt(a²+b²) | `HypotOf(3,4)=5` |
| `DegreeToRad(deg)` | 角度 → 弧度 | `DegreeToRad(180)=3.14159` |
| `RadToDegree(rad)` | 弧度 → 角度 | `RadToDegree(3.14159)=180` |
| `CubeRoot(x)` | 立方根（cube root） | `CubeRoot(27)=3` |
| `EvenCeil(n)` | 取不小於 n 的最小偶數 | `EvenCeil(3)=4` |
| `SumOfSquares(values)` | 各項平方和 Σ(xᵢ²) | `SumOfSquares([1,2,3])=14` |
| `ProductOf(values)` | 各項乘積 Π(xᵢ) | `ProductOf([2,3,4])=24` |
| `HarmMeanValue(values)` | 調和平均數 n / Σ(1/xᵢ) | `HarmMeanValue([1,2,4])=1.71428571428571` |
| `GeoMeanValue(values)` | 幾何平均數 (Πxᵢ)^(1/n) | `GeoMeanValue([1,3,9])=3` |
| `QuartileOf(values, q)` | 四分位數；q=1 Q1, q=2 中位數, q=3 Q3 | `QuartileOf([1,2,3,4,5,6,7,8,2])=4.5` |
| `NetPresentValue(rate, values)` | 淨現值 NPV；第一個引數為折現率，其餘為各期現金流 | `NetPresentValue([0.1,-1000,400,500,600])=206.953076975616` |
| `InternalRateOfReturn(values, guess)` | 內部報酬率（Newton-Raphson 迭代，最多 100 次）；最後一個引數為初始猜測值 | `InternalRateOfReturn([-1000,400,500,600,0.1])=0.216477854184290` |
| `Exp10Value(n)` | 10 的引數次方 | `Exp10Value(2)=100` |
| `Log10Value(n)` | 以 10 為底的對數 | `Log10Value(100)=2` |
| `RemainderValue(n, d)` | 取浮點餘數，結果符號同被除數（與 MOD 語意不同） | `RemainderValue(-7,3)=-1` |
| `ToIntegerValue(n)` | 取不超過引數的最大整數（向下取整） | `ToIntegerValue(-3.5)=-4` |
| `IntegerPart(n)` | 截去小數部分（向零取整） | `IntegerPart(-3.5)=-3` |
| `FractionPart(n)` | 回傳引數的小數部分 | `FractionPart(3.75)=0.75` |
| `Factorial(n)` | 階乘 n! | `Factorial(5)=120` |
| `EulerNumber` | 自然常數 e ≈ 2.71828…（無參數） | `EulerNumber=2.71828` |
| `SignOf(n)` | 回傳 -1、0 或 1，代表引數的正負或零 | `SignOf(-8)=-1` |
| `Annuity(rate, periods)` | 每期年金現值因子 ANNUITY(rate, periods) | `Annuity(0.05,10)=0.1295` |
| `PresentValue(rate, amounts…)` | 現值計算，第一個引數為折現率，其餘為各期金額 | `PresentValue([0.1,100,200,300])=481.592787377911` |

---

### B.2　統計集合

| 函式 | 說明 | 範例 |
|---|---|---|
| `COUNT(v1, v2, …)` | 計數（陣列元素個數） | `COUNT([1,2,3,4])=4` |
| `MeanValue(v1, v2, …)` | 算術平均值 | `MeanValue([2,4,6])=4` |
| `MedianValue(v1, v2, …)` | 中位數 | `MedianValue([1,3,2])=2` |
| `MidRangeValue(v1, v2, …)` | (最大值 + 最小值) / 2 | `MidRangeValue([2,10])=6` |
| `RangeValue(v1, v2, …)` | 全距（最大值 − 最小值） | `RangeValue([2,10,5])=8` |
| `SumOfValues(v1, v2, …)` | 加總所有引數 | `SumOfValues([1,2,3])=6` |
| `VarianceValue(v1, v2, …)` | 變異數 | `VarianceValue([2,4,6])=2.6667` |
| `StandardDeviation(v1, v2, …)` | 標準差 | `StandardDeviation([2,4,6])=1.6330` |
| `OrdMax(v1, v2, …)` | 回傳最大值在引數清單中的序號（1 起始） | `OrdMax([3,7,2])=2` |
| `OrdMin(v1, v2, …)` | 回傳最小值在引數清單中的序號（1 起始） | `OrdMin([3,7,2])=3` |
| `HighestAlgebraic(n)` | 回傳引數之資料型別可表示的最大值（依實際型別判斷），與引數數值無關 | `HighestAlgebraic(123)=2147483647` |
| `LowestAlgebraic(n)` | 回傳引數之資料型別可表示的最小值（依實際型別判斷），與引數數值無關 | `LowestAlgebraic(123)=(-2147483647-1)` |

---

### B.3　字串處理

| 函式 | 說明 | 範例 |
|---|---|---|
| `LEN(s)` | 字串長度（字元數） | `LEN('Hello')=5` |
| `LENA(s)` | 位元組長度 | `LENA('中文')=6（UTF-8 每字 3 byte）` |
| `AnsiLength(s)` | ANSI 位元組長度 | `AnsiLength('中文')=4（Big5 每字 2 byte）` |
| `LOWER(s)` | 轉小寫 | `LOWER('ABC')=abc` |
| `UPPER(s)` | 轉大寫 | `UPPER('abc')=ABC` |
| `AnsiLowerCase(s)` | ANSI 轉小寫 | `AnsiLowerCase('ABC')=abc` |
| `AnsiUpperCase(s)` | ANSI 轉大寫 | `AnsiUpperCase('abc')=ABC` |
| `TRIM(s)` | 去除頭尾空白 | `TRIM('  Hi  ')=Hi` |
| `LTRIM(s)` | 去左側空白 | `LTRIM('  Hi')=Hi` |
| `RTRIM(s)` | 去右側空白 | `RTRIM('Hi  ')=Hi` |
| `MID(s,p,n)` | 取子字串（byte 計數） | `MID('Wapform', 2, 3)='apf'` |
| `MIDA(s,p,n)` | 取子字串（ANSI 字元計數） | `MIDA('Hello',2,3)=ell` |
| `AnsiMid(s,p,n)` | 取子字串（ANSI 計數） | `AnsiMid('Hello',2,3)=ell` |
| `POS(sub,s)` | 找子字串位置（byte 計數） | `POS('lo','Hello')=4` |
| `FINDA(sub,s)` | 找子字串位置（ANSI 計數） | `FINDA('lo','Hello')=4` |
| `AnsiPos(sub,s)` | 找子字串位置（ANSI 計數） | `AnsiPos('lo','Hello')=4` |
| `INSTR(s,sub)` | 找尋字串位置 | `INSTR('Hello','lo')=4` |
| `REPLACE(s,old,new)` | 取代字串 | `REPLACE('hello', 'l', 'm')='hemmo'` |
| `REPLACEA(s,old,new)` | 取代字串（ANSI 版） | `REPLACEA('Hello','l','L')=HeLLo` |
| `REPLACEAT(s,p,new)` | 在指定位置取代 | `REPLACEAT('Hello',1,'J')=Jello` |
| `INSERT(s,p,n,new)` | 插入字串（byte） | `INSERT('Hllo',2,0,'e')=Hello` |
| `INSA(s,p,new)` | 插入字串（ANSI 計數） | `INSA('Hllo',2,'e')=Hello` |
| `AnsiInsert(s,p,new)` | 插入字串（ANSI 計數） | `AnsiInsert('Hllo',2,'e')=Hello` |
| `DELETE(s,p,n)` | 刪除子字串（byte） | `DELETE('Hello',1,1)=ello` |
| `DELA(s,p,n)` | 刪除子字串（ANSI 計數） | `DELA('Hello',1,1)=ello` |
| `AnsiDelete(s,p,n)` | 刪除子字串（ANSI 計數） | `AnsiDelete('Hello',1,1)=ello` |
| `CHR(n)` | 碼點轉字元 | `CHR(65)=A` |
| `ASC(c)` | 字元轉碼點 | `ASC('A')=65` |
| `ORD(c)` | 字元序號（同 ASC） | `ORD('A')=65` |
| `CODE(s)` | 代碼欄位解析 | `CODE('001-ABC')=001（依資料格式而定）` |
| `NAME(s)` | 名稱欄位解析 | `NAME('001-ABC')=ABC（依資料格式而定）` |
| `REPT(s,n)` | 重複字串 n 次 | `REPT('*', 5)='*****'` |
| `FORMAT(fmt,x)` | 格式化輸出 | `FORMAT('0.00',3.5)=3.50` |
| `FormatDateTime(fmt,d)` | 依自訂樣式字串格式化日期時間 | `FormatDateTime('yyyy/mm/dd','2026-08-03')=2026/08/03` |
| `FormatFloat(fmt,n)` | 依自訂樣式字串格式化浮點數 | `FormatFloat('#,##0.00',12345.6)=12,345.60` |
| `LIKE(s,pat)` | 萬用字元比對 | `LIKE('Hello','H*o')=True` |
| `AnsiCompareStr(a,b)` | ANSI 區分大小寫比較 | `AnsiCompareStr('abc','abd')=-1` |
| `AnsiCompareText(a,b)` | ANSI 不分大小寫比較 | `AnsiCompareText('ABC','abc')=0` |
| `CompareStr(a,b)` | 字串比較（區分大小寫） | `CompareStr('abc','abd')=-1` |
| `CompareText(a,b)` | 本地化字串比較 | `CompareText('ABC','abc')=0` |
| `HEX(n,d)` | 整數轉十六進位字串 | `HEX(255,4)=00FF` |
| `ANSI(s)` | UTF-8 轉 ANSI | `ANSI('中文')=中文（轉為 Big5 編碼位元組）` |
| `UTF8(s)` | ANSI 轉 UTF-8 | `UTF8('中文')=中文（轉為 UTF-8 編碼位元組）` |
| `HTML(s)` | HTML 特殊字元轉義 | `HTML('<b>')=&lt;b&gt;` |
| `FillChar(s,c)` | 填充字元 | `FillChar(5,'*')=*****` |
| `LeftPad2(str, len)` | 左側補空白至 len 寬 | `LeftPad2('5',3)='  5'` |
| `RightPad2(str, len)` | 右側補空白至 len 寬 | `RightPad2('5',3)='5  '` |
| `CenterPad(str, len)` | 置中補空白至 len 寬 | `CenterPad('5',5)='  5  '` |
| `LeftPad(str, len, ch)` | 左側補指定字元至 len 寬 | `LeftPad('5',3,'0')='005'` |
| `RightPad(str, len, ch)` | 右側補指定字元至 len 寬 | `RightPad('5',3,'0')='500'` |
| `RepeatStr(str, n)` | 重複字串 n 次 | `RepeatStr('ab',3)='ababab'` |
| `CountStrOccur(substr, str)` | 計算子字串出現次數 | `CountStrOccur('a','banana')=3` |
| `StartsWithStr(str, prefix)` | 字串是否以 prefix 開頭 | `StartsWithStr('Hello','He')=True` |
| `EndsWithStr(str, suffix)` | 字串是否以 suffix 結尾 | `EndsWithStr('Hello','lo')=True` |
| `ContainsStr2(str, substr)` | 字串是否包含子字串 | `ContainsStr2('Hello','ell')=True` |
| `WrapStr(str, width)` | 每 width 字元插入換行（CRLF） | `WrapStr('HelloWorld',5)='Hello\nWorld'` |
| `SplitStr(str, delim, n)` | 以 delim 分割字串，取第 n 個 token（1-based） | `SplitStr('a,b,c',',',2)='b'` |
| `SplitCount(str, delim)` | 以 delim 分割字串，計算 token 數 | `SplitCount('a,b,c',',')=3` |
| `JoinStr(str, delim)` | 將 str 中以空白分隔的多個詞（可能連續多個空白）重新以 delim 串接；例：`JoinStr('A  B  C', ' ')` → `'A B C'` | `JoinStr('A  B  C',' ')='A B C'` |
| `TokenAt(str, delim, n)` | 取第 n 個 Token（1-based），允許多字元分隔符 | `TokenAt('a-b-c','-',2)='b'` |
| `EllipsisStr(str, maxLen)` | 超過 maxLen 時截斷並補 '...' | `EllipsisStr('HelloWorld',5)='Hello...'` |
| `CapWords(str)` | 每個單詞首字大寫（英文） | `CapWords('hello world')='Hello World'` |
| `CharAt(str, n)` | 取第 n 個字元（1-based），超出範圍回傳 '' | `CharAt('Hello',2)='e'` |
| `IndexOfStr(substr, str, start)` | 從 start 位置（1-based）開始找子字串 | `IndexOfStr('l','Hello',1)=3` |
| `LastIndexOfStr(substr, str)` | 從右側找子字串，回傳最後出現的位置（1-based） | `LastIndexOfStr('l','Hello')=4` |
| `RemoveChars(str, chars)` | 移除字串中出現在 chars 裡的所有字元 | `RemoveChars('Hello123','0123456789')='Hello'` |
| `KeepChars(str, chars)` | 只保留字串中出現在 chars 裡的字元 | `KeepChars('Hello123','0123456789')='123'` |
| `OnlyDigits(str)` | 移除所有非數字字元 | `OnlyDigits('A1B2C3')='123'` |
| `OnlyAlpha(str)` | 移除所有非英文字母字元 | `OnlyAlpha('A1B2C3')='ABC'` |
| `MaskStr(str, mask, placeholder)` | 依遮罩樣板逐字套用；遮罩中等於 placeholder 的位置依序填入 str 的字元，其餘位置保留遮罩原字元（如電話、身分證格式化），placeholder 預設為 '#' | `MaskStr('123456','##-##-##','#')='12-34-56'` |
| `UnmaskStr(str, mask, ch)` | 移除遮罩，只保留 '#' 位置的字元 | `UnmaskStr('12-34-56','##-##-##','#')='123456'` |
| `SlugifyStr(str)` | 轉換為 URL slug（小寫、空白→連字號、移除特殊字元） | `SlugifyStr('Hello World!')='hello-world'` |
| `TruncWords(str, n)` | 截斷至前 n 個單詞，超出加 '...' | `TruncWords('The quick brown fox',2)='The quick...'` |
| `CrLfToBr(str)` | 將換行符號（CRLF/LF）轉為 HTML <br/> | `CrLfToBr('A'+CRLF+'B')='A<br/>B'` |
| `BrToCrLf(str)` | 將 HTML <br/> / <br> 轉為 CRLF | `BrToCrLf('A<br/>B')='A'+CRLF+'B'` |
| `HtmlEncodeStr(str)` | HTML 特殊字元編碼 | `HtmlEncodeStr('<b>')='&lt;b&gt;'` |
| `HtmlDecodeStr(str)` | HTML 特殊字元解碼 | `HtmlDecodeStr('&lt;b&gt;')='<b>'` |
| `UrlEncodeStr(str)` | URL 百分比編碼（ASCII 範圍） | `UrlEncodeStr('a b')='a%20b'` |
| `ConcatenateStr(v1, v2, …)` | 串接多個字串 | `ConcatenateStr(['Hello',' ','World'])='Hello World'` |
| `ByteLength(n)` | 字串的位元組數 | `ByteLength('中文')=6` |
| `StoredCharLength(n)` | 去除尾端空白後的有效長度 | `StoredCharLength('Hi   ')=2` |
| `LowerCaseValue(n)` | 轉換為小寫 | `LowerCaseValue('ABC')='abc'` |
| `UpperCaseValue(n)` | 轉換為大寫 | `UpperCaseValue('abc')='ABC'` |
| `ReverseStr(n)` | 字串反轉 | `ReverseStr('Hello')='olleH'` |
| `SubstituteStr(s, from1, to1, …)` | 取代子字串（區分大小寫），引數為 (字串, 被取代值1, 取代值1, 被取代值2, 取代值2, …) 依序成對處理 | `SubstituteStr(['Hello','l','L'])='HeLLo'` |
| `SubstituteCaseStr(s, from1, to1, …)` | 取代子字串（不區分大小寫），引數格式同 SUBSTITUTE | `SubstituteCaseStr(['HeLlo','l','L'])='HeLLo'` |

---

### B.4　數值轉換

| 函式 | 說明 | 範例 |
|---|---|---|
| `VAL(s)` | 字串轉數值（依內容自動判斷整數或浮點數） | `VAL('3.14')=3.14` |
| `STR(n)` | 數值轉字串 | `STR(3.14)='3.14'` |
| `FloatToStr(n)` | 浮點數轉字串 | `FloatToStr(3.14)=3.14` |
| `IntToStr(n)` | 整數轉字串 | `IntToStr(42)=42` |
| `StrToFloat(s)` | 字串轉浮點數 | `StrToFloat('3.14')=3.14` |
| `StrToInt(s)` | 字串轉整數 | `StrToInt('42')=42` |
| `FLOAT(x)` | 強制轉浮點數型態 | `FLOAT(42)=42.0` |
| `IntToHex(n,d)` | 整數轉十六進位字串 | `IntToHex(255,4)=00FF` |
| `HexToInt(s)` | 十六進位字串轉整數 | `HexToInt('FF')=255` |
| `HexToStr(s)` | 十六進位編碼轉字串 | `HexToStr('48656C6C6F')=Hello` |
| `StrToHex(s)` | 字串轉十六進位編碼 | `StrToHex('Hello')=48656C6C6F` |
| `HexToColor(s)` | 十六進位轉色彩值 | `HexToColor('FF0000')=16711680（紅色）` |
| `ColorToHex(n)` | 色彩值轉十六進位 | `ColorToHex(16711680)=FF0000` |
| `VarToStr(v)` | Variant 轉字串 | `VarToStr(123)=123` |
| `VarArrayOf(x)` | 建立 Variant 陣列 | `VarArrayOf(1,2,3)=[1,2,3]` |
| `ZeroFill(n, width)` | 整數補前導零至 width 位 | `ZeroFill(7,3)='007'` |
| `NumberFormat(value, decimals)` | 數值格式化，千分位 + 小數位 | `NumberFormat(12345.678,2)='12,345.68'` |
| `CommaFormat(value)` | 數值加千分位（整數） | `CommaFormat(12345)='12,345'` |
| `AsStringValue(value)` | Variant 轉 String，Null/Empty 回傳 '' | `AsStringValue(123)='123'` |
| `AsInt(value)` | Variant 轉整數（Trunc），失敗回傳 0 | `AsInt(3.9)=3` |
| `AsFloat(value)` | Variant 轉 Extended，失敗回傳 0 | `AsFloat('3.14')=3.14` |
| `AsBool(value)` | Variant 轉布林；Null/Empty 為 False，數值型態以是否非 0 判斷，字串接受 '1'/'T'/'Y'/'TRUE'/'YES'（不分大小寫）視為 True，其餘為 False | `AsBool('Y')=True` |
| `AsDate(value)` | Variant 轉 TDateTime（只取日期部分，時間歸零） | `AsDate('2026-08-03 14:30:00')=2026-08-03` |
| `AsTimeValue(value)` | Variant 轉 TDateTime（只取時間部分，日期歸零） | `AsTimeValue('2026-08-03 14:30:00')=14:30:00` |
| `AsDateTime(value)` | Variant 轉 TDateTime（日期＋時間） | `AsDateTime('2026-08-03 14:30:00')=2026-08-03 14:30:00` |
| `AsFixed(value, decimals)` | 固定小數位字串（不加千分位） | `AsFixed(3.14159,2)='3.14'` |
| `AsCurr(value, decimals)` | 千分位貨幣字串；decimals 預設 2 | `AsCurr(12345.6,2)='12,345.60'` |
| `AsPercent(value, decimals)` | 百分比字串，如 '12.34%' | `AsPercent(0.1234,2)='12.34%'` |
| `AsScientific(value, decimals)` | 科學記號，如 '1.23E+04' | `AsScientific(12345,2)='1.23E+04'` |
| `AsYesNo(value)` | 布林 → 'Y' / 'N' | `AsYesNo(True)='Y'` |
| `AsTrueFalse(value)` | 布林 → 'T' / 'F' | `AsTrueFalse(True)='T'` |
| `AsZeroOne(value)` | 布林 → '1' / '0' | `AsZeroOne(True)='1'` |
| `AsBit(value)` | 整數 → 1-bit 布林字串（非零→'1'，零→'0'） | `AsBit(5)='1'` |
| `AsHex(value, width)` | 整數 → 十六進位字串（補零至 width 位） | `AsHex(255,4)='00FF'` |
| `AsOctal(value)` | 整數 → 八進位字串 | `AsOctal(8)='10'` |
| `AsISO8601(datetime)` | TDateTime → ISO 8601 字串 'YYYY-MM-DDTHH:MM:SS' | `AsISO8601('2026-08-03 14:30:00')='2026-08-03T14:30:00'` |
| `AsRocDate(datetime)` | TDateTime → 民國年日期 'YYY/MM/DD' | `AsRocDate('2026-08-03')='115/08/03'` |
| `AsRocDateTime(datetime)` | TDateTime → 民國年日期時間 'YYY/MM/DD HH:MM:SS' | `AsRocDateTime('2026-08-03 14:30:00')='115/08/03 14:30:00'` |
| `AsSlug(str)` | 字串 → URL slug（小寫、空白→'-'、移除特殊字元） | `AsSlug('Hello World!')='hello-world'` |
| `AsUpper(str)` | 字串 → 全大寫 | `AsUpper('abc')='ABC'` |
| `AsLower(str)` | 字串 → 全小寫 | `AsLower('ABC')='abc'` |
| `AsTrimmed(str)` | 字串 → 去除兩端空白 | `AsTrimmed('  Hi  ')='Hi'` |
| `AsQuoted(str)` | 字串 → 單引號包住（先跳脫內部單引號） | `AsQuoted("O'Brien")="'O''Brien'"` |
| `AsDQuoted(str)` | 字串 → 雙引號包住（內部雙引號以反斜線跳脫） | `AsDQuoted('Say "Hi"')='"Say \"Hi\""'` |
| `AsSqlStr(str)` | SQL 安全字串（跳脫單引號，不加外框引號） | `AsSqlStr("O'Brien")="O''Brien"` |
| `AsNullable(value)` | Null/Empty/去除空白後為空 時回傳字串 'NULL'，否則回傳以單引號包住並跳脫內部單引號的 SQL 字面值字串 | `AsNullable(NULL)='NULL'` |
| `AsDefault(value, default)` | Value 為 Null/Empty/空白 時回傳 default | `AsDefault(NULL,'N/A')='N/A'` |
| `AsJson(value)` | 依 Variant 型別轉為 JSON 值——布林轉 true/false，數值原樣輸出，日期轉 ISO 格式字串，Null/Empty 轉 null，其餘轉為跳脫過反斜線、雙引號、CR/LF 的 JSON 字串 | `AsJson('Hi')='"Hi"'` |
| `AsCsv(value1, value2, …)` | 將多個值以逗號串接為一列 CSV；欄位內含逗號、雙引號或換行時自動加雙引號並跳脫內部雙引號 | `AsCsv(['A','B,C','D'])='A,"B,C",D'` |
| `NumVal(n)` | 將字串轉換為數值 | `NumVal('3.14')=3.14` |
| `NumValC(s, symbol)` | 含貨幣符號與千分位逗號的字串轉數值；第二引數可指定貨幣符號 | `NumValC('$1,234.56','$')=1234.56` |
| `NumValF(n)` | 將含科學記號的浮點數字串（如 '1.5E2'）轉為數值 | `NumValF('1.5E2')=150` |
| `TestNumVal(n)` | 測試字串是否可安全轉為數值，回傳 0 表示可以 | `TestNumVal('3.14')=0` |
| `TestNumValC(n)` | 測試含貨幣符號的字串是否可安全轉為數值，回傳 0 表示可以 | `TestNumValC('$1,234.56','$')=0` |
| `TestNumValF(n)` | 測試浮點數字串是否可安全轉換，回傳 0 表示可以 | `TestNumValF('1.5E2')=0` |

---

### B.5　日期與時間

| 函式 | 說明 | 範例 |
|---|---|---|
| `NOW` | 目前日期時間（格式不同） | `NOW=2026-08-03 14:30:00` |
| `TODAY` | 今日日期 | `TODAY=2026-08-03` |
| `TIME` | 目前時間（從 CURRENT_DATE 取時間部分） | `TIME=14:30:00` |
| `TDATE` | 系統日期別名 | `TDATE=2026-08-03` |
| `yesterday` | 昨天日期 | `yesterday=2026-08-02` |
| `last-night()` | 昨晚時間點 | `last-night()=2026-08-02 20:00:00` |
| `last-month()` | 上個月第一天 | `last-month()=2026-07-01` |
| `last-year()` | 去年第一天 | `last-year()=2025-01-01` |
| `YEAR(d)` | 取年份 | `YEAR('2026-08-03')=2026` |
| `MONTH(d)` | 取月份 | `MONTH('2026-08-03')=8` |
| `DAY(d)` | 取日 | `DAY('2026-08-03')=3` |
| `HOUR(d)` | 取時 | `HOUR('14:30:00')=14` |
| `MINUTE(d)` | 取分 | `MINUTE('14:30:00')=30` |
| `SECOND(d)` | 取秒 | `SECOND('14:30:00')=0` |
| `WEEK(d)` | 取週次 | `WEEK('2026-08-03')=32` |
| `DAYOFWEEK(d)` | 取星期幾（底層用 DateUtils.DayOfTheWeek，1=Monday...7=Sunday） | `DAYOFWEEK('2026-08-03')=1（Monday）` |
| `DAYOFYEAR(d)` | 取年中第幾天 | `DAYOFYEAR('2026-08-03')=215` |
| `DaysInAMonth(y,m)` | 取得某年某月的天數 | `DaysInAMonth(2024, 2)=29` |
| `IsLeapYear(y)` | 是否閏年 | `IsLeapYear(2024)=True` |
| `StrToDate(s)` | 字串轉日期 | `StrToDate('2026-08-03')=2026-08-03` |
| `StrToDateTime(s)` | 字串轉日期時間 | `StrToDateTime('2026-08-03 14:30:00')=2026-08-03 14:30:00` |
| `StrToTime(s)` | 字串轉時間 | `StrToTime('14:30:00')=14:30:00` |
| `DateToStr(d)` | 日期轉字串（依系統地區設定格式） | `DateToStr('2026-08-03')=2026/8/3` |
| `DateTimeToStr(d)` | 日期時間轉字串（依系統地區設定格式） | `DateTimeToStr('2026-08-03 14:30:00')=2026/8/3 下午 02:30:00` |
| `TimeToStr(t)` | 時間轉字串 | `TimeToStr('14:30:00')=下午 02:30:00` |
| `MyDate(d)` | 自訂日期格式化（民國年格式） | `MyDate('2026-08-03')=115/08/03` |
| `MyDateTime(d)` | 自訂日期時間格式化（民國年格式） | `MyDateTime('2026-08-03 14:30:00')=115/08/03 14:30:00` |
| `DateAddValue(date, n, unit)` | 日期加減；unit='D'/'M'/'Y'/'W' | `DateAddValue('2026-08-03',1,'M')=2026-09-03` |
| `DateDiffValue(date1, date2, unit)` | 日期差；unit='D'/'M'/'Y' | `DateDiffValue('2026-01-01','2026-08-03','D')=214` |
| `DatePeriodStart(date, unit)` | 取期間起點；unit='M'=月初/'Y'=年初/'W'=週一 | `DatePeriodStart('2026-08-03','M')=2026-08-01` |
| `DatePeriodEnd(date, unit)` | 取期間終點；unit='M'=月末/'Y'=年末 | `DatePeriodEnd('2026-08-03','M')=2026-08-31` |
| `WorkDaysBetween(date1, date2)` | 計算工作日天數（不含六日） | `WorkDaysBetween('2026-08-01','2026-08-07')=5` |
| `QuarterOf(date)` | 取季別（1~4） | `QuarterOf('2026-08-03')=3` |
| `RocDateOf(date)` | 民國年日期字串 YYYYY/MM/DD | `RocDateOf('2026-08-03')='115/08/03'` |
| `RocDateTimeOf(date)` | 民國年日期時間字串 YYY/MM/DD HH:MM:SS | `RocDateTimeOf('2026-08-03 14:30:00')='115/08/03 14:30:00'` |
| `IsWeekEnd(date)` | 是否為週六或週日 | `IsWeekEnd('2026-08-01')=True` |
| `IsWeekDay(date)` | 是否為工作日（週一~週五） | `IsWeekDay('2026-08-03')=True` |
| `NextWeekDay(date, dow)` | 從 date 起找下一個指定星期幾（dow=1 Mon..7 Sun） | `NextWeekDay('2026-08-03',5)=2026-08-07（下一個星期五）` |
| `PrevWeekDay(date, dow)` | 從 date 往前找上一個指定星期幾 | `PrevWeekDay('2026-08-03',5)=2026-07-31（上一個星期五）` |
| `EomDate(year, month)` | 指定年月的最後一天 | `EomDate(2026,2)=2026-02-28` |
| `BomDate(year, month)` | 指定年月的第一天 | `BomDate(2026,8)=2026-08-01` |
| `AddWorkDays(date, n)` | 加 n 個工作日（跳過六日） | `AddWorkDays('2026-08-03',5)=2026-08-10` |
| `YearFraction(date1, date2)` | 兩日期間的年分數（Actual/365） | `YearFraction('2026-01-01','2026-07-01')=0.4959` |
| `CalcAge(birthdate, asofdate)` | 從生日計算周歲年齡 | `CalcAge('2000-08-03','2026-08-03')=26` |
| `FiscalQuarter(date, fiscalStartMonth)` | 財政季別（自訂財政年度起始月） | `FiscalQuarter('2026-08-03',7)=1` |
| `FiscalYear(date, fiscalStartMonth)` | 財政年度 | `FiscalYear('2026-08-03',7)=2026` |
| `DayNameOf(date)` | 星期幾中文名稱 | `DayNameOf('2026-08-03')='星期一'` |
| `MonthNameOf(date)` | 月份中文名稱 | `MonthNameOf('2026-08-03')='八月'` |
| `DateSerialValue(y, m, d)` | 由年月日組合為 TDateTime | `DateSerialValue(2026,8,3)=2026-08-03` |
| `TimeSerialValue(h, m, s)` | 由時分秒組合為 TDateTime | `TimeSerialValue(14,30,0)=14:30:00` |
| `CurrentDateValue` | 目前日期時間；簡化實作：回傳系統可讀日期時間字串（含時區偏移資訊，無參數） | `CurrentDateValue='20260803143000'` |
| `WhenCompiled` | 程式編譯時間；簡化實作：回傳與 CURRENT_DATE 相同來源的時間字串（無參數，本框架為直譯執行，無實際編譯時間戳） | `WhenCompiled='20260803143000'` |
| `DateOfInteger(n)` | COBOL 內部日期整數轉 YYYYMMDD（COBOL 內部整數 = Delphi 日期序號 + 109205，已依測試驗證） | `DateOfInteger(155442)=20260803` |
| `IntegerOfDate(n)` | YYYYMMDD 轉 COBOL 內部日期整數（= Delphi 日期序號 + 109205，已依測試驗證） | `IntegerOfDate(20260803)=155442` |
| `DayOfInteger(n)` | COBOL 內部日期整數轉 YYYYDDD（儒略日格式，已依測試驗證） | `DayOfInteger(155442)=2026215` |
| `IntegerOfDay(n)` | YYYYDDD 轉 COBOL 內部日期整數（已依測試驗證） | `IntegerOfDay(2026215)=155442` |
| `SecondsPastMidnight` | 今日自午夜起算的秒數（無參數） | `SecondsPastMidnight=52200（表示 14:30:00）` |
| `CombinedDateTime(date, secs)` | 將 COBOL 內部日期整數與秒數合併為總秒數（= date × 86400 + secs，已依測試驗證；非小數形式的日期時間值） | `CombinedDateTime(155442,52200)=13430241000` |
| `DateToYyyymmdd(yymmdd [, pivot])` | 六碼日期（YYMMDD）依樞紐年份轉八碼 YYYYMMDD；第二引數為 pivot，未傳或為 0 時預設 50（YY≤50 視為 20YY，否則 19YY） | `DateToYyyymmdd(260803,50)=20260803` |
| `YearToYyyy(yy [, pivot])` | 兩碼年依樞紐年份轉四碼年；第二引數為 pivot，未傳或為 0 時預設 50 | `YearToYyyy(26,50)=2026` |
| `TestDateYyyymmdd(n)` | 驗證 YYYYMMDD 是否為合法日期（可被 EncodeDate 接受），0 = 有效，1 = 無效 | `TestDateYyyymmdd(20260803)=0` |
| `TestDayYyyyddd(n)` | 驗證 YYYYDDD 是否為合法年日（年份 ≥1601 且日序在當年天數範圍內），0 = 有效，1 = 無效 | `TestDayYyyyddd(2026215)=0` |

---

### B.6　條件與邏輯

| 函式 | 說明 | 範例 |
|---|---|---|
| `IF(cnd,t,f)` | 條件運算式：cnd 為真回傳 t，否則回傳 f（即 IIF） | `IF(5>3,'Yes','No')=Yes` |
| `TRUE` | 布林真值常數 | `TRUE=True` |
| `FALSE` | 布林假值常數 | `FALSE=False` |
| `ISNULL(x)` | 是否為 NULL | `ISNULL(NULL())=True` |
| `ISNUMBER(x)` | 是否為數值型態 | `ISNUMBER('123')=True` |
| `ISTEXT(x)` | 是否為字串型態 | `ISTEXT('abc')=True` |
| `ISEVEN(x)` | 是否偶數 | `ISEVEN(4)=True` |
| `ISODD(x)` | 是否奇數 | `ISODD(3)=True` |
| `VarIsNull(x)` | Variant 是否為 Null | `VarIsNull(NULL())=True` |
| `Assigned(x)` | 物件是否已指定 | `Assigned(obj)=True（obj 已建立實例時）` |
| `TYPE(x)` | 回傳型態代碼（varString/varInteger/varDouble/varUString，已依測試驗證修正） | `TYPE(123)='varInteger'` |
| `DEFINE(name)` | 識別字是否已定義 | `DEFINE('v1')=True（v1 已宣告時）` |
| `NvlValue(value, default)` | 若 value 為 Null 則回傳 default（Oracle NVL） | `NvlValue(NULL,'N/A')='N/A'` |
| `Nvl2Value(value, notNullVal, nullVal)` | Oracle NVL2 | `Nvl2Value(5,'有值','無值')='有值'` |
| `CoalesceValue(v1, v2, …)` | 回傳第一個非 Null 的值（可變參數版） | `CoalesceValue([NULL,NULL,3])=3` |
| `ToIntSafe(value)` | 安全轉整數，失敗回傳 0 | `ToIntSafe('abc')=0` |
| `ToFloatSafe(value)` | 安全轉浮點，失敗回傳 0 | `ToFloatSafe('3.14')=3.14` |
| `ToDateSafe(value)` | 安全轉日期，失敗回傳 Null | `ToDateSafe('2026-08-03')=2026-08-03` |
| `TypeNameOf(value)` | 傳回型態名稱字串 | `TypeNameOf(123)='Integer'` |
| `SwitchValue(key, val1, res1, val2, res2, … [, default])` | 依序比對 key 與成對出現的 (值, 結果)，找到相符則回傳對應結果；比對不到且有多出一個尾端引數則回傳該預設值，否則回傳 Null（Oracle DECODE 語意） | `SwitchValue([2,1,'One',2,'Two',3,'Three'])='Two'` |
| `DecodeValue(v1, v2, …)` | Oracle DECODE 語意（等同 SwitchValue） | `DecodeValue([2,1,'One',2,'Two','Other'])='Two'` |

---

### B.7　地區化

| 函式 | 說明 | 範例 |
|---|---|---|
| `LEADBYTE(s,p)` | 判斷是否為雙位元組首位元組 | `LEADBYTE('中文',1)=True` |
| `LocaleDate(n)` | 簡化實作：COBOL 內部日期整數轉系統地區格式日期字串（未支援指定 locale 參數） | `LocaleDate(155442)='2026/8/3'（示意值，實際格式依系統地區設定而定）` |
| `LocaleTime(secs)` | 簡化實作：秒數轉系統地區格式時間字串（未支援指定 locale 參數） | `LocaleTime(52200)='下午 02:30:00'` |
| `LocaleCompare(s1, s2)` | 依地區規則比較字串，回傳 '<'、'=' 或 '>'（實作上與 STANDARD_COMPARE 同為序數比較，未套用地區排序規則） | `LocaleCompare('abc','abd')='<'` |
| `CurrencySymbol` | 目前地區的貨幣符號（無參數） | `CurrencySymbol='NT$'` |
| `MonetaryDecimalPoint` | 貨幣小數點符號（無參數） | `MonetaryDecimalPoint='.'` |
| `MonetaryThousandsSeparator` | 貨幣千分位符號（無參數） | `MonetaryThousandsSeparator=','` |
| `NumericDecimalPoint` | 數值小數點符號（無參數） | `NumericDecimalPoint='.'` |
| `NumericThousandsSeparator` | 數值千分位符號（無參數） | `NumericThousandsSeparator=','` |

---

### B.8　隨機數

| 函式 | 說明 | 範例 |
|---|---|---|
| `RAND(a,b)` | 回傳 a~b 之間的隨機整數 | `RAND(1,10)=7（每次執行結果隨機）` |

---

### B.9　加解密與安全

| 函式 | 說明 | 範例 |
|---|---|---|
| `ENCRYPT(s,pwd)` | 字串加密（XOR，回傳十六進位字串；同一組 s/pwd 結果固定、可重現，不是隨機加鹽） | `ENCRYPT('AB','key')='2A27'` |
| `DECRYPT(s,pwd)` | 字串解密（還原 ENCRYPT 的結果） | `DECRYPT('2A27','key')='AB'` |
| `MD5(s)` | 計算字串的 MD5 雜湊值 | `MD5('Wapform')='A2269E58A973F7C621427BCC8BD3BBBA'` |
| `HashOf(str)` | 簡易 djb2 雜湊（32-bit 無號整數，回傳十六進位字串，已依測試驗證） | `HashOf('Wapform')='17333661'` |
| `CheckSumOf(str)` | 簡易 XOR 校驗和（回傳 0~255 整數） | `CheckSumOf('AB')=3` |

---

### B.10　系統與環境

| 函式 | 說明 | 範例 |
|---|---|---|
| `GetUrlContent(url)` | 取得 URL 內容 | `GetUrlContent('https://example.com')=<html>...</html>` |
| `GetMacPhysicalAddress` | 取得 MAC 實體位址 | `GetMacPhysicalAddress=00-1A-2B-3C-4D-5E` |
| `GetPhysMem` | 取得實體記憶體大小 | `GetPhysMem=16384（MB，依實際主機而定）` |
| `GetFreeRes` | 取得可用資源 | `GetFreeRes=8192（依實際主機而定）` |
| `DBX` | 多層架構旗標 | `DBX=True（多層架構模式下）` |
| `Beep` | 系統嗶聲 | `Beep=（發出系統嗶聲，無回傳值）` |
| `loCaseInsensitive` | 查找選項：不分大小寫 | `loCaseInsensitive=1（查找選項旗標值）` |
| `loPartialKey` | 查找選項：部分鍵值 | `loPartialKey=2（查找選項旗標值）` |
| `NBSP` | 不斷行空格 | `NBSP=&nbsp;` |
| `NULL` | 空值常數 | `NULL=Null` |
| `IMG(name,size)` | 圖片路徑處理 | `IMG('logo.png',32)=<img src="logo.png" width="32">` |
| `NewGuidStr` | 產生新的 GUID 字串 xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx | `NewGuidStr='550e8400-e29b-41d4-a716-446655440000'` |
| `RandomStrOf(len, chars)` | 從 chars 字元集中隨機取 len 個字元組成字串；chars 為空白時預設使用大小寫英文字母＋數字 | `RandomStrOf(6,'')='aZ3kQ9'（每次執行結果隨機）` |
| `ToHexStr(n)` | 整數轉十六進位字串（無補位） | `ToHexStr(255)='FF'` |
| `FromHex(str)` | 十六進位字串轉整數 | `FromHex('FF')=255` |
| `ToBinary(n, width)` | 整數轉二進位字串 | `ToBinary(5,8)='00000101'` |
| `FromBinary(str)` | 二進位字串轉整數 | `FromBinary('101')=5` |
| `BitOrValue(a, b)` | 位元 OR | `BitOrValue(5,3)=7` |
| `BitAndValue(a, b)` | 位元 AND | `BitAndValue(5,3)=1` |
| `BitXorValue(a, b)` | 位元 XOR | `BitXorValue(5,3)=6` |
| `BitNotValue(a)` | 位元 NOT（32-bit） | `BitNotValue(0)=-1` |
| `BitShiftLeft(a, n)` | 左移 n 位 | `BitShiftLeft(1,4)=16` |
| `BitShiftRight(a, n)` | 右移 n 位 | `BitShiftRight(16,4)=1` |
| `ByteSizeOf(n)` | 傳回儲存 n 個 bit 需要幾個 byte | `ByteSizeOf(10)=2` |
| `BooleanOfInteger(n, len)` | 整數轉 BOOLEAN 位元字串，引數為 (整數值, 位元寬度)，依高位到低位輸出 '0'/'1' | `BooleanOfInteger(5,8)='00000101'` |
| `IntegerOfBoolean(s)` | BOOLEAN 位元字串（'0'/'1' 組成）轉整數 | `IntegerOfBoolean('101')=5` |
| `StandardCompare(s1, s2)` | 標準字串比較（區分大小寫，序數比較），回傳 '<'、'=' 或 '>' | `StandardCompare('abc','abd')='<'` |

---

### B.11　路徑處理

| 函式 | 說明 | 範例 |
|---|---|---|
| `ExtractFileDir(s)` | 取得目錄路徑 | `ExtractFileDir('C:\App\data.txt')=C:\App` |
| `ExtractFileDrive(s)` | 取得磁碟代號 | `ExtractFileDrive('C:\App\data.txt')=C:` |
| `ExtractFileExt(s)` | 取得副檔名 | `ExtractFileExt('data.txt')=.txt` |
| `ExtractFileName(s)` | 取得檔案名稱（含副檔名） | `ExtractFileName('C:\App\data.txt')=data.txt` |
| `ExtractFileNameNoExt(s)` | 取得檔案名稱（不含副檔名） | `ExtractFileNameNoExt('C:\App\data.txt')=data` |
| `ExtractFilePath(s)` | 取得完整路徑 | `ExtractFilePath('C:\App\data.txt')=C:\App\` |

---

### B.12　動態變數與陣列

| 函式 | 說明 | 範例 |
|---|---|---|
| `var(name,val)` | 動態設定變數 | `var('x',10)=10（設定變數 x=10）` |
| `inc(name,val)` | 變數遞增 | `inc('x',1)=11（x 遞增 1 後的值）` |
| `dec(name,val)` | 變數遞減 | `dec('x',1)=10（x 遞減 1 後的值）` |
| `ARRAY(s)` | 以空白分割字串，組成類似陣列字面值的顯示字串（已依實際原始碼行為與測試驗證修正說明） | `ARRAY('a b c')='[''a'',''b'',''c'']'` |
| `HIGH(x)` | 陣列上界 | `HIGH(arr)=9（若陣列大小為 10，上界索引為 9）` |
| `LOW(x)` | 陣列下界 | `LOW(arr)=0（陣列下界索引，通常為 0）` |
| `ArrayJoin(values, delim)` | 將多個值以 delim 串接成字串；最後一個參數為 delim | `ArrayJoin([1,2,3,','])='1,2,3'` |
| `ArrayMax(values)` | 多個數值中最大值（可變參數） | `ArrayMax([3,7,2])=7` |
| `ArrayMin(values)` | 多個數值中最小值（可變參數） | `ArrayMin([3,7,2])=2` |
| `ArraySum(values)` | 多個數值總和（可變參數） | `ArraySum([1,2,3])=6` |
| `ArrayAverage(values)` | 多個數值平均（可變參數） | `ArrayAverage([1,2,3])=2` |
| `ArrayContains(values, target)` | 檢查 target 是否在 values 中；最後一個參數為 target | `ArrayContains([1,2,3,2])=True` |
| `ArrayUnique(values)` | 移除重複值，保留第一次出現；以逗號串接回傳 | `ArrayUnique([1,2,2,3])='1,2,3'` |
| `ChooseValue(index, values)` | 依索引（1-based）從清單選值；index 為第一個參數 | `ChooseValue([2,'A','B','C'])='B'` |

---

---

---

### B.13　財務函數

| 函式 | 說明 | 範例 |
|---|---|---|
| `PaymentValue(rate, nper, pv)` | 每期等額還款金額（貸款） | `PaymentValue(0.005,360,-300000)=1798.65157545826` |
| `PresentValueOf(rate, nper, pmt)` | 現值（已知等額年金反推現值） | `PresentValueOf(0.005,360,-1798.65157545826)=300000` |
| `FutureValue(rate, nper, pmt, pv)` | 未來值 | `FutureValue(0.005,12,-100,0)=1233.55623728999` |
| `NumOfPeriods(rate, pmt, pv)` | 還清貸款所需期數 | `NumOfPeriods(0.005,-1798.65,300000)=360` |
| `RateOf(nper, pmt, pv)` | 每期利率（Newton-Raphson，最多 100 次） | `RateOf(360,-1798.65,300000)=0.005` |
| `InterestPmt(rate, per, nper, pv)` | 第 per 期的利息部分 | `InterestPmt(0.005,1,360,-300000)=1500` |
| `PrincipalPmt(rate, per, nper, pv)` | 第 per 期的本金部分 | `PrincipalPmt(0.005,1,360,-300000)=298.651575458257` |
| `CumInterestPmt(rate, nper, pv, startPeriod [, endPeriod])` | 計算 startPeriod 至 endPeriod 期間的累計利息；未傳第 5 參數（endPeriod）時預設計算到 nper | `CumInterestPmt([0.005,360,-300000,1,12])=17899.78376866893` |

---

### B.14　其他內建函式（本次新增測試涵蓋）

> 本節收錄的函式先前未列入第六章／原附錄的完整範例中，經逐一檢視原始碼、
補上測試後新增於此。部分函式在檢視過程中發現原始碼實作有誤，已一併修正
（詳見各列「說明」欄的 ⚠️ 標註），修正內容也已同步於 `myexp.pas`。

| 函式 | 說明 | 範例 |
|---|---|---|
| `CHAR(n)` | 整數轉字元 | `CHAR(65)='A'` |
| `COLOR2HEX(color)` | 色彩值轉十六進位色碼字串（同 ColorToHex，Delphi TColor 內部存成 BGR） | `COLOR2HEX(255)='FF0000'` |
| `DAYOFMONTH(d)` | 取日期的「日」（同 DAY） | `DAYOFMONTH('2026-08-03')=3` |
| `DEL(s,index,count)` | 刪除字串中指定位置與長度的子字串 | `DEL('Hello',2,3)='Ho'` |
| `DELB(s,index,count)` | 同 DEL（Byte 版） | `DELB('Hello',2,3)='Ho'` |
| `FIND(substr,s)` | 尋找子字串位置（1-based），找不到回傳 0 | `FIND('ll','Hello')=3` |
| `FINDB(substr,s)` | 同 FIND（Byte 版） | `FINDB('ll','Hello')=3` |
| `FLOAT2STR(v)` | 浮點數轉字串 | `FLOAT2STR(3.14)='3.14'` |
| `HEX2COLOR(hex)` | 十六進位色碼字串轉色彩值（同 HexToColor，Delphi TColor 內部存成 BGR） | `HEX2COLOR('0000FF')=16711680` |
| `HEX2INT(hex)` | 十六進位字串轉整數。⚠️ 原始碼迴圈原本從索引 0（非有效字元）開始，已修正為從 1 開始 | `HEX2INT('FF')=255` |
| `HEX2STR(hex)` | 十六進位字串轉一般字串 | `HEX2STR('48656C6C6F')='Hello'` |
| `IIF(cond,t,f)` | 條件式（同 IF） | `IIF(1=1,'Yes','No')='Yes'` |
| `INS(substr,s,index)` | 在字串指定位置插入子字串 | `INS('XY','Hello',2)='HXYello'` |
| `INSB(substr,s,index)` | 同 INS（Byte 版） | `INSB('XY','Hello',2)='HXYello'` |
| `INT2HEX(n,digits)` | 整數轉十六進位字串 | `INT2HEX(255,4)='00FF'` |
| `INT2STR(n)` | 整數轉字串 | `INT2STR(123)='123'` |
| `LENB(s)` | 字串長度（Byte 版） | `LENB('Hello')=5` |
| `LENGTH(s)` | 字串長度 | `LENGTH('Hello')=5` |
| `MIDB(s,index,count)` | 取子字串（Byte 版，Byte 計，1-based） | `MIDB('Hello',2,3)='ell'` |
| `NTIER` | 同 DBX（是否為多層式連線模式） | `NTIER=False` |
| `Odd(n)` | 是否為奇數 | `Odd(3)=True` |
| `Ord(x)` | 字元或整數的序數值 | `Ord(65)=65` |
| `REPLACEB(s,old,new)` | 取代所有出現的子字串（Byte 版） | `REPLACEB('hello','l','L')='heLLo'` |
| `ROUNDTO(x,digits)` | 四捨五入至小數點後 digits 位 | `ROUNDTO(3.14159,2)=3.14` |
| `SQR(x)` | 平方 | `SQR(7)=49` |
| `STR2DATE(s)` | 字串轉日期 | `STR2DATE('2026-08-03')=46237` |
| `STR2DATETIME(s)` | 字串轉日期時間 | `STR2DATETIME('2026-08-03 14:30:00')=46237.6041666667` |
| `STR2FLOAT(s)` | 字串轉浮點數 | `STR2FLOAT('3.14')=3.14` |
| `STR2HEX(s)` | 一般字串轉十六進位字串 | `STR2HEX('Hello')='48656C6C6F'` |
| `STR2INT(s)` | 字串轉整數 | `STR2INT('123')=123` |
| `STR2TIME(s)` | 字串轉時間 | `STR2TIME('14:30:00')=0.604166666666667` |
| `UPPERA(s)` | 轉大寫（Ansi 版） | `UPPERA('abc')='ABC'` |
| `VALUE(s)` | 同 VAL | `VALUE('3.14')=3.14` |
| `VARTYPE(v)` | 回傳型別名稱字串（同 TYPE） | `VARTYPE(123)='varInteger'` |

---

### B.15　其他內建函式（不適合自動化測試）

> 以下函式存在於 `myexp.pas` 並可正常呼叫，但基於各自列出的原因
（隨機、依系統/網路狀態、依執行當下時間、地區化格式不固定、語意不明等），
不適合寫成固定預期值的自動化測試，故未收錄於 `function.wml`。

| 函式 | 說明 | 未測試原因 |
|---|---|---|
| `CPU` | （未在原始碼中找到對應註冊/未使用） | 此函式本身不產生有意義的回傳值（系統音效／內部工具函式），不適合做相等比對測試 |
| `DATE` | 目前日期（無參數，會隨執行日變動） | 結果依執行當下的系統日期/時間而定，非固定值，無法寫定預期值 |
| `DATE2STR(d)` | 日期轉字串 | 輸出格式依系統地區設定（Locale）而定，不同環境下字串格式不保證一致，故不納入精確比對測試 |
| `DATETIME2STR(d)` | 日期時間轉字串 | 輸出格式依系統地區設定（Locale）而定，不同環境下字串格式不保證一致，故不納入精確比對測試 |
| `RANDOM(lo,hi)` | [lo,hi) 隨機整數 | 隨機函式，無固定預期值可比對 |
| `RANDOMRANGE(lo,hi)` | [lo,hi) 隨機整數 | 隨機函式，無固定預期值可比對 |
| `RANDRANGE(lo,hi)` | [lo,hi) 隨機整數 | 隨機函式，無固定預期值可比對 |
| `TIME2STR(t)` | 時間轉字串 | 輸出格式依系統地區設定（Locale）而定，不同環境下字串格式不保證一致，故不納入精確比對測試 |
| `getpropstr(a,b)` | （unigui 相關內部函式，非公開語意） | unigui 平台相關內部函式，語意不對外公開，暫不納入測試 |
| `setpropstr(a,b,c)` | （unigui 相關內部函式，非公開語意） | unigui 平台相關內部函式，語意不對外公開，暫不納入測試 |

---

## 附錄 C　Flutter 運算式引擎差異

WapForm for Flutter 的運算式由 `wapform_expression.dart`（`WapEvaluator`）計算。函數名稱與附錄 B 相同，但有以下差異；本附錄的結果都由 Dart 引擎實際執行得出。

### C.1　語法與型別

| 項目 | Windows／Web | Flutter |
|---|---|---|
| `AND`／`OR` 兩側的比較 | 可不加括號 | **要加括號**：`(qty>0) AND (price<100)`；不加括號回報 `Invalid end token` |
| 數值運算 | Variant | 整數與整數做 `+`、`-`、`*` 得整數，其餘（含 `/`）得浮點數 |
| 陣列索引 | 依宣告 | 一律從 0 起；`[1..n]` 會建立 n+1 個元素，`LOW()` 為 0 |
| 陣列寫入超出上界 | 錯誤 | 自動延長（補 `null`） |
| 字串中的 `$` | — | Dart 程式中請寫 raw string `r"..."`，否則 `$` 先被 Dart 插值 |
| `$(PAGE)` | 報表引擎自動設定 | 需自行在 `PAGEPREFIX` 設定（第 7.6 節） |
| `request.*`／`session.*` | Web 環境物件 | 不存在；需要時以 `_ev.setVar("request.xxx", 值)` 自行放入 |

### C.2　傳回日期序號的函數

下列函數在 Flutter 傳回「自 1899-12-30 起的天數」（小數部分是時間），可用來比較大小或相減，但目前無法再用 `DateToStr()`、`FORMATDATETIME()` 轉回文字。需要日期文字時，改用 `DATEADD`、`DATESTART`、`DATEEND`、`DATESERIAL`、`TODAY` 等傳回日期的函數。

| 函式 | 範例 | Flutter 結果 |
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

### C.3　結果與 Windows 版不同的函數

下列函數可以呼叫，但結果與附錄 B 的 Windows 版不一致，使用前請先測試：

| 函式 | 附錄 B 範例（Windows） | Flutter 結果 |
|---|---|---|
| `LENA(s)` | `LENA('中文')=6（UTF-8 每字 3 byte）` | `2` |
| `AnsiLength(s)` | `AnsiLength('中文')=4（Big5 每字 2 byte）` | `2` |
| `REPLACEAT(s,p,new)` | `REPLACEAT('Hello',1,'J')=Jello` | `Hello` |
| `INSERT(s,p,n,new)` | `INSERT('Hllo',2,0,'e')=Hello` | `ERROR` |
| `INSA(s,p,new)` | `INSA('Hllo',2,'e')=Hello` | `Hllo2` |
| `AnsiInsert(s,p,new)` | `AnsiInsert('Hllo',2,'e')=Hello` | `Hllo2` |
| `CODE(s)` | `CODE('001-ABC')=001（依資料格式而定）` | `（空字串）` |
| `NAME(s)` | `NAME('001-ABC')=ABC（依資料格式而定）` | `（空字串）` |
| `FORMAT(fmt,x)` | `FORMAT('0.00',3.5)=3.50` | `0.00` |
| `LIKE(s,pat)` | `LIKE('Hello','H*o')=True` | `H` |
| `ANSI(s)` | `ANSI('中文')=中文（轉為 Big5 編碼位元組）` | `中文` |
| `UTF8(s)` | `UTF8('中文')=中文（轉為 UTF-8 編碼位元組）` | `中文` |
| `HTML(s)` | `HTML('<b>')=&lt;b&gt;` | `<b><br/>` |
| `EllipsisStr(str, maxLen)` | `EllipsisStr('HelloWorld',5)='Hello...'` | `He...` |
| `HexToColor(s)` | `HexToColor('FF0000')=16711680（紅色）` | `255` |
| `ColorToHex(n)` | `ColorToHex(16711680)=FF0000` | `0000FF` |
| `HOUR(d)` | `HOUR('14:30:00')=14` | `0` |
| `MINUTE(d)` | `MINUTE('14:30:00')=30` | `0` |
| `TimeToStr(t)` | `TimeToStr('14:30:00')=下午 02:30:00` | `（空字串）` |
| `MyDate(d)` | `MyDate('2026-08-03')=115/08/03` | `2026-08-03` |
| `MyDateTime(d)` | `MyDateTime('2026-08-03 14:30:00')=115/08/03 14:30:00` | `2026-08-03 14:30:00` |
| `ISNULL(x)` | `ISNULL(NULL())=True` | `ERROR` |
| `VarIsNull(x)` | `VarIsNull(NULL())=True` | `ERROR` |
| `LEADBYTE(s,p)` | `LEADBYTE('中文',1)=True` | `false` |
| `IMG(name,size)` | `IMG('logo.png',32)=<img src="logo.png" width="32">` | `ERROR` |

### C.4　Flutter 不支援的函數

下列函數在 Flutter 只傳回提示字串：

- `GetUrlContent(url)`
- `GetMacPhysicalAddress`
- `GetPhysMem`
- `GetFreeRes`

取得網頁內容請改用 Dart 的 `http` 套件；本機硬體資訊請改用對應平台的 Flutter 套件。

### C.5　Flutter 額外提供的函數

以下函數只在 Dart 引擎註冊，可在 `eval()`、`setvar()`、`$(...)` 中呼叫。「參數」欄是參數個數。

| 函式 | 參數 | 說明 |
|---|---|---|
| `AGE` | 2 | 由生日計算到指定日期的足歲 |
| `ArcCos` | 1 | 反餘弦（同 ACOS） |
| `ArcSin` | 1 | 反正弦（同 ASIN） |
| `ArcTan` | 1 | 反正切（同 ATAN） |
| `ARRAVG` | 可變 | 多個值的平均 |
| `ARRCONTAINS` | 可變 | 最後一個參數是否出現在前面的值中 |
| `ARRJOIN` | 可變 | 以最後一個參數為分隔字元串接前面的值 |
| `ARRMAX` | 可變 | 多個值的最大值 |
| `ARRMIN` | 可變 | 多個值的最小值 |
| `ARRSUM` | 可變 | 多個值的總和 |
| `ARRUNIQ` | 可變 | 去除重複值，以逗號串接傳回 |
| `As10` | 1 | 布林值 → '1'／'0' |
| `AsISO` | 1 | ISO 8601 日期字串 |
| `AsOct` | 1 | 整數 → 八進位字串 |
| `AsPct` | 2 | 百分比字串（d 位小數） |
| `AsRDate` | 1 | 民國年日期字串 |
| `AsRDateTime` | 1 | 民國年日期時間字串 |
| `AsSci` | 2 | 科學記號字串（如 1.23E+04） |
| `AsString` | 1 | 任意值 → 字串 |
| `AsTF` | 1 | 布林值 → 'T'／'F' |
| `AsTime` | 1 | 任意值 → 時間 |
| `AsYN` | 1 | 布林值 → 'Y'／'N' |
| `BDATE` | 1 | 日期轉換（相容用） |
| `BETWEEN` | 3 | 值是否落在 [lo, hi] 範圍內 |
| `BITAND` | 2 | 位元 AND |
| `BITNOT` | 1 | 位元 NOT |
| `BITOR` | 2 | 位元 OR |
| `BITSHL` | 2 | 左移 n 位元 |
| `BITSHR` | 2 | 右移 n 位元 |
| `BITXOR` | 2 | 位元 XOR |
| `BOOLEAN_OF_INTEGER` | 2 | 整數 → 位元字串 |
| `BR2CRLF` | 1 | <br/> → 換行 |
| `BYTESIZE` | 1 | 存放 n 個位元需要的位元組數 |
| `BYTE_LENGTH` | 1 | 字串的位元組長度 |
| `CBRT` | 1 | 立方根 |
| `CELL` | 2 | 交叉表儲存格值（相容用） |
| `CHECKSUM` | 1 | XOR 檢查碼 |
| `CHOOSE` | 可變 | 依索引（從 1 起）從清單取值 |
| `CLAMP` | 3 | 把值限制在 [lo, hi] 範圍內 |
| `COALESCE` | 可變 | 傳回第一個非 Null 的值（可變參數） |
| `COMBINED_DATETIME` | 2 | 日期整數與秒數合併為日期時間 |
| `COMMAFMT` | 1 | 整數加上千分位 |
| `CONCATENATE` | 可變 | 串接所有參數 |
| `CONTAINS` | 2 | 字串是否包含子字串 |
| `COPY` | 3 | 取子字串（同 Pascal Copy） |
| `COPYB` | 3 | 以位元組取子字串 |
| `COUNTSTR` | 2 | 子字串出現次數 |
| `CRLF2BR` | 1 | 換行 → <br/> |
| `CUMIPMT` | 可變 | 累計利息（期間 start～end） |
| `CURRENCY_SYMBOL` | 0 | 貨幣符號 |
| `CURRENT_DATE` | 0 | 目前時間戳字串 yyyyMMddHHmmsscc+HHmm |
| `DATEADD` | 3 | 日期加減（unit：'D'／'M'／'Y'／'W'） |
| `DATEDIFF` | 3 | 兩日期差距（依 unit） |
| `DATEEND` | 2 | 期間結束日（unit：'M' 月底／'Y' 年底） |
| `DATESERIAL` | 3 | 由年月日建立日期 |
| `DATESTART` | 2 | 期間開始日（unit：'M' 月初／'Y' 年初／'W' 週一） |
| `DATE_OF_INTEGER` | 1 | 日期整數 → YYYYMMDD |
| `DATE_TO_YYYYMMDD` | 2 | YYMMDD 依樞紐年轉為 YYYYMMDD |
| `DAYNAME` | 1 | 星期名稱（中文） |
| `DAY_OF_INTEGER` | 1 | 日期整數 → YYYYDDD |
| `DECODE` | 可變 | 類似 Oracle DECODE：依值對照傳回結果，最後一個為預設值 |
| `DEG2RAD` | 1 | 角度 → 弧度 |
| `E` | 0 | 自然常數 e |
| `ELLIPSIS` | 2 | 截斷並加上 '...' |
| `ENDSWITH` | 2 | 字串是否以指定字尾結尾 |
| `EVEN` | 1 | 大於等於 n 的最小偶數 |
| `EXP10` | 1 | 10 的 x 次方 |
| `FIB` | 1 | 第 n 個費氏數（從 0 起） |
| `FRACTION_PART` | 1 | 小數部分 |
| `FROMBIN` | 1 | 二進位字串 → 整數 |
| `FV` | 4 | 未來值 |
| `GCD` | 2 | 最大公因數 |
| `GEOMEAN` | 可變 | 幾何平均 |
| `GUID` | 0 | 產生新的 GUID 字串 |
| `HARMEAN` | 可變 | 調和平均 |
| `HASH` | 1 | 簡易 djb2 雜湊（32 位元，十六進位字串） |
| `HIGHEST_ALGEBRAIC` | 1 | 該型別的最大值 |
| `HTMLDECODE` | 1 | HTML 特殊字元解碼 |
| `HTMLENCODE` | 1 | HTML 特殊字元編碼 |
| `HYPOT` | 2 | 直角三角形斜邊 sqrt(a²+b²) |
| `INDEXOF` | 3 | 從 start（從 1 起）開始找子字串位置 |
| `INTEGER` | 1 | 無條件捨去（floor） |
| `INTEGER_OF_BOOLEAN` | 1 | 位元字串 → 整數 |
| `INTEGER_OF_DATE` | 1 | YYYYMMDD → 日期整數 |
| `INTEGER_OF_DAY` | 1 | YYYYDDD → 日期整數 |
| `INTEGER_PART` | 1 | 向零截斷取整數 |
| `IPMT` | 4 | 第 n 期付款中的利息 |
| `IRR` | 可變 | 內部報酬率（牛頓法迭代） |
| `ISPRIME` | 1 | 是否為質數 |
| `JOIN` | 2 | 清除多餘空白後以分隔字元串接 |
| `last-month` | 0 | 上個月同一天 |
| `last-night` | 0 | 昨天 |
| `last-week` | 0 | 上週同一天 |
| `last-year` | 0 | 去年同一天 |
| `LASTINDEXOF` | 2 | 從右邊找子字串位置（從 1 起） |
| `LCM` | 2 | 最小公倍數 |
| `LEADBYTEB` | 2 | 是否為雙位元組字元的前導位元組 |
| `LERP` | 3 | 線性內插 a + (b-a)*t |
| `LOCALE_COMPARE` | 2 | 依地區設定比較，傳回 '<'、'='、'>' |
| `LOCALE_DATE` | 1 | 依地區設定格式化日期 |
| `LOCALE_TIME` | 1 | 依地區設定格式化時間 |
| `LOCATE` | 2 | 子字串位置 |
| `LOG10` | 1 | 以 10 為底的對數 |
| `LOG2` | 1 | 以 2 為底的對數 |
| `LOGN` | 2 | 以 base 為底的對數 |
| `LOWERA` | 1 | 轉小寫 |
| `LOWER_CASE` | 1 | 轉小寫 |
| `LOWEST_ALGEBRAIC` | 1 | 該型別的最小值 |
| `LPAD` | 3 | 以指定字元左補到 len 寬度 |
| `MASK` | 3 | 依遮罩格式化（佔位字元預設 '#'） |
| `MEAN` | 可變 | 平均值 |
| `MEDIAN` | 可變 | 中位數 |
| `MIDRANGE` | 可變 | 最大值與最小值的平均 |
| `MOD` | 2 | 取餘數（正負號與除數相同） |
| `MONETARY_DECIMAL_POINT` | 0 | 貨幣小數點符號 |
| `MONETARY_THOUSANDS_SEPARATOR` | 0 | 貨幣千分位符號 |
| `MONTHNAME` | 1 | 月份名稱（中文） |
| `NEXTWDAY` | 2 | 從日期起下一個指定星期幾（1＝週一…7＝週日） |
| `NPER` | 3 | 付款期數 |
| `NPV` | 可變 | 淨現值 |
| `NUMERIC_DECIMAL_POINT` | 0 | 數值小數點符號 |
| `NUMERIC_THOUSANDS_SEPARATOR` | 0 | 數值千分位符號 |
| `NUMFMT` | 2 | 數值格式化：千分位加小數位數 |
| `NUMVAL_C` | 2 | 含貨幣符號的字串 → 數值 |
| `NUMVAL_F` | 1 | 浮點表示字串 → 數值 |
| `NVL` | 2 | 值為 Null 時傳回預設值 |
| `NVL2` | 3 | 類似 Oracle NVL2：非 Null 與 Null 各傳回不同值 |
| `ORD_MAX` | 可變 | 最大值的位置（從 1 起） |
| `ORD_MIN` | 可變 | 最小值的位置（從 1 起） |
| `PADC` | 2 | 以空白置中補到 len 寬度 |
| `PADL` | 2 | 以空白左補到 len 寬度 |
| `PADR` | 2 | 以空白右補到 len 寬度 |
| `PERCENT` | 2 | 百分比計算 |
| `PMT` | 3 | 每期等額付款金額 |
| `PPMT` | 4 | 第 n 期付款中的本金 |
| `PRESENT_VALUE` | 可變 | 各期金額的現值 |
| `PREVWDAY` | 2 | 日期之前上一個指定星期幾 |
| `PRODUCT` | 可變 | 所有值的乘積 |
| `PV` | 3 | 現值 |
| `QUARTER` | 1 | 季別（1～4） |
| `QUARTILE` | 可變 | 四分位數（q＝1、2、3） |
| `RAD2DEG` | 1 | 弧度 → 角度 |
| `RANDOMSTR` | 2 | 產生指定長度的隨機字串 |
| `RANGE` | 可變 | 最大值與最小值的差 |
| `RATE` | 3 | 每期利率（牛頓法近似） |
| `RDATE` | 1 | 民國年日期字串 YYY/MM/DD |
| `RDATETIME` | 1 | 民國年日期時間字串 YYY/MM/DD HH:MM:SS |
| `REM` | 2 | 取餘數（正負號與被除數相同） |
| `REPEAT` | 2 | 字串重複 n 次 |
| `REVERSE` | 1 | 字串反轉 |
| `ROUNDBANK` | 2 | 銀行家捨入（四捨六入五成雙） |
| `RPAD` | 3 | 以指定字元右補到 len 寬度 |
| `SECONDS_PAST_MIDNIGHT` | 0 | 今天已過的秒數 |
| `SIGN` | 1 | 正負號（-1、0、1） |
| `SLUGIFY` | 1 | 轉為網址 slug |
| `SPLIT` | 3 | 以分隔字元切割並取第 n 段（從 1 起） |
| `STANDARD_COMPARE` | 2 | 標準比較，傳回 '<'、'='、'>' |
| `STANDARD_DEVIATION` | 可變 | 標準差 |
| `STARTSWITH` | 2 | 字串是否以指定字首開頭 |
| `STORED_CHAR_LENGTH` | 1 | 去除尾端空白後的長度 |
| `SUBSTITUTE` | 可變 | 依成對參數依序取代字串 |
| `SUBSTITUTE_CASE` | 可變 | 依成對參數取代（不分大小寫） |
| `SUM` | 可變 | 總和 |
| `SUMSQ` | 可變 | 平方和 |
| `SWITCH` | 可變 | 依值對照傳回結果，最後一個為預設值 |
| `TEST_DATE_YYYYMMDD` | 1 | 檢查 YYYYMMDD 是否有效（0＝有效） |
| `TEST_DAY_YYYYDDD` | 1 | 檢查 YYYYDDD 是否有效（0＝有效） |
| `TEST_NUMVAL` | 1 | 檢查字串能否轉為數值（0＝可以） |
| `TEST_NUMVAL_C` | 2 | 檢查含貨幣符號的字串能否轉為數值 |
| `TEST_NUMVAL_F` | 1 | 檢查浮點表示字串能否轉為數值 |
| `TIMESERIAL` | 3 | 由時分秒建立時間 |
| `TOBIN` | 2 | 整數 → 二進位字串（width 位） |
| `TODATE` | 1 | 安全轉為日期 |
| `TOFLOAT` | 1 | 安全轉為浮點數 |
| `TOHEX` | 1 | 整數 → 十六進位字串 |
| `TOINT` | 1 | 安全轉為整數 |
| `TrimLeft` | 1 | 去除左側空白 |
| `TrimRight` | 1 | 去除右側空白 |
| `TYPENAME` | 1 | 值的型別名稱 |
| `UNMASK` | 3 | 去除遮罩，只保留佔位字元位置的字元 |
| `UPPER_CASE` | 1 | 轉大寫 |
| `URLENCODE` | 1 | 網址百分比編碼 |
| `VARIANCE` | 可變 | 變異數 |
| `WHEN_COMPILED` | 0 | 同 CURRENT_DATE |
| `WORKDAYS` | 2 | 兩日期間的工作天數（不含週六、週日） |
| `WRAP` | 2 | 每 width 個字元插入換行 |
| `YEARFRAC` | 2 | 兩日期間佔一年的比例（Actual/365） |
| `YEAR_TO_YYYY` | 2 | 兩位數年份依樞紐年轉為四位數 |
| `ZFILL` | 2 | 整數左補零到 width 位 |

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

WapForm 完整技術手冊  
作者：Neil Tsai  
版權所有 © 2026 敏弘資訊有限公司，保留所有權利。
