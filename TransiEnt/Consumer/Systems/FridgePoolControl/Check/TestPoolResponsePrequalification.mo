﻿within TransiEnt.Consumer.Systems.FridgePoolControl.Check;
model TestPoolResponsePrequalification



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
// Gas- und WÃ¤rme-Institut Essen						  //
// and                                                                            //
// XRG Simulation GmbH (Hamburg, Germany).                                        //
//________________________________________________________________________________//




  extends TransiEnt.Basics.Icons.Checkmodel;
  TransiEnt.Components.Boundaries.Electrical.ActivePower.Frequency electricGrid(useInputConnector=true) annotation (Placement(transformation(extent={{36,-10},{56,10}})));
  parameter Integer n=100;
  Pool.FridgePool fridgePool(
    dbf=0.4,
    poolSize=n,
    uniqueParams=[296.894230351112,277.752079706517,2.1373903341986,278.350924179405,5319.66408203364,5319.66408203364,0.540774425404625,4800.19218224487,1.60338629730114; 294.072744468235,278.280541624297,1.71424139698245,278.002121160517,5282.91701319315,5282.91701319315,0.539944349607836,4799.17770672371,1.86874453689656; 297.315831276262,279.350106499839,2.22387701303553,279.589987011492,4487.56428643308,4487.56428643308,0.506010264097818,4799.90575941204,1.79892727554609; 292.355452290296,279.38481216266,1.74661625426035,279.806190406926,4923.3869555683,4923.3869555683,0.528562381485724,4800.33621334095,2.13157904517332; 290.443193091984,279.421007651357,1.32886409460121,278.895858157954,4346.69865292597,4346.69865292597,0.52063980051557,4799.09534594075,1.87142273502738; 290.382872224725,279.071829208113,1.04195171634962,278.684106866754,4165.54150973157,4165.54150973157,0.450651905832424,4799.71174363879,1.88824589759893; 296.11458172958,279.260213457517,1.59997787982088,
        279.339476532905,5243.91644807698,5243.91644807698,0.537978416295739,4800.35006275753,1.68953618891861; 294.117874530144,278.864308190029,1.91406299076922,278.836036347649,4800.02392755612,4800.02392755612,0.467139935045082,4798.1641408575,1.44809051947075; 294.061839536578,279.667212966934,1.79522231997035,280.368203621612,4773.63892098749,4773.63892098749,0.469804075931192,4801.03597590825,1.61318017545043; 298.907930451928,278.332983317477,1.82408311708794,278.87831171474,5237.34108751385,5237.34108751385,0.508847341116471,4802.42446114494,1.54359745503021; 295.524753121953,279.423017733867,1.52687432490862,279.780827117833,5085.40017475635,5085.40017475635,0.484624826506862,4800.95940050941,1.57848559493506; 295.243433160393,278.64077437204,1.74320054042134,277.858655873441,4968.09656345978,4968.09656345978,0.493408982354205,4799.68422800499,1.77992494080033; 299.413097269922,278.949067836622,1.20840028101983,278.432942312025,5400.1205895864,5400.1205895864,
        0.529767883694205,4800.42862267986,1.57977994848893; 292.236602130951,279.481670007567,1.47197300040942,278.875993537798,5246.2989401077,5246.2989401077,0.552341639215262,4798.96401522149,1.51887963561316; 296.739873247549,279.773454392103,1.45436207112492,280.207364572758,4915.08636338812,4915.08636338812,0.490102068369408,4801.8778654605,1.60632101010587; 297.155264495218,278.479416790041,1.85591866644009,279.301603865655,4468.62667050661,4468.62667050661,0.51638390819536,4800.94070440335,1.65104038198708; 293.918854578866,279.906395225473,1.69575198227084,280.217931271558,4487.25425195987,4487.25425195987,0.488084924770513,4800.78734577994,1.75368019748198; 295.297010259211,279.546085884628,1.35334118951383,279.048168594271,5372.20889785501,5372.20889785501,0.511479844661016,4799.12412573804,1.5085255205184; 291.152468205554,279.109280667874,1.69714252517055,279.487275955525,4026.32141343465,4026.32141343465,0.521999895241131,4800.31994913438,1.73711714501843;
        291.206141663304,279.032867281261,1.49305683871049,278.451102880854,4788.25827041476,4788.25827041476,0.469156703555539,4799.44170571515,1.69404361457605; 294.964624148049,279.019436189914,1.49999025391965,278.445679196087,3864.55335508853,3864.55335508853,0.513741839345583,4799.68857058145,1.91838938084884; 296.816762096675,278.968135427189,1.95924482634954,279.243836289735,5289.83904693727,5289.83904693727,0.530055101623415,4799.42999008336,1.64162931244411; 302.406473757849,279.163827374655,1.73402583086806,278.866986801166,5213.62382514884,5213.62382514884,0.504615397561948,4798.97426638437,1.65579384398002; 292.649327987896,279.180774213509,1.8195088538498,279.460636550451,4800.55780007209,4800.55780007209,0.586492069578618,4799.09125441313,1.46915595277435; 295.211993073737,279.645637674127,1.9651909670704,280.135228575031,4765.99813768297,4765.99813768297,0.469572127763084,4799.79010266594,1.43065271702486; 294.402516723887,280.06618601204,1.75407730819611,
        280.212100215951,3606.58371806243,3606.58371806243,0.46314701141511,4798.30113591583,1.73589149734809; 288.850931246447,279.430148661411,1.86525635661724,279.877870486984,5078.96271488444,5078.96271488444,0.412506034680619,4800.60760057585,1.63509196839469; 293.333101538196,279.024171996967,1.90488928283358,278.519046628774,3747.63123841637,3747.63123841637,0.545524128982356,4799.88220171073,1.77067393003272; 289.265963475635,279.525114214253,2.05118259801068,280.007055035051,3686.74545281121,3686.74545281121,0.543354127647366,4800.69916033364,1.51932094737413; 297.171126589262,279.259936357801,1.8427581761835,280.127135637604,4838.36818094325,4838.36818094325,0.496005358047098,4800.26964864172,2.02353221946448; 291.985903753013,278.53213947386,2.12366980593335,279.311378255336,4344.72912788616,4344.72912788616,0.544923799468857,4800.49428705538,1.70200152609088; 294.950278499418,279.719533098679,1.70678254529288,279.013325416405,4997.51549828322,4997.51549828322,
        0.509185171154562,4798.51687897748,1.86846598804163; 293.016413210028,279.334237151488,1.68563917693394,279.109097479352,5124.94934672833,5124.94934672833,0.514539506744223,4798.97973561432,1.63915436412169; 295.560562383948,279.23110496526,2.21040039628249,278.941981950516,5211.71162169857,5211.71162169857,0.505647235851053,4799.55300498926,1.65074965052127; 292.849020313599,279.459147801315,1.54708648616977,279.745402850926,4468.24361981616,4468.24361981616,0.521997609443622,4800.10965859133,1.80420934161441; 296.119895963522,279.306843794433,1.6991435119567,279.473260688746,5015.70125912009,5015.70125912009,0.505083122185017,4801.12873645203,1.78003621885418; 296.868089370813,278.585108537427,1.97596012394192,279.15688015137,4848.30400815124,4848.30400815124,0.639366761390672,4799.7100369592,1.47835409973209; 299.785663348945,279.052597396318,1.74494261978983,278.821659333095,5196.51359926556,5196.51359926556,0.441666748490268,4801.26155071814,1.40411525749269;
        294.067629392725,279.062367219401,2.12148003370309,278.438711192876,5057.35539836444,5057.35539836444,0.407285045865515,4800.47542481171,1.48238380148268; 288.23493419168,278.830793173915,2.01023646187091,277.999895196578,5230.98644447284,5230.98644447284,0.442965942766518,4801.17411675149,1.42516080211777; 292.13123375799,280.159262156798,1.78747108663124,280.645336171087,4736.6698233962,4736.6698233962,0.44533282718802,4800.12694706804,1.69072270594189; 298.713782984014,278.624562392304,1.46669043850652,278.192878027127,4729.34330104739,4729.34330104739,0.478319535176259,4799.34318407105,1.6059748334042; 291.433534134847,278.859710969934,1.87000882926179,278.650777933514,5283.73123454661,5283.73123454661,0.491576506086228,4798.51860092842,1.61375806805263; 297.532861609222,278.722797270583,1.28521365215589,278.789343746744,3780.64537804044,3780.64537804044,0.489073321998671,4800.1554889959,1.43502663670914; 295.02214940001,278.445472601126,1.77334240267697,277.964813909831,
        4557.79852535328,4557.79852535328,0.527066721785969,4800.81855136852,1.82032213717229; 298.960089868157,279.034656289476,1.94253164095031,279.310380435738,4190.11466409184,4190.11466409184,0.519463310192163,4799.70741186917,1.75909400007967; 288.767300001905,278.98555786204,1.7639125095251,278.95818259677,4616.35929470033,4616.35929470033,0.537561449234417,4799.45921358351,1.66386795292658; 294.056905322078,280.068043508654,1.96390314927005,279.384301838998,5111.36604578334,5111.36604578334,0.58891279496455,4799.69135818472,1.86381242124255; 291.026463544221,279.000585154492,2.31166287542421,279.652316815049,5196.34903163604,5196.34903163604,0.56115312758669,4798.90340669847,1.5226836962948; 303.374024092188,278.511471952266,1.97717973460668,277.721798866711,4312.82705151353,4312.82705151353,0.435837194769762,4799.50699018468,1.75464605274857; 297.125656682685,280.112074378872,1.78007523397875,279.745496959753,4573.88644191208,4573.88644191208,0.383552274185833,
        4799.81926064359,1.74271941599141; 298.78691593375,279.890807488134,1.89249845192653,279.393786334493,4865.77193958242,4865.77193958242,0.545096573347586,4800.04584110571,1.74286579499947; 291.475459226038,279.012224129422,1.82764560668759,279.068647674348,4659.90557963828,4659.90557963828,0.40821806581324,4799.93621687998,1.54873549182669; 293.244153256698,278.246304177612,1.30558294895393,277.712971886623,4944.87290652528,4944.87290652528,0.503337845571843,4800.61133519406,1.73883124477734; 293.832591772249,278.883223310132,1.57507663409017,278.734087840377,4991.96685261879,4991.96685261879,0.501773974291879,4800.10931769377,1.58732130607323; 297.945273853666,279.056435378565,2.0674063474356,278.239492001639,4353.61845170874,4353.61845170874,0.611358403908394,4801.81401545028,1.51863969290955; 293.816384201637,279.315640952359,1.6869247383361,278.66159317667,4715.12147235397,4715.12147235397,0.496539287298898,4800.31202382833,1.4634117264453; 296.75462437449,278.993301812534,
        1.87472698323439,279.526526454096,3776.59459240246,3776.59459240246,0.474633846769275,4801.80449377172,1.86680681510734; 288.494551100267,279.416053147742,1.3980499776142,279.124658035358,5349.77362104887,5349.77362104887,0.511790483628812,4799.27687852043,1.5277300417795; 293.588450006677,279.385136525659,1.71935502269333,279.563147263592,4498.03643472281,4498.03643472281,0.512290242594692,4800.52654703775,1.64887550803335; 292.179240424529,278.399592655904,1.88008758475574,279.272747946616,4222.15201247893,4222.15201247893,0.50350226047084,4799.73974913829,1.46244263014676; 289.918828931602,278.581223446601,1.29154551354063,278.494024743467,4678.10655195705,4678.10655195705,0.469570974496003,4800.60014250881,1.62651717600083; 296.173923952718,278.705336343636,1.80427778958802,279.056723402858,4114.24950497659,4114.24950497659,0.438870330990669,4800.59393079565,1.0982331967308; 295.495952191012,278.845309469833,1.6454470344622,279.269998156955,4789.98834350323,
        4789.98834350323,0.515825018039886,4797.81397838725,1.48434733869696; 294.750439646733,278.95765469604,1.41813957021755,278.862132113391,4530.88080166647,4530.88080166647,0.432856538168903,4798.67295685048,1.42324149129365; 290.648966169716,279.157481424817,1.68874004335425,279.420077191296,5845.33378040839,5845.33378040839,0.448390782796391,4798.55898640236,1.49739886181304; 298.032476835025,277.332493595157,1.13110865191326,276.891084156665,5346.46338591821,5346.46338591821,0.566560794253249,4800.40184449704,1.64161190610468; 295.70053823181,278.875791215477,1.0616069695452,279.336273693632,3601.49447847144,3601.49447847144,0.479054840248508,4801.47020128085,1.62143739953511; 293.752801909001,279.895469043834,1.34692300078551,279.474502815357,5011.83692722925,5011.83692722925,0.492983913897182,4799.67318577121,2.02999160255393; 294.718669378255,278.509979160609,1.40284033385475,278.18196540492,4128.89381961068,4128.89381961068,0.544991116444861,4800.81232300464,
        1.5770808206971; 293.864013695102,279.710236897603,1.34809030181978,280.111738982982,4677.57351365721,4677.57351365721,0.484994449719216,4800.54554010353,1.63499418995369; 289.39936289466,279.360192600814,1.18237166314139,279.345535656157,4878.91395519299,4878.91395519299,0.551468285605155,4798.94836769048,1.39752321533867; 293.793047085214,279.132596541775,1.7864684268995,279.61308198867,5158.9123338279,5158.9123338279,0.482746701421634,4800.3974669958,1.59407112053507; 292.155900465297,279.259471300504,1.22174488391996,279.132418073511,4668.93746428661,4668.93746428661,0.550640093213149,4799.24810526132,1.43916420235879; 291.712381084498,278.21096639151,1.73306565476701,277.817454414075,5556.62407034212,5556.62407034212,0.531466729246571,4801.51626689665,1.68545382428187; 291.180795033008,279.099276312109,1.93612000290739,278.20330703048,4569.15016714615,4569.15016714615,0.489349245867947,4799.96743349081,1.83355561815334; 293.049328672052,280.112367810362,1.69933196410585,
        280.406853397124,4957.20581799825,4957.20581799825,0.456715134581974,4801.63599965728,1.75276562371968; 288.642092792351,279.209008664784,1.72793262801764,279.087300795753,5119.07237790125,5119.07237790125,0.447844584933119,4799.57494150939,1.55388836158472; 297.542688267895,279.174824168094,1.58655288302307,279.098255912095,4840.89052450616,4840.89052450616,0.486496559367595,4800.58943336672,1.3865022793055; 296.210180304366,278.709498532382,1.2551971666823,278.847390940015,5222.8573369829,5222.8573369829,0.478092932219893,4799.93720877428,1.94280237332568; 294.589916445072,279.131511761993,1.68685442439251,278.388289263925,4955.14230616685,4955.14230616685,0.479566284260184,4797.97804106995,2.04900769192882; 294.545686741915,279.289408207575,1.98824756350463,278.923195748626,4423.60983184124,4423.60983184124,0.549177261760278,4799.01786847422,1.70169010794589; 292.255509246308,279.405832534445,2.221473479784,280.011677515508,3933.42079133468,3933.42079133468,
        0.485115142799531,4800.61251129817,1.50181771124019; 297.706055846386,278.926314754966,1.57093812727217,279.23489882685,5692.12461530674,5692.12461530674,0.557183945538548,4799.94511387001,1.89559886537668; 294.250347561477,279.008127249746,1.21180317905907,278.554103595723,4509.82555738826,4509.82555738826,0.473418994124647,4798.88126799755,1.57332188072953; 292.506409508639,280.364214531962,1.74990424773802,279.717014983979,4849.61266670911,4849.61266670911,0.548628286400433,4799.37362146113,1.5954343146196; 298.70415730528,277.794987617702,1.81287977313522,277.055971418,5070.32013847007,5070.32013847007,0.473887475750323,4800.24951774056,1.83954792787308; 293.975686831842,280.487667408274,1.63191486058813,279.68447203127,4854.52655843232,4854.52655843232,0.508828889732116,4799.00698099345,1.43066043580005; 292.882912907838,279.352538220368,1.35532631311436,279.248326346849,4365.73141785694,4365.73141785694,0.548536891177734,4800.97495022481,1.32778428823825;
        293.768739206794,279.750036491753,2.30729977986316,280.10899044404,4575.49700042311,4575.49700042311,0.479301386251288,4799.35929049327,1.75572306603622; 292.106221269086,278.151501315008,0.992142946712453,278.372672325544,4740.05282533291,4740.05282533291,0.478086474089755,4801.80886262052,1.75213283966645; 291.289615096269,278.795979261477,1.54700838626002,278.844260300378,5509.90007592193,5509.90007592193,0.600169530543113,4798.92013374926,1.69712558841555; 302.227999076355,278.983161501741,1.30351232275697,278.473250863838,4386.80846879666,4386.80846879666,0.547549674977454,4800.19918944408,1.76940319049458; 299.616492778662,279.403629414732,1.50916152510199,279.602486155964,5176.64086429815,5176.64086429815,0.478399807813611,4798.47897343823,1.87480330730892; 295.572605477715,278.14787958129,1.79535542571791,277.477314088002,4948.13910717529,4948.13910717529,0.532447036868179,4799.27636887471,1.85468060190382; 290.878644921944,279.43298059585,1.74141439233486,
        278.796151106752,4687.74717977801,4687.74717977801,0.481996184942301,4799.40674968499,1.57765747732987; 292.053595908336,278.422291680195,1.48677947755663,277.825489615068,4292.65308193914,4292.65308193914,0.535294250967471,4800.40133633982,1.82579497319734; 294.120397657306,279.189714029055,1.93310105801594,278.497716524258,4663.61234177944,4663.61234177944,0.570792453421829,4800.94213331924,1.71118452692978; 297.024248184886,279.541413533197,1.8867181772516,278.915497227781,4758.38866441953,4758.38866441953,0.419774216570147,4800.3004859676,1.58900233766723; 290.653986736054,279.346235980306,1.89421426535481,278.770866355728,4094.69036424655,4094.69036424655,0.551442653450101,4799.62692934137,1.46520495763976],
    startStatus={false,false,false,true,true,false,false,false,false,false,false,false,false,false,true,false,false,false,true,false,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,false,false,false,false,false,false,false,true,false,false,false,true,false,false,false,false,false,false,false,true,true,false,false,true,false,false,false,false,false,false,false,false,false,false,true,false,false,false,false,false,false,false,false,false,false,false,false,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false})
                                                                                                                                                                                              annotation (Placement(transformation(extent={{-50,-28},{14,28}})));

  inner SimCenter simCenter annotation (Placement(transformation(extent={{-90,80},{-70,100}})));
  Modelica.Blocks.Sources.TimeTable f_grid(table=[0,50; 6000,50; 6000,49.8; 6900,49.8; 6900,50]) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={24,38})));
equation
  connect(fridgePool.epp, electricGrid.epp) annotation (Line(
      points={{10.48,0},{24,0},{24,0},{36,0}},
      color={0,135,135},
      thickness=0.5));
public
function plotResult

  constant String resultFileName = "TestPoolResponsePrequalification.mat";

  output String resultFile;

algorithm
  clearlog();
    assert(cd(Modelica.Utilities.System.getEnvironmentVariable(Basics.Types.WORKINGDIR)), "Error changing directory: Working directory must be set as environment variable with name 'workingdir' for this script to work.");
  resultFile :=TransiEnt.Basics.Functions.fullPathName(Modelica.Utilities.System.getEnvironmentVariable(Basics.Types.WORKINGDIR) + "/" + resultFileName);
  removePlots();
createPlot(id=1, position={475, 0, 458, 679}, y={"fridgePool.epp.P"}, range={0.0, 8000.0, 6000.0, 20000.0}, grid=true, colors={{28,108,200}},filename=resultFile);
createPlot(id=1, position={475, 0, 458, 337}, y={"electricGrid.epp.f"}, range={0.0, 8000.0, 44.0, 56.0}, grid=true, subPlot=2, colors={{28,108,200}},filename=resultFile);
  resultFile := "Successfully plotted results for file: " + resultFile;

end plotResult;
equation
  connect(f_grid.y, electricGrid.f_set) annotation (Line(points={{35,38},{40.6,38},{40.6,12}}, color={0,0,127}));
  annotation (Diagram(graphics,
                      coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}})), experiment(StopTime=10000),
    Documentation(info="<html>
<h4><span style=\"color: #008000\">1. Purpose of model</span></h4>
<p>Test environment for the FridgePool model</p>
<h4><span style=\"color: #008000\">2. Level of detail, physical effects considered, and physical insight</span></h4>
<p>(Purely technical component without physical modeling.)</p>
<h4><span style=\"color: #008000\">3. Limits of validity </span></h4>
<p>(Purely technical component without physical modeling.)</p>
<h4><span style=\"color: #008000\">4.Interfaces</span></h4>
<p>(no remarks)</p>
<h4><span style=\"color: #008000\">5. Nomenclature</span></h4>
<p>(no elements)</p>
<h4><span style=\"color: #008000\">6. Governing Equations</span></h4>
<p>(no equations)</p>
<h4><span style=\"color: #008000\">7. Remarks for Usage</span></h4>
<p>(no remarks)</p>
<h4><span style=\"color: #008000\">8. Validation</span></h4>
<p>(no validation or testing necessary)</p>
<h4><span style=\"color: #008000\">9. References</span></h4>
<p>(no remarks)</p>
<h4><span style=\"color: #008000\">10. Version History</span></h4>
</html>"));
end TestPoolResponsePrequalification;
