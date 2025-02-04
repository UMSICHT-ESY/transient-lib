within TransiEnt.Producer.Heat.Power2Heat.ElectricBoiler;
model ElectricBoilerSystem "Electric Boiler with buffer and control"

//________________________________________________________________________________//
// Component of the TransiEnt Library, version: 2.0.3                             //
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
// Gas- und WÃ¤rme-Institut Essen                                                  //
// and                                                                            //
// XRG Simulation GmbH (Hamburg, Germany).                                        //
//________________________________________________________________________________//

  // _____________________________________________
  //
  //          Imports and Class Hierarchy
  // _____________________________________________
  extends TransiEnt.Basics.Icons.Model;

  // _____________________________________________
  //
  //                 Outer Models
  // _____________________________________________

  outer TransiEnt.SimCenter simCenter;
  outer TransiEnt.ModelStatistics modelStatistics;
  // _____________________________________________
  //
  //                Parameters
  // _____________________________________________

  parameter Modelica.Units.SI.Power P_flowheater=18e3 "Nominal electric power";



  // _____________________________________________
  //
  //                Interfaces
  // _____________________________________________

  TransiEnt.Basics.Interfaces.Thermal.HeatFlowRateIn Q_flow_demand annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={104,20})));
  Basics.Interfaces.Electrical.ComplexPowerPort epp annotation (
    Placement(transformation(extent={{-8,-108},{12,-88}}),iconTransformation(extent={{-10,-112},{10,-92}})));


  // _____________________________________________
  //
  //                Complex Components
  // _____________________________________________

  Storage.Heat.HotWaterStorage_constProp_L2.HotWaterStorage_constProp_L2
    flowheatertank(
    useFluidPorts=false,
    T_max=473.15,
    T_s_max=373.15,
    T_s_min(displayUnit="degC") = 293.15,
    d=0.2,
    height=0.5,
    T_start(displayUnit="degC") = 328.15)
    annotation (Placement(transformation(extent={{46,12},{62,28}})));
  ElectricBoiler                                         flowheater(
    change_sign=true,
    usePelset=false,
    Q_flow_n=P_flowheater,
    eta=1,
    useFluidPorts=false,
    usePowerPort=true,
    redeclare connector PowerPortModel =
        Basics.Interfaces.Electrical.ComplexPowerPort,
    redeclare model PowerBoundaryModel =
        Components.Boundaries.Electrical.ComplexPower.PQBoundary,
    powerBoundary(useInputConnectorQ=false, cosphi_boundary=0.99))
             annotation (Placement(transformation(extent={{18,-30},{36,-14}})));
  Modelica.Blocks.Sources.RealExpression P_Heater(y=P_flowheater)
                                                                annotation (Placement(transformation(extent={{-8,-7},
            {8,7}},
        rotation=0,
        origin={-64,-7})));
  Modelica.Blocks.Sources.RealExpression zero2(y=0) annotation (Placement(transformation(extent={{-64,0},
            {-52,12}})));
  Modelica.Blocks.Logical.Switch switch5 annotation (Placement(transformation(
        extent={{6,-6},{-6,6}},
        rotation=180,
        origin={-32,-2})));
  Modelica.Blocks.Continuous.FirstOrder firstOrder1(T=1)
    annotation (Placement(transformation(extent={{0,-26},{10,-16}})));
  Modelica.Blocks.Logical.Hysteresis hysteresis1(
    uLow=55,
    uHigh=60,
    pre_y_start=true) annotation (Placement(transformation(
        extent={{-4,-4},{4,4}},
        rotation=180,
        origin={2,40})));
  Modelica.Blocks.Logical.Not Not1 annotation (Placement(transformation(extent={{-4,-4},
            {4,4}},
        rotation=180,
        origin={-12,40})));
  // _____________________________________________
  //
  //             Variable Declarations
  // _____________________________________________

equation

  // _____________________________________________
  //
  //                Connect Equations
  // _____________________________________________


  connect(flowheater.Q_flow_gen,flowheatertank. Q_flow_store) annotation (Line(
      points={{36.54,-15.44},{36.54,20},{46.48,20}},
      color={175,0,0},
      pattern=LinePattern.Dash));
  connect(switch5.y,firstOrder1. u)
    annotation (Line(points={{-25.4,-2},{-16,-2},{-16,-21},{-1,-21}},
                                                     color={0,0,127}));
  connect(switch5.u3,zero2. y) annotation (Line(points={{-39.2,2.8},{-39.2,6},{-51.4,
          6}},         color={0,0,127}));
  connect(switch5.u1,P_Heater. y)
    annotation (Line(points={{-39.2,-6.8},{-55.2,-7}}, color={0,0,127}));
  connect(firstOrder1.y,flowheater. Q_flow_set) annotation (Line(points={{10.5,-21},
          {10.5,-21.2},{17.64,-21.2}},     color={0,0,127}));
  connect(flowheatertank.T_stor_out,hysteresis1. u) annotation (Line(points={{52.56,
          27.68},{52,27.68},{52,40},{6.8,40}},
                                          color={0,0,127}));
  connect(hysteresis1.y,Not1. u)
    annotation (Line(points={{-2.4,40},{-7.2,40}},   color={255,0,255}));
  connect(Not1.y,switch5. u2) annotation (Line(points={{-16.4,40},{-50,40},{-50,
          -2},{-39.2,-2}}, color={255,0,255}));
  connect(Q_flow_demand, flowheatertank.Q_flow_demand) annotation (Line(
      points={{104,20},{62,20}},
      color={175,0,0},
      pattern=LinePattern.Dash));
  connect(flowheater.epp, epp) annotation (Line(
      points={{27,-30.16},{26,-30.16},{26,-84},{2,-84},{2,-98}},
      color={28,108,200},
      thickness=0.5));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}}), graphics={
        Ellipse(
          extent={{-42,-50},{40,-92}},
          lineColor={0,0,0},
          fillColor={127,0,0},
          fillPattern=FillPattern.VerticalCylinder),
        Rectangle(
          extent={{-42,52},{40,-74}},
          lineColor={0,0,0},
          fillColor={127,0,0},
          fillPattern=FillPattern.VerticalCylinder),
        Ellipse(
          extent={{-42,74},{40,32}},
          lineColor={0,0,0},
          fillColor={127,0,0},
          fillPattern=FillPattern.VerticalCylinder),
        Line(
          points={{0,-48},{0,-102}},
          color={0,134,134},
          smooth=Smooth.None,
          thickness=0.5),
        Line(
          points={{0,0},{20,-8},{-18,-22},{18,-36},{0,-40},{0,-50}},
          thickness=0.5,
          smooth=Smooth.None,
          color={0,134,134})}),   Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-100,-100},{100,100}})),
    Documentation(info="<html>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">1. Purpose of model</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model of an electrode boiler using TransiEnt interfaces and TransiEnt.Statistics. Heat transfer is ideal, thermal losses are modeled using a constant efficiency. Heat port or fluid ports are choosable.</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">2. Level of detail, physical effects considered, and physical insight</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(Purely technical component without physical modeling.)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">3. Limits of validity </span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(Purely technical component without physical modeling.)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">4. Interfaces</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">epp: electric power port</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">fluidPortIn: fluid inlet (if selected)</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">fluidPortOut: fluid outlet (if selected)</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">heat: heat port (if selected)</span></p>
<p>Q_flow_set: set value for heat flow rate (if selected)</p>
<p>P_el_set: set value for electric power (if selected)</p>
<p>Q_flow_gen: generated heat</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">5. Nomenclature</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no elements)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">6. Governing Equations</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no equations)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">7. Remarsk for Usage</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">8. Validation</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">9. References</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">10. Version History</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model created by Pascal Dubucq (dubucq@tuhh.de) in October 2014</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model generalized for different electrical power ports by Jan-Peter Heckel (jan.heckel@tuhh.de) in July 2018 </span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model modified (added selectable heat port) by Carsten Bode (c.bode@tuhh.de), Nov 2018</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model modified by Anne Hagemeier (anne.hagemeier@umsicht.fraunhofer.de) in July 2021 (added change_sign and option to deselect both fluid and heat ports)</span></p>
</html>"));
end ElectricBoilerSystem;
