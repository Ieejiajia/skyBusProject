import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skybus/mainscreen.dart';
import 'package:skybus/registerscreen.dart';
import 'package:skybus/user.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:async';



void main() => runApp(LoginScreen());
bool rememberMe = false;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double screenHeight;
  TextEditingController _emailEditingController = new TextEditingController();
  //String email = "";
  TextEditingController _passEditingController = new TextEditingController();
  //String password = "";
  String urlLogin = "http://smileylion.com/skyBus/php/login_user.php";
 bool isPasswordVisible = false;


  @override
  void initState() {
    super.initState();
    print("Hello i'm in INITSTATE");
    this.loadPref();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Stack(
            children: <Widget>[
              upperHalf(context),
              lowerHalf(context),
           
            ],
          )),
    );
  }

  Widget upperHalf(BuildContext context) {
   return Container(
     height: screenHeight / 2.6,
      child: Image.asset(
        'assets/image/login.PNG',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget lowerHalf(BuildContext context) {

        return Container(
          //height: screenHeight/2.5,
          margin: EdgeInsets.only(top: screenHeight / 3.0),
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: <Widget>[
              Card(
                elevation: 10,
                child: Container(
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextField(
                          controller: _emailEditingController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            icon: Icon(Icons.email),
                          )),
                      TextField(
                        controller: _passEditingController,
                        obscureText: !isPasswordVisible, 
                        decoration: InputDecoration(
                          labelText: 'Password',
                            suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    icon: Icon(Icons.vpn_key)),
                         
                        
                       
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Checkbox(
                            value: rememberMe,
                            onChanged: (bool value) {
                              _onRememberMeChanged(value);
                            },
                          ),
                          Text('Remember Me ',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            minWidth: 100,
                            height: 50,
                            child: Text('Login',
                            style: TextStyle(
                            fontSize: 19,  )),
                            color: Colors.blue,
                            textColor: Colors.white,
                            elevation: 10,
                            onPressed: this._userLogin,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Don't have an account? ", style: TextStyle(fontSize: 16.0)),
              GestureDetector(
                onTap: _registerUser,
                child: Text(
                  "Create Account",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 3,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Forgot your password ", style: TextStyle(fontSize: 16.0)),
              GestureDetector(
                onTap: _forgotPassword,
                child: Text(
                  "Reset Password",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

 void _userLogin() async{
    ProgressDialog pr = new ProgressDialog(context,
    type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Log in ...");
    pr.show();
    String email = _emailEditingController.text;
    String password = _passEditingController.text;

     http.post(urlLogin, body: {
      "email": email,
      "password": password,
    }).then((res) {
      var string = res.body;
      print(res.body);
      List userdata = string.split(",");
      if (userdata[0] == "success") {
        User _user = new User(
            name: userdata[1],
            email: email,
            password: password,
            phone: userdata[3],
            credit: userdata[4],
            datereg: userdata[5],
            quantity: userdata[6]
            );
            pr.dismiss();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => MainScreen( user: _user)));
        
      } else {
        pr.dismiss();
        Toast.show("Login failed", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }).catchError((err) {
      print(err);
      pr.dismiss();
    });
  
  }
     

  void _registerUser() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => RegisterScreen()));
  }

  void _forgotPassword() {
    TextEditingController phoneController = TextEditingController();
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Forgot Password?"),
          content: new Container(
            height: 95,
            child: Column(
              children: <Widget>[
                Text(
                  "Enter your recovery email",
                ),
                TextField(
                    decoration: InputDecoration(
                  labelText: 'Email',
                  icon: Icon(Icons.email),
                ))
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                print(
                  phoneController.text,
                );
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onRememberMeChanged(bool newValue) => setState(() {
        rememberMe = newValue;
        print(rememberMe);
        if (rememberMe) {
          savepref(true);
        } else {
          savepref(false);
        }
      });

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              MaterialButton(
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Text("Exit")),
              MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("Cancel")),
            ],
          ),
        ) ??
        false;
  }

  void loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = (prefs.getString('email'))??'';
    String password = (prefs.getString('pass'))??'';
    if (email.length > 1) {
      setState(() {
        _emailEditingController.text = email;
        _passEditingController.text = password;
        rememberMe = true;
      });
    }
  }

  void savepref(bool value) async {
    String email = _emailEditingController.text;
    String password = _passEditingController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      //save preference
      await prefs.setString('email', email);
      await prefs.setString('pass', password);
      Toast.show("Preferences have been saved", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    } else {
      //delete preference
      await prefs.setString('email', '');
      await prefs.setString('pass', '');
      setState(() {
        _emailEditingController.text = '';
        _passEditingController.text = '';
        rememberMe = false;
      });
      Toast.show("Preferences have removed", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }
}