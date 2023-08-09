within TransiEnt.Consumer.Systems.HouseholdEnergyConverter.GridConstructorSystems.Check;
model TestGridConstructor_DHN

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
        origin={-60,-71})));
  TransiEnt.Consumer.Systems.HouseholdEnergyConverter.GridConstructorSystems.GridConstructor grid(
    gas_in=false,
    gas_out=false,
    el_out=false,
    dhn_in_s=true,
    dhn_out_s=false,
    dhn_in_r=false,
    dhn_out_r=true,
    n_elements=3,
    second_row=true,
    second_Consumer={true,true,true},
    redeclare model Systems_Consumer_1 = Systems.DHN_Substation,
    redeclare model Systems_Consumer_2 = Systems.DHN_Substation,
    Basic_Grid_Elements(Systems_1(substation_indirect_noStorage_L1_1(redeclare model room_heating_hex_model = Producer.Heat.Heat2Heat.Indirect_HEX_const_T_out_L1, redeclare model dhw_heating_hex_model = Producer.Heat.Heat2Heat.Indirect_HEX_const_T_out_L1))))
                                                                      annotation (Placement(transformation(extent={{64,-18},{142,42}})));
  ClaRa.Components.BoundaryConditions.BoundaryVLE_pTxi supply_boundary(p_const=10e5, T_const(displayUnit="degC") = 363.15) annotation (Placement(transformation(extent={{-70,-6},{-54,10}})));
  ClaRa.Components.BoundaryConditions.BoundaryVLE_pTxi return_boundary(p_const=5e5, T_const(displayUnit="degC") = 343.15)                 annotation (Placement(transformation(extent={{-70,-28},{-54,-14}})));
  ClaRa.Components.Sensors.SensorVLE_L1_T T_supply annotation (Placement(transformation(extent={{14,42},{34,62}})));
  ClaRa.Components.Sensors.SensorVLE_L1_T T_return annotation (Placement(transformation(extent={{12,-22},{32,-42}})));
equation
  connect(ElectricGrid.epp, grid.epp_p) annotation (Line(
      points={{-48,-71},{54,-71},{54,-3},{64,-3}},
      color={0,127,0},
      thickness=0.5));
  connect(return_boundary.steam_a, grid.waterPortOut_return) annotation (Line(
      points={{-54,-21},{6,-21},{6,7},{64,7}},
      color={0,131,169},
      pattern=LinePattern.Solid,
      thickness=0.5));
  connect(supply_boundary.steam_a, grid.waterPortIn_supply) annotation (Line(
      points={{-54,2},{4,2},{4,17},{64,17}},
      color={0,131,169},
      pattern=LinePattern.Solid,
      thickness=0.5));
  connect(T_supply.port, grid.waterPortIn_supply) annotation (Line(
      points={{24,42},{24,17},{64,17}},
      color={0,131,169},
      pattern=LinePattern.Solid,
      thickness=0.5));
  connect(T_return.port, grid.waterPortOut_return) annotation (Line(
      points={{22,-22},{22,7},{64,7}},
      color={0,131,169},
      pattern=LinePattern.Solid,
      thickness=0.5));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{240,100}})),
    Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{240,100}}),
                                                         graphics={Line(points={{122,-22},{122,-64},{206,-64}},
                                                                                                              color={28,108,200}),Text(
          extent={{124,-48},{204,-70}},
          lineColor={28,108,200},
          textString="Total Number of Consumers"),Line(points={{76,-22},{76,-86},{164,-88}},  color={28,108,200}),Text(
          extent={{80,-72},{160,-94}},
          lineColor={28,108,200},
          textString="Number of grid elements"),
        Text(
          extent={{68,120},{194,44}},
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
end TestGridConstructor_DHN;
