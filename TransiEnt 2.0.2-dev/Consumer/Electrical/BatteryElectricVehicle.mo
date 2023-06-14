within TransiEnt.Consumer.Electrical;
model BatteryElectricVehicle

//________________________________________________________________________________//
// Component of the TransiEnt Library, version: 2.0.2                             //
//                                                                                //
// Licensed by Hamburg University of Technology under the 3-BSD-clause.           //
// Copyright 2021, Hamburg University of Technology.                              //
//________________________________________________________________________________//
//                                                                                //
// TransiEnt.EE, ResiliEntEE, IntegraNet and IntegraNet II are research projects  //
// supported by the German Federal Ministry of Economics and Energy               //
// (FKZ 03ET4003, 03ET4048, 0324027 and 03EI1008).                                //
// The TransiEnt Library research team consists of the following project partners://
// Institute of Engineering Thermodynamics (Hamburg University of Technology),    //
// Institute of Energy Systems (Hamburg University of Technology),                //
// Institute of Electrical Power and Energy Technology                            //
// (Hamburg University of Technology)                                             //
// Fraunhofer Institute for Environmental, Safety, and Energy Technology UMSICHT, //
// Gas- und Wärme-Institut Essen                                                  //
// and                                                                            //
// XRG Simulation GmbH (Hamburg, Germany).                                        //
//________________________________________________________________________________//

  outer TransiEnt.SimCenter simCenter;
  extends TransiEnt.Basics.Icons.Model;

  // _____________________________________________
  //
  //              Parameters
  // _____________________________________________

  parameter String inputDataType="carDistance" "Choose data type format: 'Distance travelled' or 'SoC at the arrival back home'"
    annotation (Dialog(group="Data"), choices(__Dymola_radioButtons=true,
                choice="carDistance",
                choice="SoC"));

  parameter Real carEfficiency=18  "[kWh/100km] Average electricity use per kilometer"    annotation (Dialog(group=
          "Electric car", enable=inputDataType == "carDistance"));

  parameter SI.Energy Bat_Capacity(displayUnit="kWh")=252000000 "Battery capacity"  annotation (Dialog(group=
          "Electric car"));
  parameter Real Bat_SOCStart=0.7;
  parameter SI.Power P_max_car_drive=200000 "Maximum driving power"  annotation (Dialog(group=
          "Electric car", enable=inputDataType == "carDistance"));
  parameter SI.Power P_max_car_charge(displayUnit="kW")=22000 "Maximum charging power" annotation (Dialog(group=
          "Electric car", enable=inputDataType == "carDistance"));

  parameter String relativepath_carDistance="emobility/CarDistance.txt"
    "Path relative to source directory for car distance table"  annotation (Dialog(group="Data",
        enable=inputDataType == "carDistance"));
  parameter String relativepath_carLocation="emobility/CarLocation.txt"
    "Path relative to source directory for car location table"  annotation (Dialog(group="Data",
        enable=inputDataType == "carDistance"));
  parameter Real timeStepSize(unit="min") = 1
    "Time step size of distance travelled"   annotation (Dialog(group="Data",
        enable=inputDataType == "carDistance"));

  parameter Integer column_Location=1 "Table column for car location data" annotation (Dialog(group="Data",
        enable=inputDataType == "carDistance"));
  parameter Integer column_Distance=1 "Table column for car distance data" annotation (Dialog(group="Data",
        enable=inputDataType == "carDistance"));

  parameter Modelica.Units.SI.Power P_chargingStation(displayUnit="kW") = 11000 "Charging power of the charging station" annotation (Dialog(group="Charging station"));
  parameter Boolean ChargeAtWork=true annotation (Dialog(group="Charging - Select if car ist charged at different locations than home. Charging power will not be accounted for but will reduce charging load at home. Locations need to be specified in Input table", joinNext=true,
      enable=inputDataType == "carDistance"),                                                                                                                                                                                                        choices(checkBox=true));
  parameter Boolean ChargeAtSchool=false annotation (Dialog(group="Charging - Select if car ist charged at different locations than home. Charging power will not be accounted for but will reduce charging load at home. Locations need to be specified in Input table", joinNext=true,
      enable=inputDataType == "carDistance"),choices(checkBox=true));
  parameter Boolean ChargeAtShopping=false annotation (Dialog(group="Charging - Select if car ist charged at different locations than home. Charging power will not be accounted for but will reduce charging load at home. Locations need to be specified in Input table", joinNext=true,
      enable=inputDataType == "carDistance"),choices(checkBox=true));
  parameter Boolean ChargeAtOther=false annotation (Dialog(group="Charging - Select if car ist charged at different locations than home. Charging power will not be accounted for but will reduce charging load at home. Locations need to be specified in Input table"),
      enable=inputDataType == "carDistance",choices(checkBox=true));

  parameter Real SOCLimit=1 "Maximum battery level";

  parameter Boolean useExternalControl = false "Checkbox to enable external load control"  annotation (
      Evaluate=true,
      HideResult=true,
      choices(checkBox=true),
      Dialog(group="Load Management"));
  parameter String controlType = "limit" "Load control method" annotation (
       Dialog(enable=useExternalControl, group="Load Management"),
       choices(choice="limit",
               choice="proportional"));


  // _____________________________________________
  //
  //              Variables
  // _____________________________________________

   //Real carLoc "Number representing car location (1=Home)";
  // Real derLoc "Derivative of car location";
  // Boolean carHome "True, if car is parked at home";
  // Modelica.Units.SI.Power P_driving "Current consumption of driving car";

  Real SoC=vehicleBattery.SOC.y;
  // _____________________________________________
  //
  //              Complex Components
  // _____________________________________________

  TransiEnt.Components.Boundaries.Electrical.ApparentPower.ApparentPower powerToGrid(
    useInputConnectorQ=false,
    Q_el_set_const=0,
    useCosPhi=false)
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={62,-78})));

  TransiEnt.Storage.Electrical.LithiumIonBattery vehicleBattery(
    use_PowerRateLimiter=false, StorageModelParams=
        TransiEnt.Storage.Electrical.Specifications.LithiumIon(
        E_start=Bat_SOCStart*Bat_Capacity,
        E_max=Bat_Capacity,
        E_min=0,
        P_max_unload=P_max_car_drive,
        P_max_load=P_max_car_charge))
    annotation (Placement(transformation(extent={{80,-2},{44,34}})));


  Modelica.Blocks.Sources.RealExpression P_batteryToGrid(y=if noEvent(
        P_set_battery.u2) then -carPowerBoundary.epp.P else 0)
                                               annotation (Placement(transformation(extent={{2,-70},
            {54,-46}})));
  TransiEnt.Components.Boundaries.Electrical.ActivePower.Frequency carPowerBoundary(
      useInputConnector=false) annotation (Placement(transformation(extent={{34,24},{18,8}})));

  Modelica.Blocks.Math.Min min1 if   useExternalControl and controlType == "limit"  annotation (Placement(transformation(extent={{-22,12},
            {-8,26}})));
  Modelica.Blocks.Math.Product product1 if  useExternalControl and controlType == "proportional" annotation (Placement(transformation(extent={{-20,-36},
            {-6,-22}})));
  Modelica.Blocks.Logical.Switch P_set_battery  annotation (Placement(transformation(extent={{54,78},{74,58}})));
  Modelica.Blocks.Sources.RealExpression chargingStationPower(y=P_charge.y) if                                                                  not useExternalControl annotation (Placement(transformation(extent={{12,28},{38,46}})));
  Modelica.Blocks.Sources.RealExpression drivingPower(y=-carEfficiency/100 * carDistance.y[1] * 60 / timeStepSize) if  inputDataType=="carDistance" annotation (Placement(transformation(extent={{8,80},{42,100}})));

  Modelica.Blocks.MathBoolean.Or charging(nu=5) if inputDataType=="carDistance" annotation (Placement(transformation(extent={{6,60},{24,78}})));
  Modelica.Blocks.Sources.BooleanExpression presence(y=carHome.y) if inputDataType=="carDistance" annotation (Placement(transformation(extent={{-40,84},{-20,100}})));
  Modelica.Blocks.Sources.BooleanExpression school(y=if ChargeAtSchool then (abs(4 - carLocation.y[1]) < 0.5 and (abs(derLoc.y) < 0.01)) else false) if inputDataType=="carDistance" annotation (Placement(transformation(extent={{-64,62},
            {-44,78}})));
  Modelica.Blocks.Sources.BooleanExpression shopping(y=if ChargeAtShopping then (abs(2 - carLocation.y[1]) < 0.5 and (abs(derLoc.y) < 0.01)) else false) if inputDataType=="carDistance" annotation (Placement(transformation(extent={{-66,78},
            {-46,94}})));
  Modelica.Blocks.Sources.BooleanExpression event(y=if ChargeAtOther then (abs(3 - carLocation.y[1]) < 0.5 and (abs(derLoc.y) < 0.01)) else false) if inputDataType=="carDistance" annotation (Placement(transformation(extent={{-40,68},
            {-20,84}})));
  Modelica.Blocks.Sources.BooleanExpression work(y=if ChargeAtWork then (abs(5 - carLocation.y[1]) < 0.5 and (abs(derLoc.y) < 0.01)) else false) if inputDataType=="carDistance" annotation (Placement(transformation(extent={{-42,54},
            {-22,70}})));

   TransiEnt.Basics.Tables.ElectricGrid.Electromobility.CarDistanceTable carDistance(
    multiple_outputs=true,
    columns={column_Distance + 1}, relativepath=relativepath_carDistance) if  inputDataType=="carDistance" annotation (Placement(transformation(extent={{-96,-58},
            {-76,-38}})));

  TransiEnt.Basics.Tables.ElectricGrid.Electromobility.CarLocationTable carLocation(
    multiple_outputs=true,
    columns={column_Location + 1},  relativepath=relativepath_carLocation) if  inputDataType=="carDistance" annotation (Placement(transformation(extent={{-96,-88},
            {-76,-68}})));



  // _____________________________________________
  //
  //              Interfaces
  // _____________________________________________

  Modelica.Blocks.Interfaces.RealInput P_limit if useExternalControl and controlType == "limit"  "Interface for Load Regulation" annotation (Placement(transformation(extent={{-130,4},
            {-92,42}}), iconTransformation(extent={{-130,4},{-92,42}})));
  Modelica.Blocks.Interfaces.RealInput p_control if useExternalControl and controlType == "proportional" "Interface for Load Regulation" annotation (Placement(transformation(extent={{-128,
            -52},{-90,-14}}),
                            iconTransformation(extent={{-128,-52},{-90,-14}})));
  TransiEnt.Basics.Interfaces.Electrical.ApparentPowerPort epp annotation (Placement(transformation(extent={{90,-10},{110,10}})));
  Modelica.Blocks.Interfaces.RealInput SOC_consumption_internal;
  Modelica.Blocks.Sources.RealExpression zero(y=0) if inputDataType=="SoC"
    annotation (Placement(transformation(extent={{8,94},{42,114}})));
  TransiEnt.Basics.Tables.ElectricGrid.Electromobility.Table_Vehicle
                table_Vehicle(use_absolute_path=false) if
                                 inputDataType=="SoC" annotation (Placement(transformation(extent={{-94,40},
            {-74,60}})));
  Modelica.Blocks.Sources.RealExpression derLoc(y=if carLocation.smoothness == Modelica.Blocks.Types.Smoothness.ConstantSegments then 0 else der(carLocation.y[1])) if                                                                           inputDataType=="carDistance"
    annotation (Placement(transformation(extent={{-56,-102},{-28,-82}})));
  Modelica.Blocks.Sources.BooleanExpression carHome(y=abs(1 - carLocation.y[1]) <
        0.5 and (abs(derLoc.y) < 0.01)) if                                                                                                                                                                                              inputDataType=="carDistance"
    annotation (Placement(transformation(extent={{-56,-84},{-28,-68}})));
  Modelica.Blocks.Logical.Hysteresis hysteresis(uLow=SOCLimit - 0.05, uHigh=
        SOCLimit)
    annotation (Placement(transformation(extent={{-76,-16},{-60,0}})));
  Modelica.Blocks.Sources.RealExpression soC(y=SoC) if                                                                                                                                                                                           inputDataType=="carDistance"
    annotation (Placement(transformation(extent={{-100,-16},{-82,0}})));
  Modelica.Blocks.Logical.Switch P_charge
    annotation (Placement(transformation(extent={{-52,0},{-36,-16}})));
  Modelica.Blocks.Sources.RealExpression zero1(y=0) if                                                                                                                                                                                           inputDataType=="carDistance"
    annotation (Placement(transformation(extent={{-82,2},{-70,18}})));
  Modelica.Blocks.Sources.RealExpression P(y=P_chargingStation) if                                                                                                                                                                               inputDataType=="carDistance"
    annotation (Placement(transformation(extent={{-82,-34},{-70,-20}})));
equation

  //equations for input type Soc

  if inputDataType=="SoC" then
    when P_set_battery.u2 then
    reinit(vehicleBattery.storageModel.E, max(vehicleBattery.storageModel.SOC - SOC_consumption_internal, 0)*(vehicleBattery.StorageModelParams.E_max
       - vehicleBattery.StorageModelParams.E_min) + vehicleBattery.StorageModelParams.E_min);
    end when;
  end if;

  //equations for input type carDistance
    if inputDataType=="carDistance" then
    SOC_consumption_internal=0;
  end if;

  //carLoc = carLocation.y[1];
 // derLoc = if carLocation.smoothness == Modelica.Blocks.Types.Smoothness.ConstantSegments then 0 else der(carLocation.y[1]);
//  carHome = abs(1 - carLocation.y[1]) < 0.5 and (abs(derLoc) < 0.01);
 // P_driving = -carEfficiency/100 * carDistance.y[1] * 60 / timeStepSize;

  //connect statements
  connect(carPowerBoundary.epp, vehicleBattery.epp) annotation (Line(
      points={{34,16},{44,16}},
      color={0,135,135},
      thickness=0.5));
  connect(powerToGrid.epp, epp) annotation (Line(
      points={{72,-78},{86,-78},{86,0},{100,0}},
      color={0,127,0},
      thickness=0.5));
  connect(P_batteryToGrid.y, powerToGrid.P_el_set)
    annotation (Line(points={{56.6,-58},{68,-58},{68,-66}}, color={0,0,127}));
  connect(P_limit,min1. u1) annotation (Line(points={{-111,23},{-23.4,23.2}},                     color={0,0,127}));
  connect(p_control, product1.u2) annotation (Line(points={{-109,-33},{-26,-33},
          {-26,-33.2},{-21.4,-33.2}},                                                                       color={0,0,127}));
  connect(P_set_battery.y, vehicleBattery.P_set) annotation (Line(points={{75,68},
          {74,68},{74,38},{62,38},{62,32.92}}, color={0,0,127}));
  connect(min1.y, P_set_battery.u1) annotation (Line(points={{-7.3,19},{0,19},{
          0,50},{46,50},{46,60},{52,60}},
                           color={0,0,127}));
  connect(product1.y, P_set_battery.u1) annotation (Line(points={{-5.3,-29},{4,
          -29},{4,50},{46,50},{46,60},{52,60}},
                                 color={0,0,127}));
  connect(chargingStationPower.y, P_set_battery.u1) annotation (Line(points={{39.3,37},{46,37},{46,60},{52,60}},
                                             color={0,0,127}));
  connect(drivingPower.y, P_set_battery.u3) annotation (Line(points={{43.7,90},{50,90},{50,82},{52,82},{52,76}},
                                    color={0,0,127}));
  connect(presence.y, charging.u[1]) annotation (Line(points={{-19,92},{-2,92},{-2,74.04},{6,74.04}}, color={255,0,255}));
  connect(school.y, charging.u[2]) annotation (Line(points={{-43,70},{2,70},{2,71.52},
          {6,71.52}},                                                                                   color={255,0,255}));
  connect(event.y, charging.u[3]) annotation (Line(points={{-19,76},{6,76},{6,69}},    color={255,0,255}));
  connect(shopping.y, charging.u[4]) annotation (Line(points={{-45,86},{-2,86},{
          -2,66.48},{6,66.48}},                                                                           color={255,0,255}));
  connect(work.y, charging.u[5]) annotation (Line(points={{-21,62},{-2,62},{-2,66},
          {2,66},{2,63.96},{6,63.96}},                                                                color={255,0,255}));
  connect(charging.y, P_set_battery.u2) annotation (Line(points={{25.35,69},{40,69},{40,68},{52,68}}, color={255,0,255}));
  connect(zero.y, P_set_battery.u3) annotation (Line(points={{43.7,104},{58,104},
          {58,82},{52,82},{52,76}},                  color={0,0,127}));
  connect(table_Vehicle.isConnected, P_set_battery.u2) annotation (Line(points={{-75,54},
          {40,54},{40,68},{52,68}},                            color={255,0,255}));
  connect(SOC_consumption_internal,table_Vehicle.SOC_Consumption);
  connect(soC.y, hysteresis.u)
    annotation (Line(points={{-81.1,-8},{-77.6,-8}}, color={0,0,127}));
  connect(hysteresis.y, P_charge.u2)
    annotation (Line(points={{-59.2,-8},{-53.6,-8}}, color={255,0,255}));
  connect(zero1.y, P_charge.u3) annotation (Line(points={{-69.4,10},{-58,10},{
          -58,-2},{-53.6,-2},{-53.6,-1.6}}, color={0,0,127}));
  connect(P_charge.y, min1.u2) annotation (Line(points={{-35.2,-8},{-30,-8},{
          -30,14},{-23.4,14},{-23.4,14.8}}, color={0,0,127}));
  connect(P_charge.y, product1.u1) annotation (Line(points={{-35.2,-8},{-30,-8},
          {-30,-26},{-21.4,-26},{-21.4,-24.8}}, color={0,0,127}));
  connect(P.y, P_charge.u1) annotation (Line(points={{-69.4,-27},{-56,-27},{-56,
          -18},{-53.6,-18},{-53.6,-14.4}}, color={0,0,127}));
  annotation (
      Diagram(graphics={
        Line(
          points={{-58,-78}},
          color={28,108,200},
          pattern=LinePattern.Dot),
        Line(
          points={{26,4},{26,-4},{26,-8},{26,-16},{26,-40}},
          color={0,0,0},
          pattern=LinePattern.Dot,
          arrow={Arrow.None,Arrow.Filled})}),
    Icon(graphics={
        Line(points={{20,-28}}, color={0,0,0}),
        Polygon(
          points={{-66,2},{60,2},{72,-28},{-80,-28},{-66,2}},
          lineColor={238,46,47},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{14,-14},{42,-42}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-56,-14},{-28,-42}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-40,34},{36,34},{50,0},{-54,0},{-40,34}},
          lineColor={238,46,47},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{50,-8},{54,-12}},
          lineColor={0,0,0},
          lineThickness=1,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Line(
          points={{52,-10},{60,-12},{66,-10},{70,-4},{74,0},{84,0},{92,-4},{100,
              0},{96,-2}},
          color={0,140,72},
          thickness=1)}),
    experiment(StopTime=0, __Dymola_Algorithm="Dassl"),
    Documentation(info="<html>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">1. Purpose of model</span></b></p>
<p>Simple model of an electric car battery. Table-based profiles of the car location and the kilometers driven determine the state-of-charge of the car. When the car ist home, it will charge from the grid. It can be selected wheather charging will occur only at home or also at other places, thus affecting the state-of-charge. </p>
<p>The wall box charging power can be externally controlled by reducing the charging power proportionally or by setting a fixed maximum charging power.</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">2. Level of detail, physical effects considered, and physical insight</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">3. Limits of validity </span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">4. Interfaces</span></b></p>
<p>epp: apparent power port</p>
<p>optional: RealInput P_limit or p_control for external load management.</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">5. Nomenclature</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">6. Governing Equations</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">7. Remarks for Usage</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">8. Validation</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">9. References</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">10. Version History</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model created by Dorian H&ouml;ffner, Fraunhofer UMSICHT in December 2021</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model modified by Anne Hagemeier, Fraunhofer UMSICHT, in June 2022</span></p>
</html>"));
end BatteryElectricVehicle;
