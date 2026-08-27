# API Specification — xSmartLive Plus One

Base URL 由各 Flavor 的 `FlavorConfig.baseUrl` 決定（UAT: `https://api-uat-1.xsmartlive.com/api`）。

所有需要認證的端點須在 Header 帶 `Authorization: Bearer <access_token>`。

> **路徑標記說明**
> - ✅ 已在 OpenAPI 文件的 `paths` 區段確認
> - 🔵 由 Schema 命名慣例推導（`App.Http.Requests.Api.V1.Mall.*`）
> - 完整的 API 文件是 [API_DOCUMENT.json](API_DOCUMENT.json)
---

## 認證 Auth

### 🔵 POST `/v1/mall/auth/login`
App（會員端）登入。

**login_type 枚舉**

| 值 | 說明 | 必填欄位 |
|----|------|----------|
| `"1"` | 手機 + 密碼 | `mobile`, `password` |
| `"2"` | 社群 Token（如 LINE） | `access_token`, `store_id` |
| `"3"` | Facebook PSID | `access_token`, `store_id`, `psid` |
| `"4"` | 其他社群 Token | `access_token`, `store_id` |

**Request**
```json
{
  "login_type": 1,
  "mobile": "+886987654321",
  "password": "$Abc123456",
  "captcha": "00000",
  "skip_captcha": true,
  "store_id": 1
}
```

**Response 200** — JWT（詳細結構待補）

## App 設定

### 🔵 GET `/v1/mall/app/setting`
取得 App 版本設定（判斷強制更新）。

**Response 200**
```json
{
  "ios": {
    "min_version": "1.0.0",
    "current_version": "1.2.0",
    "force_update": false
  },
  "android": {
    "min_version": "1.0.0",
    "current_version": "1.2.0",
    "force_update": false
  },
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-06-01T00:00:00Z"
}
```

---

## 市場 / 直播場 Market

### 🔵 GET `/v1/mall/market`（需認證）
取得市場列表。

**Response 200**
```json
[
  {
    "id": 1,
    "store_id": 10,
    "market_type": 1,
    "market_type_label": "直播",
    "name": "夏季特賣直播",
    "purchase_count": 320,
    "total_amount": 158000,
    "is_active": true,
    "started_at": "2024-06-01T14:00:00Z",
    "ended_at": "2024-06-01T16:00:00Z",
    "created_at": "2024-05-30T08:00:00Z",
    "updated_at": "2024-06-01T16:01:00Z"
  }
]
```

**market_type_label 枚舉**：`直播` | `直播貼單` | `非直播貼單` | `預售`

---

## 出價 / 搶購 Bid

**BidResource**
```json
{
  "id": 1,
  "store_id": 10,
  "member_id": 100,
  "market_id": 5,
  "product_card_id": 50,
  "product_id": 200,
  "product_name": "韓系小香風外套",
  "product_variant_id": 201,
  "quantity": 1,
  "unit_price": 299,
  "total_amount": 299,
  "remark": null,
  "is_abandoned": false,
  "created_at": "2024-06-01T14:30:00Z",
  "updated_at": "2024-06-01T14:30:00Z"
}
```

---

## 購物車 Cart

### 🔵 GET `/v1/mall/cart`（需認證）
取得目前購物車。

**Response 200 — CartResource**
```json
{
  "id": 1,
  "sku_count": 2,
  "subtotal": 598,
  "discount": 0,
  "total": 598,
  "items": [ /* CartItemResource[] */ ],
  "created_at": "2024-06-01T10:00:00Z",
  "updated_at": "2024-06-01T14:30:00Z"
}
```

> 金額欄位（subtotal / discount / total）以 **minor unit（最小貨幣單位）** 表示。

---

### 🔵 POST `/v1/mall/cart`（需認證）
將競標商品加入購物車。

**Request**
```json
{
  "store_id": 10,
  "bid_id": 1,
  "market_id": 5
}
```

**Response 201**

---

### 🔵 PUT `/v1/mall/cart/{cartItemId}`（需認證）
更新購物車商品數量。

**Request**
```json
{ "quantity": 2 }
```

> `quantity` 範圍：1–9999

**Response 200**

---

### 🔵 DELETE `/v1/mall/cart/{cartItemId}`（需認證）
移除購物車項目。**Response 204**

---

**CartItemResource**
```json
{
  "id": 1,
  "cart_id": 1,
  "bid_id": 1,
  "product_id": 200,
  "product_variant_id": 201,
  "quantity": 1,
  "unit_price": 299,
  "product": {
    "id": 200,
    "name": "韓系小香風外套"
  },
  "created_at": "2024-06-01T10:00:00Z",
  "updated_at": "2024-06-01T10:00:00Z"
}
```

---

## 結帳 Checkout

### 🔵 POST `/v1/mall/checkout/preview`（需認證）
預覽結帳金額（含折扣計算）。

**Request**
```json
{
  "cart_ids": [1],
  "cart_item_ids": [1, 2],
  "member_coupon_id": null
}
```

**Response 200** — 結帳預覽（詳細結構待補）

---

### 🔵 POST `/v1/mall/checkout/confirm`（需認證）
確認下單，建立訂單並觸發付款流程。

**Request**
```json
{
  "store_payment_method_id": 1,
  "store_shipping_method_id": 1,
  "member_coupon_id": null,
  "snapshot_url": "https://...",
  "bonus_amount": null,
  "credit_amount": null,
  "topup_amount": null,
  "cart_ids": [1],
  "cart_item_ids": [1, 2]
}
```

> `snapshot_url`：購物車快照連結，用於訂單記錄與客服議處理，最長 500 字元。

**Response 200** — 訂單建立結果

---

## 訂單 Purchase

### 🔵 GET `/v1/mall/purchase`（需認證）
取得訂單列表（分頁）。

**Response 200**
```json
{
  "data": [
    {
      "id": 1001,
      "amount": "598.00",
      "subtotal": "598.00",
      "shipping_fee": "0.00",
      "total_discount": "0.00",
      "status": {
        "paid": true,
        "shipped": false,
        "completed": false
      },
      "created_at": "2024-06-01T15:00:00Z"
    }
  ],
  "meta": {
    "pagination": {
      "current_page": "1",
      "page_size": "20",
      "total_pages": "3",
      "total_number": "52"
    }
  }
}
```

> 金額欄位為**字串格式**（已包含小數點）。

---

## 優惠券 Coupon

### 🔵 GET `/v1/mall/coupon`（需認證）
取得可用優惠券列表（分頁）。

**Response 200**
```json
{
  "data": [
    {
      "id": 1,
      "name": "新會員 100 元折扣券",
      "enable": 1,
      "discount_type": 1,
      "total_quota": 500,
      "usable_end_time": "2024-12-31T23:59:59Z",
      "status": "可使用"
    }
  ],
  "meta": { "pagination": { /* ... */ } }
}
```

**discount_type 枚舉**

| 值 | 說明 |
|----|------|
| `1` | 固定折扣金額 |
| `2` | 折扣後固定金額 |
| `3` | 折扣百分比 |
| `4` | 折扣後百分比 |

---

## 紅利點數 Bonus

### 🔵 GET `/v1/mall/bonus/balance`（需認證）
取得會員紅利點數餘額。

**Response 200**
```json
{
  "point_balance": 350,
  "updated_at": "2024-06-01T12:00:00Z",
  "expiring_points": "100",
  "expiring_at": "2024-12-31T23:59:59Z"
}
```

---

### 🔵 POST `/v1/mall/bonus/spend`（需認證）
於結帳時使用紅利點數折抵。

**Request**
```json
{
  "purchase_id": 1001,
  "point_used": 100,
  "purchase_ref_type": null,
  "note": null
}
```

**Response 200 — BonusUsageResource**
```json
{
  "id": 1,
  "member_id": 100,
  "purchase_id": 1001,
  "point_used": 100,
  "converted_amount": 10.00,
  "note": null,
  "created_at": "2024-06-01T15:01:00Z"
}
```

---

## 購物金 Credit

### 🔵 GET `/v1/mall/credit/balance`（需認證）
取得會員購物金餘額。

**Response 200**
```json
{
  "id": 1,
  "store_id": 10,
  "member_id": 100,
  "currency": "TWD",
  "total_amount": 500.00,
  "locked_amount": 0.00,
  "available_amount": 500.00,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-06-01T00:00:00Z"
}
```

---

### 🔵 POST `/v1/mall/credit/spend`（需認證）
於結帳時使用購物金折抵。

**Request**
```json
{
  "purchase_id": 1001,
  "amount_used": 100.00,
  "note": null
}
```

> `amount_used` 範圍：0.01–999,999.99

**Response 200** — CreditEarningResource

---

## 錯誤格式

所有錯誤回應統一格式：

```json
{
  "message": "Human-readable error description"
}
```

**422 ValidationException**（欄位驗證失敗）：
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "field_name": ["欄位錯誤說明"]
  }
}
```

| HTTP Status | 說明 |
|-------------|------|
| 400 | 請求參數錯誤 |
| 401 | 未認證或 Token 已失效 |
| 403 | 無權限 |
| 404 | 資源不存在 |
| 422 | 欄位驗證失敗 |
| 500 | 伺服器內部錯誤 |
