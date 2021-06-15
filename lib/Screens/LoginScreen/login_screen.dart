import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lycread/Services/auth_service.dart';
import 'package:lycread/widgets/rounded_button.dart';
import 'package:lycread/widgets/rounded_phone_input_field.dart';
import 'package:lycread/widgets/rounded_text_input.dart';
import 'package:lycread/widgets/slide_right_route_animation.dart';
import '../../constants.dart';
import '../loading_screen.dart';
import 'components/background.dart';

class LoginScreen extends StatefulWidget {
  final String errors;
  LoginScreen({Key key, this.errors}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String phoneNo;
  String smsCode;
  String verificationId;
  String error = '';

  bool codeSent = false;
  bool loading = false;
  List<Color> colorizeColors = [
    footyColor,
    Color.fromRGBO(87, 245, 66, 1.0),
    Colors.greenAccent,
    Colors.blue,
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (widget.errors != null) {
      setState(() {
        error = widget.errors;
      });
    }
    return loading
        ? LoadingScreen()
        : Scaffold(
            backgroundColor: primaryColor,
            body: Background(
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.width * 0.5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'LycRead',
                          textScaleFactor: 1,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: whiteColor,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.5 - 280),
                      Container(
                        width: size.width * 0.9,
                        child: Card(
                          margin: EdgeInsets.all(5),
                          shadowColor: whiteColor,
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  AnimatedTextKit(
                                    totalRepeatCount: 1,
                                    animatedTexts: [
                                      TyperAnimatedText(
                                        'Добро пожаловать',
                                        textStyle: GoogleFonts.montserrat(
                                          textStyle: TextStyle(
                                            color: primaryColor,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 30,
                                    child: DefaultTextStyle(
                                      style: const TextStyle(
                                        color: primaryColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      child: AnimatedTextKit(
                                        repeatForever: true,
                                        animatedTexts: [
                                          RotateAnimatedText('Станьте автором'),
                                          RotateAnimatedText(
                                              'Станьте читателем'),
                                          RotateAnimatedText(
                                              'Станьте журналистом'),
                                          RotateAnimatedText(
                                              'Станьте блогером'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  !codeSent
                                      ? RoundedPhoneInputField(
                                          hintText: "Номер телефона",
                                          onChanged: (value) {
                                            this.phoneNo = value;
                                          },
                                        )
                                      : SizedBox(height: size.height * 0),
                                  codeSent
                                      ? RoundedTextInput(
                                          validator: (val) => val.length == 6
                                              ? null
                                              : 'Минимум 6 символов',
                                          hintText: "Введите код",
                                          type: TextInputType.number,
                                          onChanged: (value) {
                                            this.smsCode = value;
                                          },
                                        )
                                      : SizedBox(height: size.height * 0),
                                  codeSent
                                      ? SizedBox(height: 20)
                                      : SizedBox(height: size.height * 0),

                                  // RoundedPasswordField(
                                  //   hintText: "Password",
                                  //   onChanged: (value) {},
                                  // ),
                                  SizedBox(height: 20),
                                  RoundedButton(
                                    width: 0.5,
                                    ph: 45,
                                    text: codeSent ? 'GO' : 'ОТПРАВИТЬ КОД',
                                    press: () async {
                                      if (_formKey.currentState.validate()) {
                                        setState(() {
                                          loading = true;
                                        });
                                        if (codeSent) {
                                          dynamic res = await AuthService()
                                              .signInWithOTP(smsCode,
                                                  verificationId, context);
                                          if (res == null) {
                                            setState(() {
                                              error = 'Неверные данные';
                                              loading = false;
                                            });
                                          }
                                        } else {
                                          await verifyPhone(phoneNo);
                                        }
                                      }
                                    },
                                    color: darkPrimaryColor,
                                    textColor: whiteColor,
                                  ),
                                  codeSent
                                      ? SizedBox(height: 55)
                                      : SizedBox(height: size.height * 0),
                                  codeSent
                                      ? RoundedButton(
                                          width: 0.7,
                                          ph: 45,
                                          text: 'Поменять номер телефона',
                                          press: () {
                                            Navigator.push(
                                                context,
                                                SlideRightRoute(
                                                    page: LoginScreen()));
                                          },
                                          color: lightPrimaryColor,
                                          textColor: whiteColor,
                                        )
                                      : SizedBox(height: size.height * 0),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      error,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(
                                        size.width * 0.05,
                                        0,
                                        size.width * 0.05,
                                        0),
                                    child: Text(
                                      'Продолжая вы принимаете все правила пользования приложением и нашу Политику Конфиденциальности',
                                      textScaleFactor: 1,
                                      style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                          color: primaryColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w100,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // RoundedButton(
                                  //   text: 'REGISTER',
                                  //   press: () {
                                  //     Navigator.push(
                                  //         context, SlideRightRoute(page: RegisterScreen()));
                                  //   },
                                  //   color: lightPrimaryColor,
                                  //   textColor: darkPrimaryColor,
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 150),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified =
        (PhoneAuthCredential authResult) {
      AuthService().signIn(authResult, context);
      setState(() {
        loading = false;
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setState(() {
        this.error = '${authException.message}';
        this.loading = false;
      });
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.error = '';
        this.codeSent = true;
        this.loading = false;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
      setState(() {
        this.codeSent = false;
        this.loading = false;
        this.error = 'Время действия кода истекло';
      });
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 100),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }
}
