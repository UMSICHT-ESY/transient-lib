within TransiEnt.Consumer.Systems.HouseholdEnergyConverter.GridConstructorSystems.Check;
model TestGridConstructor

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

  extends TransiEnt.Basics.Icons.Checkmodel;

public
  inner TransiEnt.SimCenter simCenter(
    ambientConditions(
      redeclare TransiEnt.Basics.Tables.Ambient.GHI_Hamburg_3600s_2012_TMY globalSolarRadiation,
      redeclare TransiEnt.Basics.Tables.Ambient.DNI_Hamburg_3600s_2012_TMY directSolarRadiation,
      redeclare TransiEnt.Basics.Tables.Ambient.DHI_Hamburg_3600s_2012_TMY diffuseSolarRadiation,
      redeclare TransiEnt.Basics.Tables.Ambient.Temperature_Hamburg_3600s_TMY temperature),
    T_ground=278.15,
    v_n=400,
    p_eff_1=5000,
    tableInterpolationSmoothness=Modelica.Blocks.Types.Smoothness.MonotoneContinuousDerivative1) annotation (Placement(transformation(extent={{-84,74},{-56,100}})));
  TransiEnt.Components.Boundaries.Electrical.ApparentPower.FrequencyVoltage ElectricGrid(
    epp(
      P(start=1),
      v(start=400),
      Q(start=1)),
    Use_input_connector_f=false,
    Use_input_connector_v=false,
    v_boundary=400) annotation (Placement(transformation(
        extent={{-12,-13},{12,13}},
        rotation=180,
        origin={-84,-29})));
  TransiEnt.Components.Boundaries.Gas.BoundaryRealGas_pTxi Gas_Source(p_const=simCenter.p_amb_const + simCenter.p_eff_1) annotation (Placement(transformation(extent={{-96,34},{-70,60}})));
  TransiEnt.Consumer.Systems.HouseholdEnergyConverter.GridConstructorSystems.GridConstructor grid(
    gas_in=false,
    gas_out=false,
    el_out=false,
    dhn_in_s=false,
    dhn_out_s=false,
    dhn_in_r=false,
    dhn_out_r=false,
    n_elements=3,
    second_row=true,
    second_Consumer={true,true,true},
    redeclare model Systems_Consumer_1 = Systems.HeatPump,
    redeclare model Systems_Consumer_2 = Systems.HeatPump)            annotation (Placement(transformation(extent={{-36,-12},{42,48}})));
equation
  connect(Gas_Source.gasPort, grid.gasPortIn) annotation (Line(
      points={{-70,47},{-42,47},{-42,33},{-36,33}},
      color={255,255,0},
      thickness=1.5));
  connect(ElectricGrid.epp, grid.epp_p) annotation (Line(
      points={{-72,-29},{-40,-29},{-40,3},{-36,3}},
      color={0,127,0},
      thickness=0.5));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false), graphics={Line(points={{22,-16},{22,-58},{106,-58}}, color={28,108,200}),Text(
          extent={{24,-42},{104,-64}},
          lineColor={28,108,200},
          textString="Total Number of Consumers"),Line(points={{-24,-16},{-24,-82},{64,-82}}, color={28,108,200}),Text(
          extent={{-20,-66},{60,-88}},
          lineColor={28,108,200},
          textString="Number of grid elements"),
        Text(
          extent={{-32,126},{94,50}},
          textColor={0,0,0},
          horizontalAlignment=TextAlignment.Left,
          textStyle={TextStyle.Bold},
          textString="Look at:
- grid.epp_p.P (Electrical demand of GridConstructor)")}),
    experiment(
      StopTime=8640000,
      Interval=60.0001344,
      __Dymola_Algorithm="Dassl"),
    Documentation(info="<html>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">1. Purpose of model</span></b></p>
<p>Test environment for the usage of the GridConstructor model with activated gas and electric port and corresponding sources.</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">2. Level of detail, physical effects considered, and physical insight</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">3. Limits of validity </span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">4. Interfaces</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">5. Nomenclature</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">6. Governing Equations</span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">7. Remarks for Usage</span></b> </p>
<p>(no remarks)</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">8. Validation</span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">9. References</span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">10. Version History</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model created during the project IntegraNet</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Modified by Annika Heyer, 2021</span></p>
</html>"));
end TestGridConstructor;
