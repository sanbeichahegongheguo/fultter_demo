import 'package:flustars/flustars.dart';
import 'package:flutter/widgets.dart';
import 'package:yondor_whiteboard/whiteboard.dart';

class DeviceInputsMenu extends StatelessWidget {
  final WhiteboardController whiteboardController;
  final Appliance appliance;
  const DeviceInputsMenu({Key key, this.whiteboardController, this.appliance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        getDeviceInputs(appliance: Appliance.pencil, isActive: appliance == Appliance.pencil),
        SizedBox(height: 2),
        getDeviceInputs(appliance: Appliance.eraser, isActive: appliance == Appliance.eraser),
        SizedBox(height: 15),
      ],
    );
  }

  getDeviceInputs({Appliance appliance, bool isActive = false}) {
    String image = appliance.toString().replaceAll("Appliance.", "");
    return GestureDetector(
      onTap: isActive ? () => whiteboardController.undo() : () => whiteboardController.setAppliance(appliance),
      child: Container(
        height: ScreenUtil.getInstance().getWidth(20),
        width: ScreenUtil.getInstance().getWidth(20),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/live/${image}_${isActive ? "on" : "normal"}.png"),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
