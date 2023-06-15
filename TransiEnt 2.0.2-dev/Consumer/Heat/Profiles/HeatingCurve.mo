within TransiEnt.Consumer.Heat.Profiles;
model HeatingCurve

  // _____________________________________________
  //
  //          Imports and Class Hierarchy
  // _____________________________________________

  extends TransiEnt.Basics.Icons.Model;
  outer SimCenter simCenter;

  // _____________________________________________
  //
  //          Parameters
  // _____________________________________________

  parameter Integer heatingCurveType=3 "Choose if heating curve is constant, taken from table data or caculcated based on slope and radiator exponent" annotation(choices(__Dymola_radioButtons=true,
                choice=1 "Constant temperature",
                choice=2 "Table_data",
                choice=3 "Calculation"), Dialog(group="heatingCurveCalculation"));

  parameter SI.Temperature T_supply_constant(displayUnit="degC") = 323.15
                                                                        annotation (Dialog(enable=heatingCurveType == 1, group="Constant values"));
  parameter SI.Temperature T_return_constant(displayUnit="degC") = 303.15
                                                                        annotation (Dialog(enable=heatingCurveType == 1, group="Constant values"));
  parameter String path_heatingCurve="heat/HeatingCurve_60_40.txt" annotation (Dialog(enable=heatingCurveType == 2, group="Tablebased curve"),
  choices(  choice="heat/HeatingCurve_FloorHeating.txt" "Heating curve for floor heating with 45°C/27°C on cold days",
            choice="heat/HeatingCurve_60_40.txt" "DHN heating curve with 60°C/40°C on cold days",
            choice="heat/HeatingCurve_80_60.txt" "DHN heating curve with 80°C/60°C on cold days",
            choice="heat/HeatingCurve_90_70.txt" "DHN heating curve with 90°C/70°C on cold days",
            choice="heat/HeatingCurve_LHN_EonHanse.txt" "DHN heating curve from EonHanse",
            choice="heat/HeatingCurve_LHN_EnergieverbundWilhelmsburgMitte.txt" "DHN heating curve from Energieverbund Wilhelmsburg Mitte",
            choice="heat/HeatingCurve_DHN_Vattenfall_Hamburg.txt" "DHN heating curve from Vattenfall"));

  parameter Real n=1.33 "Radiator exponent" annotation (Dialog(enable=heatingCurveType == 3, group="Exponential formula"));
  parameter Real slope_supply=(T_supply_max - T_room_set)/(T_room_set - T_amb_min)^(1/n) "Slope of the supply temperature curve";
  parameter Real slope_return=(T_return_max-T_room_set)/(T_room_set-T_amb_min)^(1/n) "Slope of the return temperature curve" annotation (Dialog(enable=heatingCurveType == 3, group="Exponential formula"));

  parameter SI.Temperature offset_supply(displayUnit="K")=0 "Constant elevation of supply temperature curve" annotation (Dialog(enable=heatingCurveType == 3, group="Exponential formula"));
  parameter SI.Temperature offset_return(displayUnit="K")=0 "Constant elevation of return temperature curve" annotation (Dialog(enable=heatingCurveType == 3, group="Exponential formula"));

  parameter SI.Temperature T_room_set=293.15 "Room temperature" annotation (Dialog(enable=heatingCurveType == 3, group="Exponential formula"));
  parameter SI.Temperature T_amb_min(displayUnit="degC")=263.15 "Heating design temperature" annotation (Dialog(enable=heatingCurveType == 3, group="Exponential formula"));
  parameter SI.Temperature T_supply_max(displayUnit="degC")=323.15 "Supply temperature at ambient design temperature" annotation (Dialog(enable=heatingCurveType == 3, group="Exponential formula"));
  parameter SI.Temperature T_return_max(displayUnit="degC")=303.15 "Supply temperature at ambient design temperature" annotation (Dialog(enable=heatingCurveType == 3, group="Exponential formula"));

  // _____________________________________________
  //
  //          Instances of other Classes
  // _____________________________________________


  TransiEnt.Basics.Tables.HeatGrid.HeatingCurves.HeatingCurve_FromDataPath  heatingCurve_FromDataPath(datapath=path_heatingCurve) if heatingCurveType==2  annotation (Placement(transformation(extent={{-44,-10},
            {-24,10}})));

  Modelica.Blocks.Sources.RealExpression T_supply_const(y=T_supply_constant) if heatingCurveType==1 annotation (Placement(transformation(extent={{-16,12},{2,32}})));
  Modelica.Blocks.Sources.RealExpression T_return_const(y=T_return_constant) if heatingCurveType==1 annotation (Placement(transformation(extent={{-16,-34},{0,-16}})));

  Modelica.Blocks.Sources.RealExpression T_supply_formula(y=if noEvent(T_room_set > simCenter.T_amb_var+273.15) then offset_supply+T_room_set+slope_supply*(T_room_set-simCenter.T_amb_var-273.15)^(1/n) else offset_supply+T_room_set) if heatingCurveType==3 annotation (Placement(transformation(extent={{-16,34},
            {0,52}})));
  Modelica.Blocks.Sources.RealExpression T_return_formula(y=if noEvent(T_room_set > simCenter.T_amb_var+273.15) then offset_return+T_room_set+slope_return*(T_room_set-simCenter.T_amb_var-273.15)^(1/n) else offset_return+T_room_set) if heatingCurveType==3 annotation (Placement(transformation(extent={{-16,-54},
            {2,-34}})));

  Real test=T_room_set-simCenter.T_amb_var;

  // _____________________________________________
  //
  //          Interfaces
  // _____________________________________________




  TransiEnt.Basics.Interfaces.General.TemperatureOut T_supply "Supply temperature of the heating system" annotation (
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC",
    Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={106,24}), iconTransformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={104,20})));
  TransiEnt.Basics.Interfaces.General.TemperatureOut T_return "Return temperature of the heating system" annotation (
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC",
    Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={106,-24}), iconTransformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={104,-20})));
equation


  // _____________________________________________
  //
  //          Conncect statements
  // _____________________________________________

  connect(heatingCurve_FromDataPath.T_Return, T_return) annotation (Line(points={{-23.2,-2},{88,-2},{88,-24},{106,-24}},
                                                                                                                       color={0,0,127}));
  connect(T_supply_const.y, T_supply) annotation (Line(points={{2.9,22},{62,22},{62,24},{106,24}},color={0,0,127}));
  connect(T_return_const.y, T_return) annotation (Line(points={{0.8,-25},{88,-25},{88,-24},{106,-24}},  color={0,0,127}));
  connect(T_supply_formula.y, T_supply) annotation (Line(points={{0.8,43},{86,43},{86,24},{106,24}},  color={0,0,127}));
  connect(T_return_formula.y, T_return) annotation (Line(points={{2.9,-44},{88,-44},{88,-24},{106,-24}},  color={0,0,127}));
  connect(heatingCurve_FromDataPath.T_Supply, T_supply) annotation (Line(points={{-23.2,3.6},{86,3.6},{86,24},{106,24}}, color={0,0,127}));
                                                                                                                                                                                                          annotation (Dialog(enable=heatingCurveType == 3, group="Exponential formula"),
              Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Line(points={{-66,64},{-66,-50},{68,-50}}, color={28,108,200}),
        Line(
          points={{-46,-48},{-46,-42},{-42,-32},{-40,-24},{-34,-12},{-28,-2},{-20,8},{-6,18},{4,26},{16,34},{26,40},{36,42},{50,44},{56,46}},
          color={28,108,200},
          smooth=Smooth.Bezier,
          thickness=0.5),
        Line(
          points={{-56,-40},{-54,-32},{-52,-24},{-50,-16},{-44,-4},{-38,6},{-30,16},{-16,26},{-6,34},{6,42},{16,48},{28,52},{38,54},{46,54}},
          color={238,46,47},
          smooth=Smooth.Bezier,
          thickness=0.5),
        Line(points={{-72,58},{-66,66},{-60,58}}, color={28,108,200}),
        Line(points={{-82,-50},{-58,-50}}, color={28,108,200}),
        Line(points={{-78,-46},{-82,-50},{-78,-54}}, color={28,108,200})}),
                                                                 Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end HeatingCurve;
