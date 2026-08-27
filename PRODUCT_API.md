Change Log
版本
說明
日期
建立者
v1.0
初版
2025/10/31
@蔡宗益
v1.1
新增 API - 取得商家擁有的商品分類、修改路徑名稱 center => mall
2025/11/10
@蔡宗益
v1.2
新增加價購 api
2026/03/02
@蔡宗益
v1.3
新增商品卡 api & 棄用取商品 api
2026/03/03
@蔡宗益
v1.4
- 新增商城分類 (product group) api
- 修改 取得商品卡列表 輸入參數 (market_id & group_id 為擇一必填)
  2026/03/23
  @蔡宗益
  商品卡 (product_card)
  ● 取得商品卡列表
  GET /api/v1/mall/store/{store_id}/productCard
  Query 參數
  參數名稱
  參數中文名稱
  型態
  備註
  page
  頁數
  integer
  預設 1
  page_size
  每頁筆數
  integer
  預設 20
  market_id
  賣場 id
  integer
  沒有輸入 group_id 時為必填
  category_ids
  分類 id
  array

category_ids[]

integer

type
商品類型
integer

keyword
關鍵字
string
後綴匹配模糊查詢
group_id
商城分類 id
integer
沒有輸入 market_id 時為必填
order_by
排序依據
string
預設 id，可選 id, created_at
direction
排序方向
string
預設 desc，可選 asc, desc
響應範例
{
"success": true,
"data": [
{
"id": 1,
"store_id": 1,
"market_id": 1,
"product_id": 1,
"type": 1,
"name": "化妝品A (商品卡)",
"has_spec": false,
"status": 1,
"allow_oversell": false,
"use_original_stock": true,
"keyword": "",
"category": [
{
"id": 1,
"name": "美妝保養",
"child": [
{
"id": 5,
"name": "彩妝"
}
]
}
],
"image": [
{
"id": 1,
"sequence": 1,
"url": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/2026/03/02/1772442209_e92a2331-2388-4379-ac64-7a51020a80c8.jpg",
"created_at": "2026-03-02T01:07:41.000000Z",
"updated_at": "2026-03-02T01:07:41.000000Z"
}
],
"detail": {
"id": 1,
"store_id": 1,
"product_id": 1,
"intro": "",
"note": "",
"tags": [
"零食"
],
"weight": 0,
"created_at": "2026-03-02T09:07:41.000000Z",
"updated_at": "2026-03-02T09:07:41.000000Z"
},
"variant": [
{
"id": 1,
"product_card_id": 1,
"store_id": 1,
"specs": [],
"original_price": 100,
"sale_price": 120,
"stock": 0,
"created_at": "2026-03-02T01:17:38.000000Z",
"updated_at": "2026-03-02T01:17:38.000000Z"
}
],
"spec": [],
"publish_at": null,
"unpublish_at": null,
"created_at": "2026-03-02T09:17:38.000000Z",
"updated_at": "2026-03-02T09:17:38.000000Z"
}
],
"meta": {
"pagination": {
"current_page": 1,
"page_size": 20,
"total_pages": 1,
"total_number": 1
}
}
}
商品 (product) @deprecated
● 取得商品列表
GET /api/v1/mall/store/{store_id}/product
Query 參數
參數名稱
參數中文名稱
型態
備註
page
頁數
integer
預設 1
page_size
每頁筆數
integer
預設 20
category_ids
分類 id
array

category_ids[]

integer

keyword
關鍵字
string
後綴匹配模糊查詢
order_by
排序依據
string
預設 id，可選 id, created_at
direction
排序方向
string
預設 desc，可選 asc, desc
響應範例
{
"success": true,
"data": [
{
"id": 422,
"store_id": 1,
"name": "外套",
"has_spec": true,
"status": 0,
"category": [
{
"id": 6,
"name": "餅乾"
}
],
"image": [
{
"id": 200,
"sequence": 1,
"url": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/dog_1761725145.png",
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
},
{
"id": 201,
"sequence": 2,
"url": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/pig_1761725145.jpg",
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
}
],
"detail": {
"id": 854,
"store_id": 1,
"product_id": 422,
"intro": "這是商品介紹",
"note": "這是商品備註",
"tags": [
"流行",
"韓風"
],
"weight": 0,
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
},
"variant": [
{
"id": 1155,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001883,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "XL",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/1_1761725144.jpg"
},
{
"id": 10001887,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 10,C
"original_price": 20,
"sale_price": 30,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-30 16:22:26"
},
{
"id": 1156,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001883,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "XL",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/1_1761725144.jpg"
},
{
"id": 10001888,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 5,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-30 16:22:26"
},
{
"id": 1157,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001884,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "L",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
},
{
"id": 10001887,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
},
{
"id": 1158,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001884,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "L",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
},
{
"id": 10001888,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
},
{
"id": 1159,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001885,
"store_id": 1,
"product_id": 422,
"sequence": 3,
"name": "M",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/2_1761725144.jpg"
},
{
"id": 10001887,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
},
{
"id": 1160,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001885,
"store_id": 1,
"product_id": 422,
"sequence": 3,
"name": "M",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/2_1761725144.jpg"
},
{
"id": 10001888,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
}
],
"publish_at": "2026-01-01 09:30:00",
"unpublish_at": null,
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
},
{
"id": 419,
"store_id": 1,
"name": "外套",
"has_spec": true,
"status": 0,
"category": [
{
"id": 5,
"name": "手機耳機"
}
],
"image": [],
"detail": {
"id": 851,
"store_id": 1,
"product_id": 419,
"intro": "這是商品介紹",
"note": "這是商品備註",
"tags": [
"流行",
"韓風"
],
"weight": 0,
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
},
"variant": [
{
"id": 1149,
"product_id": 419,
"store_id": 1,
"specs": [
{
"id": 10001872,
"store_id": 1,
"product_id": 419,
"sequence": 1,
"name": "XL",
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
},
{
"id": 10001876,
"store_id": 1,
"product_id": 419,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 5,
"status": 0,
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-30 11:23:45"
},
{
"id": 1150,
"product_id": 419,
"store_id": 1,
"specs": [
{
"id": 10001872,
"store_id": 1,
"product_id": 419,
"sequence": 1,
"name": "XL",
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
},
{
"id": 10001877,
"store_id": 1,
"product_id": 419,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 9,
"status": 0,
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-30 16:22:26"
},
{
"id": 1151,
"product_id": 419,
"store_id": 1,
"specs": [
{
"id": 10001873,
"store_id": 1,
"product_id": 419,
"sequence": 2,
"name": "L",
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
},
{
"id": 10001876,
"store_id": 1,
"product_id": 419,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
},
{
"id": 1152,
"product_id": 419,
"store_id": 1,
"specs": [
{
"id": 10001873,
"store_id": 1,
"product_id": 419,
"sequence": 2,
"name": "L",
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
},
{
"id": 10001877,
"store_id": 1,
"product_id": 419,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
},
{
"id": 1153,
"product_id": 419,
"store_id": 1,
"specs": [
{
"id": 10001874,
"store_id": 1,
"product_id": 419,
"sequence": 3,
"name": "M",
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
},
{
"id": 10001876,
"store_id": 1,
"product_id": 419,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
},
{
"id": 1154,
"product_id": 419,
"store_id": 1,
"specs": [
{
"id": 10001874,
"store_id": 1,
"product_id": 419,
"sequence": 3,
"name": "M",
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
},
{
"id": 10001877,
"store_id": 1,
"product_id": 419,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:04:15",
"updated_at": "2025-10-29 16:04:15"
}
],
"publish_at": "2026-01-01 09:30:00",
"unpublish_at": null,
"created_at": "2025-10-29 16:04:14",
"updated_at": "2025-10-29 16:04:14"
},
{
"id": 418,
"store_id": 1,
"name": "卡通上衣",
"has_spec": true,
"status": 0,
"category": [
{
"id": 1,
"name": "3C",
"child": [
{
"id": 4,
"name": "手機",
"child": [
{
"id": 5,
"name": "手機耳機"
}
]
}
]
},
{
"id": 4,
"name": "手機",
"child": [
{
"id": 5,
"name": "手機耳機"
}
]
},
{
"id": 5,
"name": "手機耳機"
}
],
"image": [],
"detail": {
"id": 850,
"store_id": 1,
"product_id": 418,
"intro": "美樂蒂圖案",
"note": "",
"tags": [],
"weight": 0,
"created_at": "2025-10-29 15:18:34",
"updated_at": "2025-10-29 15:18:34"
},
"variant": [
{
"id": 1146,
"product_id": 418,
"store_id": 1,
"specs": [
{
"id": 10001868,
"store_id": 1,
"product_id": 418,
"sequence": 1,
"name": "XL",
"created_at": "2025-10-29 15:18:35",
"updated_at": "2025-10-29 15:18:35"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 15:18:35",
"updated_at": "2025-10-29 15:18:35"
},
{
"id": 1147,
"product_id": 418,
"store_id": 1,
"specs": [
{
"id": 10001869,
"store_id": 1,
"product_id": 418,
"sequence": 2,
"name": "L",
"created_at": "2025-10-29 15:18:35",
"updated_at": "2025-10-29 15:18:35"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 50,
"stock": 20,
"status": 0,
"created_at": "2025-10-29 15:18:35",
"updated_at": "2025-10-29 15:18:35"
},
{
"id": 1148,
"product_id": 418,
"store_id": 1,
"specs": [
{
"id": 10001870,
"store_id": 1,
"product_id": 418,
"sequence": 3,
"name": "M",
"created_at": "2025-10-29 15:18:35",
"updated_at": "2025-10-29 15:18:35"
}
],
"cost": 30,
"original_price": 60,
"sale_price": 70,
"stock": 30,
"status": 0,
"created_at": "2025-10-29 15:18:35",
"updated_at": "2025-10-29 15:18:35"
}
],
"publish_at": null,
"unpublish_at": null,
"created_at": "2025-10-29 15:18:34",
"updated_at": "2025-10-29 15:18:34"
},
{
"id": 416,
"store_id": 1,
"name": "外套",
"has_spec": true,
"status": 0,
"category": [
{
"id": 5,
"name": "手機耳機"
}
],
"image": [],
"detail": {
"id": 848,
"store_id": 1,
"product_id": 416,
"intro": "這是商品介紹",
"note": "這是商品備註",
"tags": [
"流行",
"韓風"
],
"weight": 0,
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 10:58:38"
},
"variant": [
{
"id": 1134,
"product_id": 416,
"store_id": 1,
"specs": [
{
"id": 10001854,
"store_id": 1,
"product_id": 416,
"sequence": 3,
"name": "XL",
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 15:27:50"
},
{
"id": 10001858,
"store_id": 1,
"product_id": 416,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 10:58:38"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 10:58:38"
},
{
"id": 1135,
"product_id": 416,
"store_id": 1,
"specs": [
{
"id": 10001854,
"store_id": 1,
"product_id": 416,
"sequence": 3,
"name": "XL",
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 15:27:50"
},
{
"id": 10001859,
"store_id": 1,
"product_id": 416,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 10:58:38"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 10:58:38"
},
{
"id": 1136,
"product_id": 416,
"store_id": 1,
"specs": [
{
"id": 10001855,
"store_id": 1,
"product_id": 416,
"sequence": 1,
"name": "L",
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 15:27:51"
},
{
"id": 10001858,
"store_id": 1,
"product_id": 416,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 10:58:38"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 10:58:38"
},
{
"id": 1137,
"product_id": 416,
"store_id": 1,
"specs": [
{
"id": 10001855,
"store_id": 1,
"product_id": 416,
"sequence": 1,
"name": "L",
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 15:27:51"
},
{
"id": 10001859,
"store_id": 1,
"product_id": 416,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 10:58:38"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 10:58:38"
},
{
"id": 1138,
"product_id": 416,
"store_id": 1,
"specs": [
{
"id": 10001856,
"store_id": 1,
"product_id": 416,
"sequence": 2,
"name": "M",
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 15:27:52"
},
{
"id": 10001858,
"store_id": 1,
"product_id": 416,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 10:58:38"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 10:58:38"
},
{
"id": 1139,
"product_id": 416,
"store_id": 1,
"specs": [
{
"id": 10001856,
"store_id": 1,
"product_id": 416,
"sequence": 2,
"name": "M",
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 15:27:52"
},
{
"id": 10001859,
"store_id": 1,
"product_id": 416,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 10:58:38"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 10:58:38"
}
],
"publish_at": "2026-01-01 09:30:00",
"unpublish_at": null,
"created_at": "2025-10-29 10:58:38",
"updated_at": "2025-10-29 10:58:38"
},
{
"id": 399,
"store_id": 1,
"name": "卡通上衣",
"has_spec": true,
"status": 0,
"category": [
{
"id": 1,
"name": "3C",
"child": [
{
"id": 4,
"name": "手機",
"child": [
{
"id": 5,
"name": "手機耳機"
}
]
}
]
},
{
"id": 4,
"name": "手機",
"child": [
{
"id": 5,
"name": "手機耳機"
}
]
},
{
"id": 6,
"name": "餅乾"
}
],
"image": [],
"detail": {
"id": 831,
"store_id": 1,
"product_id": 399,
"intro": "美樂蒂圖案",
"note": "",
"tags": [],
"weight": 0,
"created_at": "2025-10-23 14:16:21",
"updated_at": "2025-10-23 14:16:21"
},
"variant": [
{
"id": 1122,
"product_id": 399,
"store_id": 1,
"specs": [
{
"id": 10001811,
"store_id": 1,
"product_id": 399,
"sequence": 1,
"name": "XL",
"created_at": "2025-10-23 14:16:21",
"updated_at": "2025-10-23 14:16:21"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 10,
"status": 0,
"created_at": "2025-10-23 14:16:21",
"updated_at": "2025-10-23 14:16:21"
},
{
"id": 1123,
"product_id": 399,
"store_id": 1,
"specs": [
{
"id": 10001812,
"store_id": 1,
"product_id": 399,
"sequence": 2,
"name": "L",
"created_at": "2025-10-23 14:16:21",
"updated_at": "2025-10-23 14:16:21"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 50,
"stock": 20,
"status": 0,
"created_at": "2025-10-23 14:16:21",
"updated_at": "2025-10-23 14:16:21"
},
{
"id": 1124,
"product_id": 399,
"store_id": 1,
"specs": [
{
"id": 10001813,
"store_id": 1,
"product_id": 399,
"sequence": 3,
"name": "M",
"created_at": "2025-10-23 14:16:21",
"updated_at": "2025-10-23 14:16:21"
}
],
"cost": 30,
"original_price": 60,
"sale_price": 70,
"stock": 30,
"status": 0,
"created_at": "2025-10-23 14:16:22",
"updated_at": "2025-10-23 14:16:22"
}
],
"publish_at": null,
"unpublish_at": null,
"created_at": "2025-10-23 14:16:21",
"updated_at": "2025-10-23 14:16:21"
},
{
"id": 4,
"store_id": 1,
"name": "無規格商品",
"has_spec": false,
"status": 0,
"category": [],
"image": [],
"detail": {
"id": 11,
"store_id": 1,
"product_id": 4,
"intro": "0",
"note": "0",
"tags": 0,
"weight": 0.5,
"created_at": "2025-08-06 14:18:00",
"updated_at": "2025-08-06 14:18:00"
},
"variant": [
{
"id": 11,
"product_id": 4,
"store_id": 0,
"specs": [],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 100,
"status": 0,
"created_at": "2025-08-19 14:36:02",
"updated_at": "2025-08-19 14:37:22"
}
],
"publish_at": null,
"unpublish_at": null,
"created_at": "2025-08-06 14:17:50",
"updated_at": "2025-08-29 17:10:15"
},
{
"id": 3,
"store_id": 1,
"name": "乖乖",
"has_spec": true,
"status": 0,
"category": [],
"image": [],
"detail": {
"id": 10,
"store_id": 1,
"product_id": 3,
"intro": "0",
"note": "0",
"tags": 0,
"weight": 10,
"created_at": "2025-08-06 14:18:00",
"updated_at": "2025-08-06 14:18:00"
},
"variant": [
{
"id": 9,
"product_id": 3,
"store_id": 0,
"specs": [
{
"id": 15,
"store_id": 1,
"product_id": 3,
"sequence": 1,
"name": "綠",
"created_at": "2025-08-06 14:18:21",
"updated_at": "2025-08-06 14:18:21"
},
{
"id": 16,
"store_id": 1,
"product_id": 3,
"sequence": 2,
"name": "黑",
"created_at": "2025-08-06 14:18:21",
"updated_at": "2025-08-06 14:18:21"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 100,
"status": 0,
"created_at": "2025-08-19 14:36:02",
"updated_at": "2025-08-19 14:37:21"
},
{
"id": 10,
"product_id": 3,
"store_id": 0,
"specs": [],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 100,
"status": 0,
"created_at": "2025-08-19 14:36:02",
"updated_at": "2025-08-19 14:37:21"
}
],
"publish_at": null,
"unpublish_at": null,
"created_at": "2025-08-06 14:17:50",
"updated_at": "2025-08-29 17:10:13"
},
{
"id": 2,
"store_id": 1,
"name": "運動鞋",
"has_spec": true,
"status": 0,
"category": [],
"image": [],
"detail": {
"id": 8,
"store_id": 1,
"product_id": 2,
"intro": "0",
"note": "0",
"tags": 0,
"weight": 1,
"created_at": "2025-08-06 14:18:00",
"updated_at": "2025-08-06 14:18:00"
},
"variant": [
{
"id": 5,
"product_id": 2,
"store_id": 0,
"specs": [
{
"id": 9,
"store_id": 2,
"product_id": 2,
"sequence": 1,
"name": "adidas",
"created_at": "2025-08-06 14:18:21",
"updated_at": "2025-08-06 14:18:21"
},
{
"id": 13,
"store_id": 2,
"product_id": 2,
"sequence": 1,
"name": "26",
"created_at": "2025-08-06 14:18:21",
"updated_at": "2025-08-06 14:18:21"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 100,
"status": 0,
"created_at": "2025-08-19 14:36:02",
"updated_at": "2025-08-19 14:37:18"
},
{
"id": 6,
"product_id": 2,
"store_id": 0,
"specs": [
{
"id": 10,
"store_id": 2,
"product_id": 2,
"sequence": 2,
"name": "PUMA",
"created_at": "2025-08-06 14:18:21",
"updated_at": "2025-08-06 14:18:21"
},
{
"id": 13,
"store_id": 2,
"product_id": 2,
"sequence": 1,
"name": "26",
"created_at": "2025-08-06 14:18:21",
"updated_at": "2025-08-06 14:18:21"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 100,
"status": 0,
"created_at": "2025-08-19 14:36:02",
"updated_at": "2025-08-19 14:37:18"
},
{
"id": 7,
"product_id": 2,
"store_id": 0,
"specs": [
{
"id": 11,
"store_id": 2,
"product_id": 2,
"sequence": 3,
"name": "New Balance",
"created_at": "2025-08-06 14:18:21",
"updated_at": "2025-08-06 14:18:21"
},
{
"id": 13,
"store_id": 2,
"product_id": 2,
"sequence": 1,
"name": "26",
"created_at": "2025-08-06 14:18:21",
"updated_at": "2025-08-06 14:18:21"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 100,
"status": 0,
"created_at": "2025-08-19 14:36:02",
"updated_at": "2025-08-19 14:37:19"
},
{
"id": 8,
"product_id": 2,
"store_id": 0,
"specs": [
{
"id": 12,
"store_id": 2,
"product_id": 2,
"sequence": 4,
"name": "NIKE",
"created_at": "2025-08-06 14:18:21",
"updated_at": "2025-08-06 14:18:21"
},
{
"id": 13,
"store_id": 2,
"product_id": 2,
"sequence": 1,
"name": "26",
"created_at": "2025-08-06 14:18:21",
"updated_at": "2025-08-06 14:18:21"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 100,
"status": 0,
"created_at": "2025-08-19 14:36:02",
"updated_at": "2025-08-19 14:37:19"
}
],
"publish_at": null,
"unpublish_at": null,
"created_at": "2025-08-06 14:17:50",
"updated_at": "2025-08-29 17:10:12"
}
],
"meta": {
"pagination": {
"current_page": 1,
"page_size": 20,
"total_pages": 1,
"total_number": 8
}
}
}
● 取得單一商品資料
GET /api/v1/mall/store/{store_id}/product/{product_id}
響應範例
{
"success": true,
"data": {
"id": 422,
"store_id": 1,
"name": "外套",
"has_spec": true,
"status": 0,
"category": [
{
"id": 6,
"name": "餅乾"
}
],
"image": [
{
"id": 200,
"sequence": 1,
"url": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/dog_1761725145.png",
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
},
{
"id": 201,
"sequence": 2,
"url": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/pig_1761725145.jpg",
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
}
],
"detail": {
"id": 854,
"store_id": 1,
"product_id": 422,
"intro": "這是商品介紹",
"note": "這是商品備註",
"tags": [
"流行",
"韓風"
],
"weight": 0,
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
},
"variant": [
{
"id": 1155,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001883,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "XL",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/1_1761725144.jpg"
},
{
"id": 10001887,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-30 16:22:26"
},
{
"id": 1156,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001883,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "XL",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/1_1761725144.jpg"
},
{
"id": 10001888,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 5,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-30 16:22:26"
},
{
"id": 1157,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001884,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "L",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
},
{
"id": 10001887,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
},
{
"id": 1158,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001884,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "L",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
},
{
"id": 10001888,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
},
{
"id": 1159,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001885,
"store_id": 1,
"product_id": 422,
"sequence": 3,
"name": "M",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/2_1761725144.jpg"
},
{
"id": 10001887,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
},
{
"id": 1160,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001885,
"store_id": 1,
"product_id": 422,
"sequence": 3,
"name": "M",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/2_1761725144.jpg"
},
{
"id": 10001888,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
}
],
"publish_at": "2026-01-01 09:30:00",
"unpublish_at": null,
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
}
商品規格細項 (product_variant)
● 取得某一商品規格細項資料
GET /api/v1/mall/store/{store_id}/product/{product_id}/variant
撈出商品所有規格的售價、庫存等細項資料
響應範例
{
"success": true,
"data": [
{
"id": 1155,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001883,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "XL",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/1_1761725144.jpg"
},
{
"id": 10001887,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-30 16:22:26"
},
{
"id": 1156,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001883,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "XL",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/1_1761725144.jpg"
},
{
"id": 10001888,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 5,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-30 16:22:26"
},
{
"id": 1157,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001884,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "L",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
},
{
"id": 10001887,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
},
{
"id": 1158,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001884,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "L",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
},
{
"id": 10001888,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
},
{
"id": 1159,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001885,
"store_id": 1,
"product_id": 422,
"sequence": 3,
"name": "M",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/2_1761725144.jpg"
},
{
"id": 10001887,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
},
{
"id": 1160,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001885,
"store_id": 1,
"product_id": 422,
"sequence": 3,
"name": "M",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/2_1761725144.jpg"
},
{
"id": 10001888,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 20,
"original_price": 40,
"sale_price": 60,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
}
],
"meta": {
"pagination": {
"current_page": 1,
"page_size": 20,
"total_pages": 1,
"total_number": 6
}
}
}
● 取得某一規格細項資料
GET /api/v1/mall/store/{store_id}/product/variant/{variant_id}
響應範例
{
"success": true,
"data": {
"id": 1157,
"product_id": 422,
"store_id": 1,
"specs": [
{
"id": 10001884,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "L",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
},
{
"id": 10001887,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"cost": 10,
"original_price": 20,
"sale_price": 30,
"stock": 10,
"status": 0,
"created_at": "2025-10-29 16:05:45",
"updated_at": "2025-10-29 16:05:45"
}
}
商品規格 (product_spec)
● 取得某一商品的規格
GET /api/v1/mall/store/{store_id}/product/{product_id}/spec
撈出商品所有的規格
響應範例
{
"success": true,
"data": [
{
"id": 10001882,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "尺寸",
"child": [
{
"id": 10001883,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "XL",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/1_1761725144.jpg"
},
{
"id": 10001884,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "L",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
},
{
"id": 10001885,
"store_id": 1,
"product_id": 422,
"sequence": 3,
"name": "M",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/2_1761725144.jpg"
}
],
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:17:31"
},
{
"id": 10001886,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "顏色",
"child": [
{
"id": 10001887,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "紅",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
},
{
"id": 10001888,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "綠",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
}
],
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:17:35"
}
],
"meta": {
"pagination": {
"current_page": 1,
"page_size": 20,
"total_pages": 1,
"total_number": 2
}
}
}
● 取得某一規格資料
GET /api/v1/mall/store/{store_id}/product/spec/{spec_id}
響應範例
{
"success": true,
"data": {
"id": 10001882,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "尺寸",
"child": [
{
"id": 10001883,
"store_id": 1,
"product_id": 422,
"sequence": 1,
"name": "XL",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/1_1761725144.jpg"
},
{
"id": 10001884,
"store_id": 1,
"product_id": 422,
"sequence": 2,
"name": "L",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44"
},
{
"id": 10001885,
"store_id": 1,
"product_id": 422,
"sequence": 3,
"name": "M",
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:05:44",
"image": "https://dev-168money.s3.ap-northeast-1.amazonaws.com/uploads/2_1761725144.jpg"
}
],
"created_at": "2025-10-29 16:05:44",
"updated_at": "2025-10-29 16:17:31"
}
}
商城分類 (product_group)
● 取得商城分類列表
GET /api/v1/mall/store/{store_id}/productGroup
響應範例
{
"success": true,
"data": [
{
"id": 6,
"name": "主分類3"
},
{
"id": 8,
"name": "主分類111"
},
{
"id": 4,
"name": "主分類2"
}
],
"meta": {
"pagination": {
"current_page": 1,
"page_size": 20,
"total_pages": 1,
"total_number": 3
}
}
}
分類 (category)
● 取得分類列表
GET /api/v1/mall/category
響應範例
{
"success": true,
"data": [
{
"id": 1,
"name": "3C",
"child": [
{
"id": 4,
"name": "手機",
"child": [
{
"id": 5,
"name": "手機耳機"
}
]
}
]
},
{
"id": 2,
"name": "食品",
"child": [
{
"id": 6,
"name": "餅乾"
}
]
},
{
"id": 3,
"name": "運動用品"
},
{
"id": 7,
"name": "服飾"
}
]
}
● 取得單一分類資料
GET /api/v1/mall/category/{category_id}
響應範例
{
"success": true,
"data": {
"id": 1,
"name": "3C",
"child": [
{
"id": 4,
"name": "手機",
"child": [
{
"id": 5,
"name": "手機耳機"
}
]
}
]
}
}
響應範例
{
"success": true,
"data": true
}
● 取得商家擁有的商品分類
GET /api/v1/mall/store/{store_id}/category
響應範例
{
"success": true,
"data": [
{
"id": 1,
"name": "健康與美容"
},
{
"id": 1,
"name": "健康與美容",
"child": [
{
"id": 2,
"name": "健康保健"
}
]
},
{
"id": 1,
"name": "健康與美容",
"child": [
{
"id": 2,
"name": "健康保健",
"child": [
{
"id": 4,
"name": "口腔保健"
}
]
}
]
},
{
"id": 1,
"name": "健康與美容",
"child": [
{
"id": 2,
"name": "健康保健",
"child": [
{
"id": 5,
"name": "女性私人護理"
}
]
}
]
},
{
"id": 1,
"name": "健康與美容",
"child": [
{
"id": 2,
"name": "健康保健",
"child": [
{
"id": 6,
"name": "急救護理"
}
]
}
]
},
{
"id": 1,
"name": "健康與美容",
"child": [
{
"id": 9,
"name": "美容",
"child": [
{
"id": 10,
"name": "化妝",
"child": [
{
"id": 11,
"name": "化妝套組"
}
]
}
]
}
]
},
{
"id": 1,
"name": "健康與美容",
"child": [
{
"id": 9,
"name": "美容",
"child": [
{
"id": 10,
"name": "化妝",
"child": [
{
"id": 12,
"name": "化妝工具和配件",
"child": [
{
"id": 14,
"name": "刷子和海綿"
}
]
}
]
}
]
}
]
},
{
"id": 1,
"name": "健康與美容",
"child": [
{
"id": 9,
"name": "美容",
"child": [
{
"id": 47,
"name": "沐浴和身體用品",
"child": [
{
"id": 56,
"name": "海綿和刷子"
}
]
}
]
}
]
},
{
"id": 1269,
"name": "服飾和配件",
"child": [
{
"id": 1337,
"name": "服飾",
"child": [
{
"id": 1348,
"name": "女裝",
"child": [
{
"id": 1349,
"name": "上衣"
}
]
}
]
}
]
},
{
"id": 1269,
"name": "服飾和配件",
"child": [
{
"id": 1337,
"name": "服飾",
"child": [
{
"id": 1453,
"name": "男裝",
"child": [
{
"id": 1455,
"name": "上衣"
}
]
}
]
}
]
},
{
"id": 2930,
"name": "食品和飲品",
"child": [
{
"id": 2931,
"name": "食品",
"child": [
{
"id": 2948,
"name": "點心和薯片"
}
]
}
]
}
]
}
加價購 (upsell)
● 取得加購商品
GET /api/v1/mall/store/{store_id}/upsell?product_id={product_id}&market_type={market_type}&category_id={category_id}
Query 參數
參數名稱
參數中文名稱
必填
型態
備註
page
頁數

integer
預設 1
page_size
每頁筆數

integer
預設 20
product_id
主商品 id
V
integer

market_type
主商品源自哪個賣場
V
integer

category_id
主商品的商品分類
V
integer

響應範例
{
"success": true,
"data": [
{
"id": 577,
"name": "外套",
"detail": {
"id": 989,
"store_id": 1,
"product_id": 577,
"intro": "這是商品介紹",
"note": "這是商品備註",
"tags": [
"流行",
"韓風"
],
"weight": 0,
"created_at": "2026-01-16T07:39:02.000000Z",
"updated_at": "2026-01-16T07:39:02.000000Z"
},
"image": [
{
"id": 331,
"sequence": 1,
"url": "https://dev-168money.s3.ap-northeast-1.amazonaws.com",
"created_at": "2026-01-15T09:12:30.000000Z",
"updated_at": "2026-01-22T06:10:47.000000Z"
}
]
},
{
"id": 579,
"name": "組合商品",
"detail": {
"id": 991,
"store_id": 1,
"product_id": 579,
"intro": "",
"note": "",
"tags": [
"測試"
],
"weight": 0,
"created_at": "2026-01-19T05:32:08.000000Z",
"updated_at": "2026-01-19T05:32:08.000000Z"
},
"image": []
}
]
}


---

# 多國語言 (Localisation)

## 版本
| 版本 | 說明 | 日期 | 建立者 |
|------|------|------|--------|
| v1.0 | 初版 | 2026/04/17 | @ZhengLun |

---

## 規則

### 1. 支援語言清單
| 語言標籤 | 顯示名稱 | 備註 |
|----------|----------|------|
| zh-TW | 繁體中文 | 預設語言 |
| zh-CN | 简体中文 | |
| en | English | |
| ja | 日本語 | |
| ko | 한국어 | |

### 2. 語言切換規則
- 使用者選擇的語言以 `SharedPreferences` 鍵值 `app_locale` 持久化存儲，格式為 IETF 語言標籤（如 `zh-TW`、`en`）。
- APP 啟動時讀取儲存值；若無則預設 `zh-TW`（繁體中文）。
- 語言切換立即生效，不需重啟 APP。
- 語言設定透過 `localeNotifierProvider`（Riverpod `AsyncNotifierProvider`）管理，`MaterialApp.router` 的 `locale` 屬性綁定此 provider。

### 3. 本地化委派 (Localization Delegates)
- 必須於 `MaterialApp` 設定以下委派：
  - `GlobalMaterialLocalizations.delegate`
  - `GlobalWidgetsLocalizations.delegate`
  - `GlobalCupertinoLocalizations.delegate`
- 對應 Flutter SDK 套件：`flutter_localizations`（已列於 `pubspec.yaml`）。

### 4. APP 版本顯示
- 版本資訊由 `package_info_plus` 套件取得（`PackageInfo.fromPlatform()`）。
- 顯示格式：`{version} (build {buildNumber})`，例如 `1.0.0 (build 2)`。
- 版本資訊僅顯示，不可編輯。

### 5. 設定頁進入點
- 設定頁路由：`/settings`（`SettingsScreen`）。
- 由個人頁（`/profile`）中的「設定」選單項目導航進入。
- 設定頁包含兩個區塊：
  1. **語言**（多國語言選擇清單）
  2. **關於**（APP 版本資訊）

### 6. 未來擴充原則
- 新增語言時，同步更新 `supportedLocales` 陣列與 `localeDisplayNames` 對應表（均位於 `lib/providers/locale_provider.dart`）。
- 若未來引入 ARB 文字翻譯檔，需在 `pubspec.yaml` 的 `flutter.generate: true` 下設定 `flutter_intl` 或使用 `gen-l10n`，並依照對應語言標籤建立 `.arb` 資源檔。
- 後端 API 若需隨語言回傳多語系資料，可於請求 Header 加入 `Accept-Language: {locale_tag}`。
