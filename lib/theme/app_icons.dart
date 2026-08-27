import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Central icon mapping from the prototype's `src/icons.jsx` names to
/// Flutter Material/Cupertino icon equivalents. Keeps every screen using
/// consistent iconography that mirrors the React prototype.
///
/// Usage:
/// ```dart
/// Icon(AppIcons.home)             // outlined
/// Icon(AppIcons.homeFilled)       // solid
/// ```
///
/// When a prototype name has no exact Material equivalent, the closest
/// semantic match is used and noted in a comment. Brand icons (apple,
/// line) point to Material/Cupertino built-ins; per-merchant SVG/PNG
/// assets in `assets/icons/` should be preferred when added.
class AppIcons {
  AppIcons._();

  // ── Bottom navigation ───────────────────────────────────────────────
  // Mapping derived from prototype `src/icons.jsx`:
  //   prototype `live`  = concentric circles + broadcast arc waves
  //                       → closest Material match: `podcasts`
  //   prototype `shop`  = bag with rounded handle (not a storefront)
  //                       → `shopping_bag_outlined`
  //   prototype `cart`  = trolley with two wheel circles
  //                       → `shopping_cart_outlined`
  //   prototype `me`    = person head + body arc
  //                       → `person_outline`
  //   prototype `home`  = house outline
  //                       → `home_outlined`
  static const IconData home = Icons.home_outlined;
  static const IconData homeFilled = Icons.home;
  static const IconData live = Icons.podcasts;
  static const IconData liveFilled = Icons.podcasts;
  static const IconData shop = Icons.shopping_bag_outlined;
  static const IconData shopFilled = Icons.shopping_bag;
  static const IconData cart = Icons.shopping_cart_outlined;
  static const IconData cartFilled = Icons.shopping_cart;
  static const IconData me = Icons.person_outline;
  static const IconData meFilled = Icons.person;

  // ── Common actions ──────────────────────────────────────────────────
  static const IconData search = Icons.search;
  static const IconData back = Icons.arrow_back_ios_new;
  static const IconData close = Icons.close;
  static const IconData chevron = Icons.chevron_right;
  static const IconData menu = Icons.menu;
  static const IconData arrowRight = Icons.arrow_forward;

  // ── Quantity / selection ────────────────────────────────────────────
  static const IconData plus = Icons.add;
  static const IconData minus = Icons.remove;
  static const IconData check = Icons.check;
  static const IconData checkCircle = Icons.check_circle_outline;
  static const IconData checkCircleFilled = Icons.check_circle;

  // ── Engagement / favorites ──────────────────────────────────────────
  static const IconData heart = Icons.favorite_border;
  static const IconData heartFilled = Icons.favorite;
  static const IconData star = Icons.star;
  static const IconData share = Icons.ios_share;
  static const IconData gift = Icons.card_giftcard;
  static const IconData sparkle = Icons.auto_awesome;
  static const IconData fire = Icons.local_fire_department;

  // ── Notifications / info ────────────────────────────────────────────
  static const IconData bell = Icons.notifications_none_outlined;
  static const IconData info = Icons.info_outline;
  static const IconData globe = Icons.language;

  // ── Media controls ──────────────────────────────────────────────────
  static const IconData play = Icons.play_arrow;
  static const IconData pause = Icons.pause;
  static const IconData mute = Icons.volume_off_outlined;
  static const IconData unmute = Icons.volume_up_outlined;
  static const IconData mic = Icons.mic_none_outlined;

  // ── Commerce ────────────────────────────────────────────────────────
  static const IconData tag = Icons.local_offer_outlined;
  static const IconData coupon = Icons.confirmation_number_outlined;
  static const IconData wallet = Icons.account_balance_wallet_outlined;
  static const IconData card = Icons.credit_card_outlined;
  static const IconData truck = Icons.local_shipping_outlined;
  static const IconData box = Icons.inventory_2_outlined;
  static const IconData shoppingBag = Icons.shopping_bag_outlined;
  static const IconData addCart = Icons.add_shopping_cart;

  // ── Comms ───────────────────────────────────────────────────────────
  static const IconData send = Icons.send;
  static const IconData comment = Icons.chat_bubble_outline;
  static const IconData mail = Icons.mail_outline;

  // ── Auth / form ─────────────────────────────────────────────────────
  static const IconData eye = Icons.visibility_outlined;
  static const IconData eyeOff = Icons.visibility_off_outlined;
  static const IconData lock = Icons.lock_outline;
  static const IconData face = Icons.tag_faces;

  // ── Brand (closest Cupertino/Material approximations) ───────────────
  // Real OAuth providers should use brand assets in assets/icons/.
  static const IconData apple = CupertinoIcons.app_badge;
  static const IconData line = Icons.chat;
}
