import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum ToastKind { success, warning, danger, info }

class ToastAction {
  final String label;
  final VoidCallback onTap;
  ToastAction(this.label, this.onTap);
}

class _ToastData {
  final ToastKind kind;
  final String title;
  final String? message;
  final ToastAction? action;
  final OverlayEntry entry;

  _ToastData({
    required this.kind,
    required this.title,
    this.message,
    this.action,
    required this.entry,
  });
}

class _ToastOverlayState extends State<ToastOverlay> {
  final List<_ToastData> _toasts = [];

  static _ToastOverlayState? _instance;

  @override
  void initState() {
    super.initState();
    _instance = this;
  }

  @override
  void dispose() {
    _instance = null;
    super.dispose();
  }

  void show({
    required BuildContext context,
    required ToastKind kind,
    required String title,
    String? message,
    ToastAction? action,
  }) {
    // Create a placeholder, then reassign after entry is built
    _ToastData? dataRef;
    final entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        data: dataRef!,
        onDismiss: () => _remove(dataRef!),
      ),
    );
    final data = _ToastData(
      kind: kind,
      title: title,
      message: message,
      action: action,
      entry: entry,
    );
    dataRef = data;

    setState(() => _toasts.add(data));
    Overlay.of(context).insert(entry);

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _remove(data);
    });
  }

  void _remove(_ToastData data) {
    if (!_toasts.contains(data)) return;
    data.entry.remove();
    if (mounted) setState(() => _toasts.remove(data));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ToastOverlay extends StatefulWidget {
  final Widget child;

  const ToastOverlay({super.key, required this.child});

  @override
  State<ToastOverlay> createState() => _ToastOverlayState();
}

class Toaster {
  static void show(
    BuildContext context, {
    required ToastKind kind,
    required String title,
    String? message,
    ToastAction? action,
  }) {
    _ToastOverlayState._instance?.show(
      context: context,
      kind: kind,
      title: title,
      message: message,
      action: action,
    );
  }

  static void success(BuildContext context, String title, {String? message, ToastAction? action}) =>
      show(context, kind: ToastKind.success, title: title, message: message, action: action);

  static void warning(BuildContext context, String title, {String? message, ToastAction? action}) =>
      show(context, kind: ToastKind.warning, title: title, message: message, action: action);

  static void danger(BuildContext context, String title, {String? message, ToastAction? action}) =>
      show(context, kind: ToastKind.danger, title: title, message: message, action: action);

  static void info(BuildContext context, String title, {String? message, ToastAction? action}) =>
      show(context, kind: ToastKind.info, title: title, message: message, action: action);
}

class _ToastWidget extends StatefulWidget {
  final _ToastData data;
  final VoidCallback onDismiss;

  const _ToastWidget({required this.data, required this.onDismiss});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = BLColors.of(context);
    final d = widget.data;

    Color iconColor;
    IconData iconData;

    switch (d.kind) {
      case ToastKind.success:
        iconColor = c.moss;
        iconData = Icons.check_circle_outline;
        break;
      case ToastKind.warning:
        iconColor = c.gold;
        iconData = Icons.warning_amber_outlined;
        break;
      case ToastKind.danger:
        iconColor = c.berry;
        iconData = Icons.error_outline;
        break;
      case ToastKind.info:
        iconColor = c.muted;
        iconData = Icons.info_outline;
        break;
    }

    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: c.bg2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.rule, width: 1),
            ),
            child: Row(
              children: [
                Icon(iconData, color: iconColor, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        d.title,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: c.ink,
                          letterSpacing: -0.07,
                        ),
                      ),
                      if (d.message != null)
                        Text(
                          d.message!,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: c.muted,
                            letterSpacing: -0.06,
                          ),
                        ),
                    ],
                  ),
                ),
                if (d.action != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      d.action!.onTap();
                      widget.onDismiss();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: c.coral,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Text(d.action!.label),
                  ),
                ],
                IconButton(
                  icon: Icon(Icons.close, size: 16, color: c.muted),
                  onPressed: widget.onDismiss,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
