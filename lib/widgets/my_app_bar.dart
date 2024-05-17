import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../back_end/api.dart';
import '../widgets/empty_widget.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import 'notification.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Helper hp;
  final bool? centerTitle;
  final Color? shadowColor;
  final ShapeBorder? shape;
  final PreferredSizeWidget? bottom;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget? leading, flexibleSpace, title;
  final IconThemeData? iconTheme, actionsIconTheme;
  final TextStyle? toolbarTextStyle, titleTextStyle;
  final double? elevation, titleSpacing, toolbarHeight;
  const MyAppBar(this.hp, this.scaffoldKey,
      {Key? key,
      this.title,
      this.shape,
      this.bottom,
      this.leading,
      this.elevation,
      this.iconTheme,
      this.centerTitle,
      this.shadowColor,
      this.titleSpacing,
      this.flexibleSpace,
      this.toolbarHeight,
      this.titleTextStyle,
      this.actionsIconTheme,
      this.toolbarTextStyle})
      : super(key: key);

  @override
  MyAppBarState createState() => MyAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize =>
      Size.fromHeight(hp.radius / (bottom == null ? 100 : 10.99511627776));
}

class MyAppBarState extends State<MyAppBar> {
  Helper get hp => Helper.of(context);

  Widget dialogueBuilder(
      BuildContext context, Animation<double> start, Animation<double> end) {
    log(start.status);
    log(end.status);
    return const ShowNotifications();
  }

  Widget imageBuilder(BuildContext context, User user, Widget? child) {
    final hpi = Helper.of(context);
    try {
      return IconButton(
          onPressed: () {
            log(hpi);
          },
          icon: CircleAvatar(
              backgroundImage: NetworkImage(user.image),
              onBackgroundImageError: onImageError));
    } catch (e) {
      sendAppLog(e);

      return child ?? const EmptyWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: widget.title,
        shape: widget.shape,
        bottom: widget.bottom,
        elevation: widget.elevation,
        iconTheme: widget.iconTheme,
        centerTitle: widget.centerTitle,
        shadowColor: widget.shadowColor,
        titleSpacing: widget.titleSpacing,
        flexibleSpace: widget.flexibleSpace,
        toolbarHeight: widget.toolbarHeight,
        titleTextStyle: widget.titleTextStyle,
        toolbarTextStyle: widget.toolbarTextStyle,
        actionsIconTheme: widget.actionsIconTheme,
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        actions: [
          IconButton(
              onPressed: () async {
                final p = await showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    pageBuilder: dialogueBuilder,
                    barrierLabel: 'Notifications_Dialogue');
                log(p);
              },
              icon: const Icon(Icons.notifications),
              tooltip: 'notification'),
          ValueListenableBuilder<User>(
              builder: imageBuilder,
              valueListenable: currentUser,
              child:
                  IconButton(onPressed: () {}, icon: const Icon(Icons.person))),
          IconButton(
              onPressed: () {
                try {
                  final st = widget.scaffoldKey.currentState;
                  (st?.hasEndDrawer ?? false)
                      ? st?.openEndDrawer()
                      : doNothing();
                } catch (e) {
                  sendAppLog(e);
                  hp.sct.hasEndDrawer ? hp.sct.openEndDrawer() : doNothing();
                }
              },
              icon: const Icon(Icons.chat_bubble),
              tooltip: 'chat'),
          IconButton(
              tooltip: 'sfsdf',
              onPressed: hp.logout,
              icon: Image.asset('${assetImagePath}logout.png'))
        ],
        leading: widget.leading);
  }
}
