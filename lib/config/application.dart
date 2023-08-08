typedef TabbarChangeCallback = void Function(int selectIndex, [dynamic result]);

class Application {
  TabbarChangeCallback? tabbarChanged;

  static final Application _appl = Application._internal();
  factory Application() {
    return _appl;
  }
  Application._internal();
}

Application? appl = Application();
