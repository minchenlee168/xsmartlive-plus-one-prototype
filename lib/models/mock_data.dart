import 'live_stream.dart';
import 'notification_item.dart';
import 'product.dart';
import 'user.dart';

class MockData {
  MockData._();

  static const User currentUser = User(
    memberId: 001,
    name: '購物達人小花',
    email: 'xiaohua@example.com',
    level: 'Lv.5',
    points: 2580,
    isVip: true,
  );

  static const List<LiveStream> liveStreams = [
    LiveStream(
      id: 'live_001',
      title: '夏季新品大促銷！超值特惠，限時搶購中',
      streamer: '美妝達人小芸',
      thumbnail: '',
      viewers: 12580,
      likes: 8640,
      isLive: true,
      streamUrl: 'https://example.com/live/001',
    ),
    LiveStream(
      id: 'live_002',
      title: '品牌週年慶回顧直播',
      streamer: '時尚主播Coco',
      thumbnail: '',
      viewers: 9320,
      likes: 4210,
      isLive: false,
      startTime: '2026-03-28 20:00',
    ),
    LiveStream(
      id: 'live_003',
      title: '居家好物分享，北歐風格布置大揭秘',
      streamer: '生活達人阿宅',
      thumbnail: '',
      viewers: 5430,
      likes: 2800,
      isLive: false,
      startTime: '2026-03-27 19:00',
    ),
    LiveStream(
      id: 'live_004',
      title: '春夏穿搭指南，平價也能穿出精緻感',
      streamer: '穿搭女王Lily',
      thumbnail: '',
      viewers: 7800,
      likes: 5100,
      isLive: false,
      startTime: '2026-03-26 21:00',
    ),
    LiveStream(
      id: 'live_005',
      title: '美食開箱 × 廚房神器推薦',
      streamer: '美食家Tony',
      thumbnail: '',
      viewers: 3200,
      likes: 1560,
      isLive: false,
      startTime: '2026-03-25 18:30',
    ),
  ];

  static const List<Product> products = [
    Product(
      id: 'p001',
      name: '韓系小香風外套',
      price: 299.0,
      originalPrice: 599.0,
      image: '',
      category: '女裝',
      rating: 4.8,
      sales: 1280,
      isHot: true,
    ),
    Product(
      id: 'p002',
      name: '厚底增高小白鞋',
      price: 199.0,
      originalPrice: 399.0,
      image: '',
      category: '鞋子',
      rating: 4.6,
      sales: 860,
      isHot: true,
    ),
    Product(
      id: 'p003',
      name: '珍珠鍊條包',
      price: 159.0,
      image: '',
      category: '配件',
      rating: 4.5,
      sales: 520,
    ),
    Product(
      id: 'p004',
      name: '玻尿酸保濕精華',
      price: 89.0,
      originalPrice: 188.0,
      image: '',
      category: '美妝',
      rating: 4.9,
      sales: 2100,
    ),
    Product(
      id: 'p005',
      name: '北歐風香薰蠟燭',
      price: 45.0,
      image: '',
      category: '居家',
      rating: 4.7,
      sales: 430,
    ),
    Product(
      id: 'p006',
      name: '運動瑜伽套裝',
      price: 189.0,
      originalPrice: 280.0,
      image: '',
      category: '運動',
      rating: 4.4,
      sales: 310,
    ),
    Product(
      id: 'p007',
      name: '復古牛仔外套',
      price: 259.0,
      image: '',
      category: '女裝',
      rating: 4.6,
      sales: 720,
      isHot: true,
    ),
    Product(
      id: 'p008',
      name: '水鑽髮夾套組',
      price: 39.0,
      image: '',
      category: '配件',
      rating: 4.3,
      sales: 1560,
    ),
  ];

  static const List<NotificationItem> notifications = [
    NotificationItem(
      id: 'n001',
      type: NotificationType.live,
      title: '美妝達人開播啦！',
      message: '你關注的主播正在直播，快來搶購限時優惠',
      time: '3分鐘前',
      isRead: false,
    ),
    NotificationItem(
      id: 'n002',
      type: NotificationType.cart,
      title: '購物車商品即將售罄',
      message: '你的購物車中「韓系小香風外套」庫存緊張',
      time: '1小時前',
      isRead: false,
    ),
    NotificationItem(
      id: 'n003',
      type: NotificationType.favorite,
      title: '收藏商品降價了！',
      message: '你收藏的「玻尿酸保濕精華」降價至 89 元',
      time: '2小時前',
      isRead: true,
    ),
    NotificationItem(
      id: 'n004',
      type: NotificationType.promotion,
      title: '限時特賣活動開始',
      message: '全場滿 300 減 50，今天只剩 3 小時！',
      time: '5小時前',
      isRead: true,
    ),
  ];

  static const List<LiveComment> liveComments = [
    LiveComment(
      id: 'c001',
      username: '小紅花',
      message: '好漂亮啊！請問有沒有其他顏色？',
      time: '14:28',
    ),
    LiveComment(
      id: 'c002',
      username: '購物達人99',
      message: '已下單！期待收到',
      time: '14:29',
    ),
    LiveComment(
      id: 'c003',
      username: '時尚小姐姐',
      message: '這個價格也太划算了吧，比實體店便宜一半',
      time: '14:29',
    ),
    LiveComment(
      id: 'c004',
      username: 'MeiMei520',
      message: '主播能穿給我們看看嗎？',
      time: '14:30',
    ),
    LiveComment(
      id: 'c005',
      username: '開心購物每一天',
      message: '已經是第三次回購了，質量真的很好',
      time: '14:30',
    ),
    LiveComment(
      id: 'c006',
      username: '愛美的小白',
      message: '這款適合夏天嗎？會不會太熱',
      time: '14:31',
    ),
    LiveComment(
      id: 'c007',
      username: 'JoJo娃娃',
      message: '剛剛加入購物車了！主播繼續介紹',
      time: '14:31',
    ),
    LiveComment(
      id: 'c008',
      username: '寶媽也愛美',
      message: '尺碼偏大還是偏小？',
      time: '14:32',
    ),
    LiveComment(
      id: 'c009',
      username: '好物獵人',
      message: '真的是今年看過最划算的一次直播！',
      time: '14:32',
    ),
    LiveComment(
      id: 'c010',
      username: '狂熱購物魂',
      message: '庫存還剩多少？快搶！',
      time: '14:33',
    ),
  ];
}
