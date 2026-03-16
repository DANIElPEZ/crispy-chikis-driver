import 'package:crispychikisdriver/theme/color/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crispychikisdriver/components/button.dart';
import 'package:crispychikisdriver/components/textfield.dart';
import 'package:crispychikisdriver/provider/provider.dart';
import 'package:crispychikisdriver/components/snack_bar_message.dart';
import 'package:crispychikisdriver/utils/utils.dart';
import 'package:crispychikisdriver/views/NavigationView.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController orderIdController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  List<String> countryCode = [
    '+57 ', //'Online'
  ];
  String dropDownValue = '+57 ';

  @override
  void dispose() {
    super.dispose();
    orderIdController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              color: colorsPalete['dark blue'],
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.19,
            ),
            Flexible(
              child: Container(
                color: colorsPalete['orange'],
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
          child: Column(
            children: [
              Text(
                'Conductor de Crispy Chikis',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 22,
                  color: colorsPalete['white'],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    width: 3,
                    color: colorsPalete['dark brown']!,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset('assets/logo.jpeg', width: 150),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: orderIdController,
                        labelText: 'Id orden',
                        placeHolder: '97',
                      ),
                      SizedBox(height: 10),
                      Text('Telefono',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colorsPalete['white'])),
                      SizedBox(height: 5),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                width: 90,
                                height: 55,
                                decoration: BoxDecoration(
                                    color: colorsPalete['pink'],
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                        isExpanded: true,
                                        dropdownColor: colorsPalete['pink'],
                                        value: dropDownValue,
                                        icon: Icon(Icons.arrow_drop_down,
                                            color: colorsPalete['dark brown']),
                                        items: countryCode
                                            .map<DropdownMenuItem<String>>(
                                                (String value) => DropdownMenuItem(
                                                value: value,
                                                child: Text(value,
                                                    style: GoogleFonts.nunito(
                                                        fontSize: 21,
                                                        fontWeight: FontWeight.w600,
                                                        color: colorsPalete[
                                                        'dark brown']))))
                                            .toList(),
                                        onChanged: (String? value) =>
                                            setState(() => dropDownValue = value!)))),
                            SizedBox(width: 10),
                            Expanded(
                              child: CustomTextField(
                                  controller: phoneController,
                                  showText: false,
                                  placeHolder: '3112345678'),
                            ),
                          ]
                      ),
                      SizedBox(height: 10),
                      Consumer<crispyDriverProvider>(
                        builder: (context, provider, child) {
                          if (!provider.isLive) {
                            return CustomButton(
                              text: 'Iniciar',
                              onPressed: () {
                                if (sanitizeOrderId(orderIdController.text) &&
                                    sanitizePhone(phoneController.text)) {
                                  provider.startStreamUpdateLoc(
                                    orderIdController.text,
                                    dropDownValue+phoneController.text,
                                  );
                                } else {
                                  snackBarMessage(
                                    ScaffoldMessenger.of(context),
                                    'Datos no validos',
                                  );
                                }
                              },
                            );
                          }
                          return Column(
                            children: [
                              CustomButton(text: 'Navegar', onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            navigationView()));
                              }),
                              SizedBox(height: 10),
                              CustomButton(
                                text: 'Parar',
                                onPressed: () => provider.stopStreamLoc(),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
