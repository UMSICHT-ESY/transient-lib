within TransiEnt.Consumer.Electrical;
model ElectricCar


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
  // _____________________________________________
  //
  //              Parameters
  // _____________________________________________

  parameter String inputDataType="carDistance" "Choose data type format: 'Distance travelled' or 'SoC at the arrival back home'"
    annotation (Dialog(group="Data"), choices(
                choice="carDistance",
                choice="SoC"));

  parameter Real carEfficiency=18  "[kWh/100km] Average electricity use per kilometer"    annotation (Dialog(group=
          "Electric car", enable=inputDataType == "carDistance"));

  parameter SI.Energy Bat_Capacity=252000000 "Battery capacity" annotation (Dialog(group=
          "Electric car"));
  parameter SI.Power P_max_car_drive=200000 "Maximum driving power of the vehicle" annotation (Dialog(group=
          "Electric car", enable=inputDataType == "carDistance"));
  parameter SI.Power P_max_car_charge=22000
    "Maximum charging power of the vehicle"                                         annotation (Dialog(group=
          "Electric car"));

  parameter String relativepath_carDistance="emobility/CarDistance.txt"
    "Path relative to source directory for car distance table" annotation (Dialog(group="Data",
        enable=inputDataType == "carDistance"));
  parameter String relativepath_carLocation="emobility/CarLocation.txt"
    "Path relative to source directory for car location table" annotation (Dialog(group="Data",
        enable=inputDataType == "carDistance"));
  parameter Real timeStepSize(unit="min") = 1
    "Time step size of distance travelled" annotation (Dialog(group="Data",
        enable=inputDataType == "carDistance"));

  parameter Integer column_Location=1 "Table column for car location data" annotation (Dialog(group="Data",
        enable=inputDataType == "carDistance"));
  parameter Integer column_Distance=1 "Table column for car distance data" annotation (Dialog(group="Data",
        enable=inputDataType == "carDistance"));

  parameter Modelica.Units.SI.Power P_chargingStation = 11000 "Charging power of the charging station" annotation (Dialog(group="Charging station"));
  parameter Boolean ChargeAtWork=true annotation (Dialog(group="Charging - Select if car ist charged at different locations than home. Charging power will not be accounted for but will reduce charging load at home. Locations need to be specified in Input table", joinNext=true,
      enable=inputDataType == "carDistance"),                                                                                                                                                                                                        choices(checkBox=true));
  parameter Boolean ChargeAtSchool=false annotation (Dialog(group="Charging - Select if car ist charged at different locations than home. Charging power will not be accounted for but will reduce charging load at home. Locations need to be specified in Input table", joinNext=true,
      enable=inputDataType == "carDistance"),choices(checkBox=true));
  parameter Boolean ChargeAtShopping=false annotation (Dialog(group="Charging - Select if car ist charged at different locations than home. Charging power will not be accounted for but will reduce charging load at home. Locations need to be specified in Input table", joinNext=true,
      enable=inputDataType == "carDistance"),choices(checkBox=true));
  parameter Boolean ChargeAtOther=false annotation (Dialog(group="Charging - Select if car ist charged at different locations than home. Charging power will not be accounted for but will reduce charging load at home. Locations need to be specified in Input table"),
      enable=inputDataType == "carDistance",choices(checkBox=true));


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

   Real carLoc "Number representing car location (1=Home)";
   Real derLoc "Derivative of car location";
   Boolean carHome "True, if car is parked at home";
   Modelica.Units.SI.Power P_driving "Current consumption of driving car";
   Real P_charge "Charging power";

   Real P_limit=simCenter.P_limit;
   Real p_control=simCenter.PropControlFactor;


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
    use_PowerRateLimiter=true,
    redeclare model StorageModel = TransiEnt.Storage.Base.GenericStorageHyst,
    StorageModelParams=TransiEnt.Storage.Electrical.Specifications.LithiumIon(
        E_start=Bat_Capacity,
        E_max=Bat_Capacity,
        E_min=0.3*Bat_Capacity,
        P_max_unload=P_max_car_drive,
        P_max_load=P_max_car_charge,
        selfDischargeRate=0))
    annotation (Placement(transformation(extent={{74,-18},{38,18}})));
  Modelica.Blocks.Sources.RealExpression P_batteryToGrid(y=if noEvent(carHome)
         then -carPowerBoundary.epp.P else 0)  annotation (Placement(transformation(extent={{2,-68},{54,-44}})));
  TransiEnt.Components.Boundaries.Electrical.ActivePower.Frequency carPowerBoundary(
      useInputConnector=false) annotation (Placement(transformation(extent={{28,8},{
            12,-8}})));

  Modelica.Blocks.Logical.Switch P_set_battery  annotation (Placement(transformation(extent={{54,76},
            {74,56}})));
  Modelica.Blocks.Sources.RealExpression chargingStationPower(y=P_charge) if          not useExternalControl annotation (Placement(transformation(extent={{-86,14},
            {-60,32}})));
  Modelica.Blocks.Sources.RealExpression drivingPower(y=P_driving)  annotation (Placement(transformation(extent={{4,80},{
            34,98}})));


  Modelica.Blocks.MathBoolean.Or charging(nu=5) annotation (Placement(transformation(extent={{-8,58},
            {8,74}})));
  Modelica.Blocks.Sources.BooleanExpression presence(y=carHome) annotation (Placement(transformation(extent={{-72,76},
            {-40,94}})));
  Modelica.Blocks.Sources.BooleanExpression school(y=if ChargeAtSchool then (abs(4 - carLoc) < 0.5 and (abs(derLoc) < 0.01)) else false) annotation (Placement(transformation(extent={{-72,42},
            {-40,58}})));
  Modelica.Blocks.Sources.BooleanExpression shopping(y=if ChargeAtShopping then (abs(2 - carLoc) < 0.5 and (abs(derLoc) < 0.01)) else false) annotation (Placement(transformation(extent={{-72,66},
            {-40,82}})));
  Modelica.Blocks.Sources.BooleanExpression event(y=if ChargeAtOther then (abs(3 - carLoc) < 0.5 and (abs(derLoc) < 0.01)) else false) annotation (Placement(transformation(extent={{-72,54},
            {-40,70}})));
  Modelica.Blocks.Sources.BooleanExpression work(y=if ChargeAtWork then (abs(5 - carLoc) < 0.5 and (abs(derLoc) < 0.01)) else false) annotation (Placement(transformation(extent={{-72,30},
            {-40,48}})));

  TransiEnt.Basics.Tables.ElectricGrid.Electromobility.DistanceTable carDistance(
    multiple_outputs=true,
    columns={column_Distance + 1},
    relativepath=relativepath_carDistance) annotation (Placement(transformation(extent={{-96,-40},{-76,-20}})));

  TransiEnt.Basics.Tables.ElectricGrid.Electromobility.LocationTable carLocation(
    multiple_outputs=true,
    columns={column_Location + 1},
    relativepath=relativepath_carLocation) annotation (Placement(transformation(extent={{-96,-80},{-76,-60}})));


  // _____________________________________________
  //
  //              Interfaces
  // _____________________________________________


  TransiEnt.Basics.Interfaces.Electrical.ApparentPowerPort epp annotation (Placement(transformation(extent={{90,-10},{110,10}})));

  Modelica.Blocks.Logical.Switch P_set_battery1 annotation (Placement(transformation(extent={{-8,36},
            {12,16}})));
  Modelica.Blocks.Sources.RealExpression P_SoC_Limit(y=0) if                          not useExternalControl
    annotation (Placement(transformation(extent={{-76,-8},{-50,10}})));
equation

 if useExternalControl then
   if controlType == "limit" then
   P_charge=max(P_chargingStation,P_limit);
   else
   P_charge=P_chargingStation*p_control;
   end if;
else
   P_charge=P_chargingStation;
 end if;

  carLoc = carLocation.y[1];
  derLoc = if carLocation.smoothness == Modelica.Blocks.Types.Smoothness.ConstantSegments then 0 else der(carLoc);
  carHome = abs(1 - carLoc) < 0.5 and (abs(derLoc) < 0.01);
  P_driving = -carEfficiency/100 * carDistance.y[1] * 60 / timeStepSize;

  connect(carPowerBoundary.epp, vehicleBattery.epp) annotation (Line(
      points={{28,0},{38,0}},
      color={0,135,135},
      thickness=0.5));
  connect(powerToGrid.epp, epp) annotation (Line(
      points={{72,-78},{86,-78},{86,0},{100,0}},
      color={0,127,0},
      thickness=0.5));
  connect(P_batteryToGrid.y, powerToGrid.P_el_set)
    annotation (Line(points={{56.6,-56},{68,-56},{68,-66}}, color={0,0,127}));
  connect(P_set_battery.y, vehicleBattery.P_set) annotation (Line(points={{75,66},
          {80,66},{80,22},{56,22},{56,16.92}}, color={0,0,127}));
  connect(drivingPower.y, P_set_battery.u3) annotation (Line(points={{35.5,89},{
          46,89},{46,74},{52,74}},  color={0,0,127}));
  connect(presence.y, charging.u[1]) annotation (Line(points={{-38.4,85},{-20,85},
          {-20,70.48},{-8,70.48}},                                                                    color={255,0,255}));
  connect(school.y, charging.u[2]) annotation (Line(points={{-38.4,50},{-20,50},
          {-20,68.24},{-8,68.24}},                                                                      color={255,0,255}));
  connect(event.y, charging.u[3]) annotation (Line(points={{-38.4,62},{-24,62},{
          -24,66},{-8,66}},                                                            color={255,0,255}));
  connect(shopping.y, charging.u[4]) annotation (Line(points={{-38.4,74},{-20,74},
          {-20,63.76},{-8,63.76}},                                                                        color={255,0,255}));
  connect(work.y, charging.u[5]) annotation (Line(points={{-38.4,39},{-20,39},{-20,
          61.52},{-8,61.52}},                                                                         color={255,0,255}));
  connect(charging.y, P_set_battery.u2) annotation (Line(points={{9.2,66},{52,66}},                   color={255,0,255}));
  connect(chargingStationPower.y, P_set_battery1.u3) annotation (Line(points={{
          -58.7,23},{-36,23},{-36,34},{-10,34}}, color={0,0,127}));
  connect(P_set_battery1.y, P_set_battery.u1) annotation (Line(points={{13,26},
          {46,26},{46,58},{52,58}}, color={0,0,127}));
  connect(P_SoC_Limit.y, P_set_battery1.u1) annotation (Line(points={{-48.7,1},
          {-16,1},{-16,18},{-10,18}}, color={0,0,127}));
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
          points={{-70,-12},{42,-12},{52,-40},{-80,-40},{-70,-12}},
          lineColor={238,46,47},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{10,-26},{38,-54}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-66,-26},{-38,-54}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-44,16},{8,14},{28,-12},{-54,-12},{-44,16}},
          lineColor={238,46,47},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Line(points={{92,0},{72,-4},{66,-8},{64,-16},{60,-20},{52,-22},{46,-22},
              {38,-20}}, color={0,0,0}),
        Rectangle(
          extent={{34,-18},{38,-22}},
          lineColor={0,0,0},
          lineThickness=1,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid)}),
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
end ElectricCar;
