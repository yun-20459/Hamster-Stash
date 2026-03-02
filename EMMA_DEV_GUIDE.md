# Hamster's Stash — Emma 的完整開發指南

歡迎加入倉鼠小金庫！這份指南會帶你從零開始，一步步設定好開發環境，然後開始做出可愛的 App 頁面。

> **你不需要會寫程式！** 你的工作是「告訴 Claude 你想要什麼」，Claude 會自動幫你寫程式碼。

---

## 目錄

1. [環境安裝（Windows）](#1-環境安裝windows)
2. [取得專案程式碼](#2-取得專案程式碼)
3. [安裝 Claude Code](#3-安裝-claude-code)
4. [如何使用 Claude Code](#4-如何使用-claude-code)
5. [Git 工作流程（全部交給 Claude）](#5-git-工作流程全部交給-claude)
6. [你的任務清單](#6-你的任務清單)
7. [常見問題 FAQ](#7-常見問題-faq)

---

## 1. 環境安裝（Windows）

### 1.1 安裝 Git

Git 是用來管理程式碼版本的工具（但你不需要自己打 Git 指令，Claude 會幫你）。

1. 前往 https://git-scm.com/download/win
2. 下載並執行安裝程式
3. 安裝過程中，所有選項都用預設值，一直按「Next」即可
4. 安裝完成後，打開「命令提示字元」(CMD) 或「PowerShell」，輸入：
   ```
   git --version
   ```
   看到版本號就代表安裝成功（例如 `git version 2.44.0.windows.1`）

5. 設定你的名字和信箱（這會顯示在你的提交紀錄上）：
   ```
   git config --global user.name "Emma"
   git config --global user.email "你的信箱@example.com"
   ```

### 1.2 安裝 Flutter

Flutter 是我們做 App 的工具。

1. 前往 https://docs.flutter.dev/get-started/install/windows/mobile
2. 點擊「Download Flutter SDK」下載 ZIP 檔
3. 將 ZIP 解壓縮到一個簡單的路徑，例如 `C:\flutter`
   - **注意：路徑不要有中文或空格！** 例如不要放在「桌面」或「我的文件」
4. 設定環境變數（讓你在任何地方都能使用 `flutter` 指令）：
   - 按 `Win + S` 搜尋「環境變數」，點選「編輯系統環境變數」
   - 點「環境變數」按鈕
   - 在「使用者變數」中找到 `Path`，點「編輯」
   - 點「新增」，輸入 `C:\flutter\bin`
   - 一路按「確定」關閉
5. **關閉並重新打開** 命令提示字元，輸入：
   ```
   flutter --version
   ```
   看到 Flutter 版本資訊就代表成功

### 1.3 安裝 Android Studio（用來跑模擬器）

1. 前往 https://developer.android.com/studio 下載並安裝 Android Studio
2. 第一次打開 Android Studio 時，它會引導你安裝 Android SDK，全部選預設即可
3. 安裝完成後，打開 Android Studio：
   - 點上方選單 `Tools` → `Device Manager`
   - 點 `Create Virtual Device`
   - 選一個手機型號（建議選 `Pixel 7`），點 `Next`
   - 選擇系統映像（選最新的，例如 `API 34`），點 `Download` 下載，然後 `Next`
   - 點 `Finish` 建立模擬器
4. 在 Device Manager 中，點模擬器旁邊的 ▶️ 啟動按鈕，確認模擬器可以正常開啟

5. 接受 Android 授權，在命令提示字元輸入：
   ```
   flutter doctor --android-licenses
   ```
   然後一直輸入 `y` 同意即可

### 1.4 安裝 Chrome（用來跑網頁版測試）

如果你電腦已經有 Chrome 就不用裝了。Flutter 可以在 Chrome 上跑，比較快，適合做 UI 測試。

### 1.5 驗證安裝

在命令提示字元輸入：
```
flutter doctor
```

你應該會看到類似這樣的結果：
```
[✓] Flutter (Channel stable, 3.41.x)
[✓] Android toolchain
[✓] Chrome
[✓] Android Studio
```

如果 Android toolchain 或 Android Studio 有 ✗，請按照提示修復。Xcode 的 ✗ 可以忽略（那是 macOS 才需要的）。

---

## 2. 取得專案程式碼

### 2.1 Clone 專案

打開命令提示字元，先切換到你想放專案的資料夾（例如桌面）：
```
cd C:\Users\你的使用者名稱\Desktop
```

然後 clone 專案：
```
git clone https://github.com/yun-20459/Hamster-Stash.git
```

進入專案資料夾：
```
cd Hamster-Stash
```

### 2.2 切換到開發分支

```
git checkout develop
```

### 2.3 安裝專案相依套件

```
flutter pub get
```

### 2.4 確認專案能跑

用 Chrome 測試（最快）：
```
flutter run -d chrome
```

你應該會看到一個有 4 個 Tab（Accounts、Transactions、Budget、Reports）的 App 在 Chrome 中打開。

用 Android 模擬器測試（先在 Android Studio 啟動模擬器）：
```
flutter run
```

看到 App 畫面就代表一切正常！按 `Ctrl + C` 可以停止。

---

## 3. 安裝 Claude Code

Claude Code 是你最重要的工具——你只要告訴它你想做什麼，它就會自動幫你寫程式。

### 3.1 安裝 Node.js

Claude Code 需要 Node.js 才能運行。

1. 前往 https://nodejs.org 下載 **LTS 版本**（左邊那個按鈕）
2. 執行安裝程式，所有選項用預設值
3. 安裝完成後，打開新的命令提示字元，輸入：
   ```
   node --version
   ```
   看到版本號就代表成功

### 3.2 安裝 Claude Code

在命令提示字元輸入：
```
npm install -g @anthropic-ai/claude-code
```

安裝完成後，輸入：
```
claude --version
```
看到版本號就代表成功。

### 3.3 登入 Claude Code

第一次使用需要登入：
```
claude
```
它會引導你登入 Anthropic 帳號。按照畫面上的指示操作即可。

---

## 4. 如何使用 Claude Code

### 4.1 啟動 Claude Code

**每次開始工作前：**

1. 打開命令提示字元
2. 切換到專案資料夾：
   ```
   cd C:\Users\你的使用者名稱\Desktop\Hamster-Stash
   ```
3. 輸入 `claude` 啟動

### 4.2 跟 Claude 說話

進入 Claude Code 後，你可以直接用中文或英文說你想做什麼。就像跟一個很會寫程式的朋友聊天一樣。

**好的描述範例：**
```
請幫我做一個 App 的啟動畫面：
- 背景是淡淡的粉橘色漸層
- 中間有一個大大的倉鼠 emoji 🐹
- 下方顯示 "Hamster's Stash" 文字，要粗體、大字
- 再下方小字「你的可愛記帳保險箱」
- 啟動時倉鼠有一個從小變大的可愛動畫
- 大約 1 秒後自動跳到主頁面
```

**不好的描述範例：**
```
我要一個畫面
```

**訣竅：描述越具體越好！** 包含顏色、大小、位置、動畫效果等。

### 4.3 看結果，給意見

Claude 寫完程式後，你可以：
- 在模擬器或 Chrome 上看結果
- 如果不滿意，直接說哪裡要改：
  - 「按鈕太小了，請放大」
  - 「顏色換成粉紅色」
  - 「文字要置中」
  - 「加一個可愛的陰影效果」

### 4.4 跑模擬器看結果

如果 App 還沒在跑，可以告訴 Claude：
```
請幫我在 Chrome 上跑 App
```

或自己在另一個命令提示字元視窗執行：
```
cd C:\Users\你的使用者名稱\Desktop\Hamster-Stash
flutter run -d chrome
```

### 4.5 完成後儲存

滿意後，告訴 Claude：
```
請幫我 commit 到 feature/emma-splash 分支並 push
```

Claude 會自動：
1. 建立分支（如果還沒有的話）
2. 產生有意義的 commit message
3. 提交並推送程式碼

---

## 5. Git 工作流程（全部交給 Claude）

你不需要自己打任何 Git 指令！以下是你需要知道的概念：

### 5.1 分支命名

你的分支都叫 `feature/emma-任務名稱`，例如：
- `feature/emma-splash` — 啟動畫面
- `feature/emma-tab-nav` — Tab 導航
- `feature/emma-overview` — 總覽頁
- `feature/emma-category-picker` — 分類選擇器

### 5.2 每個任務的流程

1. **開始新任務前**，告訴 Claude：
   ```
   請從 develop 分支建立一個新的 feature/emma-splash 分支
   ```

2. **工作中**，每完成一個小步驟就告訴 Claude：
   ```
   請幫我 commit 這些變更
   ```

3. **任務完成後**，告訴 Claude：
   ```
   請幫我 push 到遠端
   ```

4. **通知 Erin** 你完成了，她會幫你 review 並 merge 到 develop 分支。

### 5.3 開始下一個任務前

告訴 Claude：
```
請切換回 develop 分支，pull 最新的程式碼，然後建立 feature/emma-下一個任務 分支
```

---

## 6. 你的任務清單

### 🎨 Phase 1：你的第一步（Day 2–4）

目標：熟悉 Claude Code，做出第一批可見的 UI。

| # | 任務 | 說明 | 難度 |
|---|------|------|------|
| 1-1 | App 啟動畫面 | 可愛的 Splash Screen，有倉鼠 emoji 和動畫 | ⭐ |
| 1-2 | 主頁 Tab 導航 | 底部 4 個 Tab：總覽、記帳、報表、設定 | ⭐ |
| 1-3 | 總覽頁（靜態版）| 顯示總資產、短期/長期資產卡片，用假數字 | ⭐⭐ |
| 1-4 | 帳戶列表卡片 | 在總覽頁加上帳戶列表，用假資料 | ⭐⭐ |
| 1-5 | 記帳頁按鈕 | 大圓形「+」按鈕，點擊彈出 Bottom Sheet | ⭐ |
| 1-6 | 設定頁 | 顯示設定項目列表（先不用有功能）| ⭐ |

---

#### Task 1-1：App 啟動畫面 (Splash Screen)

**分支名稱：** `feature/emma-splash`

**你要告訴 Claude 的：**
```
請幫我做一個 App 的啟動畫面 (Splash Screen)：
- 背景是淡淡的粉橘色漸層
- 中間有一個大大的倉鼠 emoji 🐹
- 下方顯示 "Hamster's Stash" 文字，要粗體、大字
- 再下方小字「你的可愛記帳保險箱」
- 啟動時倉鼠有一個從小變大的可愛動畫
- 大約 1 秒後自動跳到主頁面

請使用專案的 AppTheme 和 AppColors（在 lib/core/theme/ 裡）。
主要顏色是 primary #D4740A（粉橘色），背景色是 #FFF8F0。
```

**完成標準：** 打開 App 看到可愛的啟動畫面，1 秒後自動跳到主頁。

---

#### Task 1-2：主頁 Tab 導航

**分支名稱：** `feature/emma-tab-nav`

**說明：** 我們已經有 4 個 Tab 的基本架構了（在 `lib/app.dart`），你的任務是讓它更好看。

**你要告訴 Claude 的：**
```
請修改目前的底部導航列（在 lib/app.dart），讓它更好看：
- 4 個 Tab：總覽（icon 用小房子）、記帳（icon 用筆）、報表（icon 用圓餅圖）、設定（icon 用齒輪）
- 選中的 Tab 要有明顯的顏色變化，使用 primary 色 #D4740A
- 每個 Tab 的頁面中間顯示「這是 XXX 頁面」和對應的大 icon
- 風格要簡潔可愛

請使用專案的 AppTheme 和 AppColors。
```

---

#### Task 1-3：總覽頁（靜態版）

**分支名稱：** `feature/emma-overview`

**你要告訴 Claude 的：**
```
請幫我做總覽頁的內容（放在 lib/features/accounts/presentation/screens/ 資料夾）：
- 最上方顯示「歡迎回來，小倉鼠！🐹」
- 一個大卡片顯示總資產 $123,456
- 下方三個小卡片並排：
  短期資產 $80,000
  長期資產 $43,456
  淨資產 $100,000
- 數字先用假的寫死就好
- 卡片設計要圓角（borderRadius 16）、有淡淡的陰影、簡潔好看
- 使用 AppColors 的顏色：primary #D4740A, primaryLight #FFF3E6, background #FFF8F0
```

---

#### Task 1-4：帳戶列表卡片

**分支名稱：** `feature/emma-account-cards`

**你要告訴 Claude 的：**
```
請在總覽頁的卡片下方加上「我的帳戶」區塊：
每個帳戶是一張橫向卡片，顯示：
- 左邊一個 emoji icon、帳戶名稱、帳戶類型
- 右邊顯示餘額與幣別

用以下假資料：
1. 🏦 國泰世華、銀行帳戶、TWD 150,000
2. 💰 現金、現金、TWD 5,000
3. 📈 Firstrade、投資帳戶、USD 3,200
4. 🏠 房子、不動產、TWD 8,000,000

卡片要圓角、有陰影、排列整齊。
```

---

#### Task 1-5：記帳頁按鈕

**分支名稱：** `feature/emma-add-transaction-btn`

**你要告訴 Claude 的：**
```
請幫我做記帳頁面的內容（放在 lib/features/transactions/presentation/screens/）：
- 畫面中間有一個大大的圓形「+」按鈕
- 按鈕是粉橘色 (#D4740A)、白色的「+」符號
- 點擊後從螢幕下方彈出一個白色面板 (Bottom Sheet)
- 面板裡面先顯示「新增記帳」標題就好
- 可以往下滑或點空白處關閉面板
```

---

#### Task 1-6：設定頁

**分支名稱：** `feature/emma-settings`

**你要告訴 Claude 的：**
```
請幫我做設定頁面的內容（放在 lib/features/accounts/presentation/screens/ 或適當的位置）：
- 最上方顯示 App 名稱 "Hamster's Stash" 和版本號 (v1.0.0)
- 下方是一個列表，每一項有 icon 和文字：
  ⚙️ 分類管理
  💰 預算設定
  📤 匯出資料
  🔒 隱私鎖
  ℹ️ 關於
- 點擊每一項先不用有反應，只要 UI 好看就好
- 每一項之間有淡淡的分隔線
```

---

### 🎨 Phase 2：更多 UI 元件（Day 5–10）

| # | 任務 | 說明 | 難度 |
|---|------|------|------|
| 2-1 | 分類選擇器 | 格子狀分類選擇，點擊展開小分類 | ⭐⭐ |
| 2-2 | 金額輸入鍵盤 | 數字鍵盤 + 簡單計算機 | ⭐⭐ |
| 2-3 | 記帳表單組裝 | 把金額+分類+備註組裝在 Bottom Sheet | ⭐⭐ |
| 2-4 | 交易紀錄列表 | 最近交易列表，支出紅色、收入綠色 | ⭐⭐ |
| 2-5 | 日曆檢視頁面 | 月曆+每日支出+點擊看明細 | ⭐⭐ |
| 2-6 | 報表頁圓餅圖 | 圓餅圖+分類明細列表 | ⭐⭐ |
| 2-7 | 空狀態插畫 | 可愛的空資料畫面 | ⭐ |

---

#### Task 2-1：分類選擇器

**分支名稱：** `feature/emma-category-picker`

**你要告訴 Claude 的：**
```
請幫我做一個分類選擇的元件（放在 lib/features/categories/presentation/widgets/）：
- 用格子狀排列，每排 4 個
- 每個分類是一個圓形 icon + 下方名稱
- 假資料用：
  🍔 飲食、🚌 交通、🎬 娛樂、🛒 購物
  🏠 住居、🏥 醫療、📚 教育、❤️ 其他
- 點擊分類後有選中的視覺回饋（比如邊框變色）
- 點擊後展開小分類，例如飲食 → 早餐、午餐、晚餐、飲料、零食
```

---

#### Task 2-2：金額輸入鍵盤

**分支名稱：** `feature/emma-number-pad`

**你要告訴 Claude 的：**
```
請幫我做一個自定的數字鍵盤（放在 lib/features/transactions/presentation/widgets/）：
- 上方有一個大大的金額顯示區，顯示目前輸入的數字
- 下方是 0–9 的數字按鈕，加上小數點和刪除鍵
- 另外有 +、−、×、÷ 四個運算按鈕和一個 = 按鈕
- 按鈕要大一點、容易點擊
- 風格要簡潔可愛，使用 AppColors 的顏色
```

---

#### Task 2-3：記帳表單組裝

**分支名稱：** `feature/emma-transaction-form`

**你要告訴 Claude 的：**
```
請幫我把記帳的彈出面板（Task 1-5 的 Bottom Sheet）內容組裝起來：
- 最上方是金額輸入區（用之前做的數字鍵盤）
- 中間是分類選擇器（用之前做的分類元件）
- 下方有一個「備註」輸入框，可以打字
- 最下方是一個大大的「儲存」按鈕
- 儲存按鈕點下去先不用真的存，顯示「已儲存！」的提示訊息就好
```

---

#### Task 2-4：交易紀錄列表

**分支名稱：** `feature/emma-transaction-list`

**你要告訴 Claude 的：**
```
請在總覽頁的帳戶列表下方加上「最近交易」區塊：
- 每筆交易顯示：分類 emoji、名稱、金額、日期
- 支出用紅色 (#E74C3C)、收入用綠色 (#2ECC71)

用以下假資料：
🍔 午餐 -$180   2/25
🚌 捷運 -$35    2/25
💰 薪資 +$45,000 2/24
🛒 超市 -$520   2/24
🎬 電影 -$380   2/23
```

---

#### Task 2-5：日曆檢視頁面

**分支名稱：** `feature/emma-calendar`

**你要告訴 Claude 的：**
```
請幫我做一個月曆頁面（放在 lib/features/calendar/presentation/screens/）：
- 用 table_calendar 套件顯示一個月曆，可以切換月份
- 每一天的格子下方顯示當日總支出的小數字
- 花越多的日子顏色越深（像是熱度圖）
- 點擊某一天會在下方顯示當日的交易明細
- 先用假資料就好
- 使用 AppColors 的配色
```

---

#### Task 2-6：報表頁圓餅圖

**分支名稱：** `feature/emma-report-chart`

**你要告訴 Claude 的：**
```
請幫我做報表頁面的內容（放在 lib/features/reports/presentation/screens/）：
- 最上方顯示「本月支出」和總金額
- 中間是一個彩色圓餅圖（用 fl_chart 套件），顯示各分類佔比
- 下方是分類明細列表，顯示顏色圓點 + 分類名 + 金額 + 百分比

用以下假資料：
🍔 飲食 35% $7,000
🚌 交通 15% $3,000
🎬 娛樂 20% $4,000
🛒 購物 18% $3,600
📦 其他 12% $2,400
```

---

#### Task 2-7：空狀態插畫

**分支名稱：** `feature/emma-empty-states`

**你要告訴 Claude 的：**
```
請幫我做幾個「空狀態」畫面元件（可重複使用的 Widget）：

第一個：還沒有交易紀錄時
- 用 emoji 組合一個可愛的畫面（例如 🐹 + 📭）
- 文字：「來記第一筆帳吧！」
- 下方有一個「開始記帳」按鈕

第二個：還沒有帳戶時
- emoji 畫面（例如 🐹 + 🏦）
- 文字：「新增你的第一個帳戶！」
- 下方有一個「新增帳戶」按鈕

風格要可愛、溫暖，使用 AppColors 配色。
```

---

### 💼 Phase 3–4：發揮你的會計專長（Day 11–25）

從這個階段開始，你的角色從「UI 設計師」轉為「會計顧問」。你不需要再用 Claude Code 寫程式，而是用你的專業知識來確保 App 的記帳邏輯是正確的。

> **你的產出會直接變成 App 的功能！**
> - 你定義的分類樹 → 會變成 App 的預設分類
> - 你設計的報表指標 → 會變成 App 的報表頁面
> - 你的驗算表 → 會變成自動化測試，確保計算永遠正確

| # | 任務 | 交付格式 | 難度 |
|---|------|---------|------|
| 3-E1 | 定義預設分類樹 | Excel / Google Sheets | ⭐⭐ |
| 3-E2 | 帳戶分類對照表 | Excel / Google Sheets | ⭐ |
| 3-E3 | 淨資產計算驗算 | Excel（含公式）| ⭐⭐ |
| 4-E1 | 預算規則設計 | Excel 或文件 | ⭐⭐ |
| 4-E2 | 應收應付流程審核 | Excel 或文件 | ⭐⭐ |
| 4-E3 | 報表指標設計 | 文件（含公式）| ⭐⭐ |
| 4-E4 | 轉帳與匯率驗算 | Excel（含公式）| ⭐⭐ |
| 4-E5 | CSV 匯出格式定義 | CSV 範例檔 + 說明 | ⭐⭐ |

---

#### Task 3-E1：定義預設分類樹

建立一份完整的分類清單 Excel，格式如下：

| 類型 | 大分類 | 小分類 | Emoji | 建議色碼 |
|------|--------|--------|-------|---------|
| 支出 | 飲食 | 早餐 | 🍳 | #FF6B6B |
| 支出 | 飲食 | 午餐 | 🍜 | #FF6B6B |
| 支出 | 交通 | 捷運 | 🚇 | #4ECDC4 |
| 收入 | 薪資 | 月薪 | 💰 | #2ECC71 |

請盡量完整，包含日常生活會用到的所有分類。

---

#### Task 3-E2：帳戶分類對照表

定義哪些帳戶類型屬於「短期資產」、哪些屬於「長期資產」：

| 帳戶類型 | 預設分類 | 範例 | 說明 |
|---------|---------|------|------|
| 現金 | 短期 | 錢包 | 可隨時使用 |
| 活存 | 短期 | 國泰活儲 | 可隨時提領 |
| 股票帳戶 | 短期 | Firstrade | 可隨時賣出 |
| 信用卡 | 負債 | 中信卡 | 待繳款項 |
| 定存 | 長期 | 郵局定存 | 到期才能提 |
| 不動產 | 長期 | 房子 | 長期持有 |

---

#### Task 3-E3：淨資產計算驗算

在 Excel 中建立驗算表，給定帳戶資料後計算：
- 短期資產小計（注意幣別換算）
- 長期資產小計
- 總資產 = 短期 + 長期
- 總負債 = 信用卡待繳 + 應付帳款
- 淨資產 = 總資產 − 總負債

請至少提供 **5 組**不同情境的測試數據。

---

#### Task 4-E1：預算規則設計

定義 App 中「預算管理」的規則：
- 建議哪些分類該設預算
- 預設警示閾值設在幾%（目前設 80%）
- 過月結轉邏輯：未用完加到下月？還是歸零？超支怎麼處理？

請用具體數字範例說明。

---

#### Task 4-E2：應收應付流程審核

用具體數字說明以下情境：
- 借出 $3,000 → 先收回 $1,000 → 再收回 $2,000 的完整流程
- 每一步的狀態變化（pending → partial → settled）
- 餘額計算是否正確

---

#### Task 4-E3：報表指標設計

定義 App 報表該顯示哪些數字：
- 月報表：總收入、總支出、淨收支、儲蓄率（公式？）
- 資產總覽：總資產、總負債、淨資產、資產變動率
- 分類分析：Top N 支出分類、與上月比較

---

#### Task 4-E4：轉帳與匯率驗算

建立跨幣別轉帳的測試案例 Excel，驗證：
- 轉出方扣款金額
- 轉入方入帳金額（匯率換算）
- 轉帳不計入收入或支出

提供 5–10 組測試數據。

---

#### Task 4-E5：CSV 匯出格式定義

定義匯出 CSV 的格式：
- 日期格式：YYYY-MM-DD 或 YYYY/MM/DD？
- 金額小數位數：固定 2 位？
- 分類怎麼表示：「飲食>午餐」還是分開兩欄？
- 轉帳怎麼表示：一筆還是兩筆？

提供一個範例 CSV 檔，含 10–20 筆交易。

---

### 🔍 Phase 5：會計驗收（Day 26–30）

| # | 任務 | 說明 | 難度 |
|---|------|------|------|
| 5-E1 | 全流程會計驗收 | 實際操作 App 驗證計算正確性 | ⭐⭐ |
| 5-E2 | 邊界案例測試 | 列出極端狀況的預期結果 | ⭐⭐ |
| 5-E3 | CSV 匯出驗收 | 匯入 Excel 驗證格式和數字 | ⭐⭐ |

---

#### Task 5-E1：全流程會計驗收

實際操作 App，輸入一組真實情境資料：
- 建立多個帳戶（含多幣別）
- 記幾筆交易（支出、收入、轉帳）
- 新增應收應付並部分收款
- 檢查總覽頁的數字是否算對

**任何算錯的地方，記錄為 bug report：「應該是 XX，但顯示 YY」**

---

#### Task 5-E2：邊界案例測試清單

從會計角度列出可能出問題的極端狀況：
- 金額為 0 的交易？
- 帳戶餘額變成負數？
- 同一帳戶轉帳給自己？
- 預算超支 200%？
- 應收金額收回超過原始金額？
- 匯率為 0 或負數？

每個案例說明「預期結果」應該是什麼。

---

#### Task 5-E3：CSV 匯出驗收

將 App 匯出的 CSV 匯入 Excel，驗證：
- 欄位是否符合你在 4-E5 定義的格式
- 金額小數位數正確
- 轉帳交易顯示正確
- 用 SUMIF 驗證彙總是否與 App 報表一致

---

## 7. 常見問題 FAQ

### Q: flutter run 出現錯誤怎麼辦？
告訴 Claude：「flutter run 出現以下錯誤：（貼上錯誤訊息）」，Claude 會幫你修。

### Q: 我改壞了怎麼辦？
告訴 Claude：「請幫我把剛才的修改復原」，Claude 會用 git 幫你還原。

### Q: 模擬器跑不起來？
- 確認 Android Studio 的模擬器有啟動
- 或改用 Chrome：`flutter run -d chrome`

### Q: Claude Code 卡住了？
按 `Ctrl + C` 中斷，然後重新輸入 `claude` 重新啟動。

### Q: 要怎麼看目前的 App 畫面？
- 如果用 Chrome：App 會在瀏覽器中打開
- 如果用 Android 模擬器：App 會在模擬器中顯示
- 修改程式碼後，通常會自動刷新（Hot Reload），不用重新啟動

### Q: 我需要同時修改很多檔案嗎？
不需要！你只要告訴 Claude 你想要什麼效果，Claude 會自己決定要修改哪些檔案。

### Q: commit 是什麼？
commit 就像是「存檔」。每次你完成一個小任務，就讓 Claude 幫你「存檔」一次。這樣如果之後出問題，可以回到之前的版本。

### Q: 什麼是 branch（分支）？
branch 就像是一個「平行世界」。你在自己的 branch 上工作，不會影響到其他人的程式碼。完成後再把你的修改合併回去。

---

## 設計規格速查

| 項目 | 值 |
|------|------|
| 主色 (Primary) | `#D4740A` 粉橘色 |
| 主色淺 (Primary Light) | `#FFF3E6` |
| 背景色 | `#FFF8F0` 暖白色 |
| 副色 (Secondary) | `#2E5090` 藍色 |
| 支出色 | `#E74C3C` 紅色 |
| 收入色 | `#2ECC71` 綠色 |
| 圓角 | 16px（卡片）/ 24px（大元件）/ 999px（圓形）|
| 大標題 | 28pt 粗體 |
| 副標題 | 18pt 半粗 |
| 內文 | 14pt 正常 |
| 小字 | 12pt |

---

🐹 **有任何問題隨時問 Erin！祝你玩得開心！**
