import 'src/app_lifecycle/app_lifecycle_test.dart' as app_lifecycle_test;
import 'src/games_services/score_test.dart' as score_test;
import 'src/loading_selection/loading_selection_screen_test.dart' as loading_selection_test;
import 'src/settings/settings_test.dart' as settings_test;
import 'src/user/user_test.dart' as user_test;
import 'src/user/user_manager_test.dart' as user_manager_test;
import 'src/widgets/responsive_widget_test.dart' as responsive_widget_test;

void main() {
  app_lifecycle_test.main();
  score_test.main();
  loading_selection_test.main();
  settings_test.main();
  user_test.main();
  user_manager_test.main();
  responsive_widget_test.main();
}