import 'dart:io';
import 'package:flutter/material.dart';
import 'package:md2_tab_indicator/md2_tab_indicator.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/services.dart';
import '../shared/shared.dart';
import 'pages.dart';

class HomePage extends StatefulWidget {
  static TabViewPage favoritesPage = TabViewPage("favorites.json", true);
  static TabViewPage recentlyAddedPage = TabViewPage("recently_added.json", false);

  static var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  TabController _tabController;

  AnimationController _rotationController1;
  AnimationController _rotationController2;
  int _tabIndex = 0;
  bool _tabBarWasAnimated = false;

  _tabOnChange() {
    if (_tabIndex != _tabController.index) {
      if (_tabController.index == 0) {
        _rotationController1.forward(from: .0);
      } else if (_tabController.index == 1) {
        _rotationController2.forward(from: .0);
      }
      setState(() {
        _tabIndex = _tabController.index;
        _tabBarWasAnimated = true;
      });
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_tabOnChange);
    _rotationController1 = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _rotationController2 = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    getApplicationDocumentsDirectory().then((Directory dir) {
      setState(() {
        HomePage.favoritesPage.dir = dir;
        HomePage.recentlyAddedPage.dir = dir;
        HomePage.favoritesPage.jsonFile = File(HomePage.favoritesPage.dir.path + "/" + HomePage.favoritesPage.jsonFileName);
        HomePage.recentlyAddedPage.jsonFile = File(HomePage.recentlyAddedPage.dir.path + "/" + HomePage.recentlyAddedPage.jsonFileName);
        HomePage.favoritesPage.jsonFileExists = HomePage.favoritesPage.jsonFile.existsSync();
        HomePage.recentlyAddedPage.jsonFileExists = HomePage.recentlyAddedPage.jsonFile.existsSync();
        if (HomePage.favoritesPage.jsonFileExists) {
          HomePage.favoritesPage.connections = [];
          HomePage.favoritesPage.connections.addAll(HomePage.favoritesPage.getConnectionsFromJson());
        }
        if (HomePage.recentlyAddedPage.jsonFileExists) {
          HomePage.recentlyAddedPage.connections = [];
          HomePage.recentlyAddedPage.connections.addAll(HomePage.recentlyAddedPage.getConnectionsFromJson());
        }
      });
    });
    SettingsVariables.initState();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<CustomTheme>(context).setThemeValue(await Provider.of<CustomTheme>(context).getThemeValue());
    });
    return Scaffold(
      key: HomePage.scaffoldKey,
      appBar: AppBar(
        elevation: 2.8,
        backgroundColor: Theme.of(context).bottomAppBarColor,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(18.0),
          child: TabBar(
            indicator: MD2Indicator(
              indicatorSize: MD2IndicatorSize.normal,
              indicatorHeight: 3.4,
              indicatorColor: Theme.of(context).accentColor,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2.0,
            labelColor: Theme.of(context).accentColor,
            unselectedLabelColor: Theme.of(context).brightness == Brightness.light ? Colors.grey[600] : Colors.grey[400],
            labelStyle: TextStyle(fontFamily: SettingsVariables.accentFont, fontWeight: FontWeight.w600, fontSize: 14.0),
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                icon: RotationTransition(
                  turns: Tween(begin: .0, end: .2).animate(_rotationController1),
                  child: Icon(Icons.star_border),
                ),
                text: "Favorites",
              ),
              Tab(
                icon: RotationTransition(
                  turns: _tabBarWasAnimated
                      ? Tween(begin: -.5, end: -1.0).animate(_rotationController2)
                      : Tween(begin: .0, end: -1.0).animate(_rotationController2),
                  child: Padding(
                    padding: EdgeInsets.only(right: 2.0),
                    child: Icon(Icons.restore),
                  ),
                ),
                text: "Recently added",
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 6.0,
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 55.0,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: CustomIconButton(
                  icon: Icon(OMIcons.settings),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage())),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                width: 1.0,
                margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                color: Theme.of(context).dividerColor,
              ),
              InkWell(
                borderRadius: BorderRadius.circular(40.0),
                child: Padding(
                  padding: EdgeInsets.only(left: 14.0, right: 16.0, top: 8.0, bottom: 8.0),
                  child: Row(
                    children: <Widget>[
                      Image.asset("assets/app_icon.png", width: 27.0),
                      SizedBox(width: 8.0),
                      Text(
                        "RemoteFiles",
                        style: TextStyle(fontFamily: SettingsVariables.accentFont, fontWeight: FontWeight.w600, fontSize: 17.0),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();
                  String version = packageInfo.version;
                  customShowDialog(
                    context: context,
                    builder: (context) {
                      return CustomAlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 6.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18.0),
                                color: Colors.white,
                                boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, .2), blurRadius: 2.0, offset: Offset(.0, .8))],
                              ),
                              width: 90.0,
                              height: 90.0,
                              child: Padding(
                                padding: EdgeInsets.all(15.79),
                                child: Image.asset("assets/app_icon.png"),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 18.0, bottom: 6.0),
                              child: Text(
                                "RemoteFiles",
                                style: TextStyle(fontWeight: FontWeight.w600, fontFamily: SettingsVariables.accentFont, fontSize: 19.0),
                              ),
                            ),
                            Text(
                              "Version: $version",
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.6, color: Theme.of(context).hintColor),
                            ),
                            Divider(height: 30.0),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: RaisedButton(
                                    color: Provider.of<CustomTheme>(context).isLightTheme() ? Color.fromRGBO(235, 240, 255, 1) : Color.fromRGBO(84, 88, 92, 1),
                                    splashColor:
                                        Provider.of<CustomTheme>(context).isLightTheme() ? Color.fromRGBO(215, 225, 250, 1) : Color.fromRGBO(100, 104, 110, 1),
                                    elevation: .0,
                                    highlightElevation: 2.8,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: .8),
                                      child: Text(
                                        "GitHub",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.body1.color, fontSize: 13.6, fontFamily: "Roboto"),
                                      ),
                                    ),
                                    onPressed: () async {
                                      const url = "https://github.com/niklas-8/RemoteFiles";
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        Navigator.pop(context);
                                        HomePage.scaffoldKey.currentState.showSnackBar(
                                          SnackBar(
                                            content: Text("Could not launch $url"),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 14.0,
                                ),
                                Expanded(
                                  child: RaisedButton(
                                    color: Provider.of<CustomTheme>(context).isLightTheme() ? Color.fromRGBO(235, 240, 255, 1) : Color.fromRGBO(84, 88, 92, 1),
                                    splashColor:
                                        Provider.of<CustomTheme>(context).isLightTheme() ? Color.fromRGBO(215, 225, 250, 1) : Color.fromRGBO(100, 104, 110, 1),
                                    elevation: .0,
                                    highlightElevation: 2.8,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: .8),
                                      child: Text(
                                        "PlayStore",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.body1.color, fontSize: 13.6, fontFamily: "Roboto"),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      HomePage.scaffoldKey.currentState.showSnackBar(
                                        SnackBar(
                                          content: Text("App is not yet available in the Google PlayStore"),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: "fab",
        elevation: 4.0,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => EditConnectionPage(isNew: true)));
        },
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            HomePage.favoritesPage,
            HomePage.recentlyAddedPage,
          ],
        ),
      ),
    );
  }
}
