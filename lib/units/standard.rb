
class Numeric
  WEIGHT = {
             :pounds             =>  1.0,
             :ounces             =>  0.0625,
             :kilograms          =>  0.45359237,
             :grams              =>  453.59237
           }                     
  WEIGHT_ALIASES = {             
             :pounds             =>  [ :lb, :lbs, :pound       ],
             :ounces             =>  [ :oz, :ozs, :ounce       ],
             :kilograms          =>  [ :kg, :kgs, :kilogram    ],
             :grams              =>  [ :gm, :gms, :gram        ]
           }
  VOLUME = {
             :pints              =>  0.125, 
             :milliliters        =>  0.000264172051, 
             :cubic_feet         =>  7.48051945, 
             :cups               =>  0.0625, 
             :microliters        =>  2.64172051, 
             :cubic_inches       =>  0.00432900431, 
             :liters             =>  0.264172051, 
             :cubic_centimeters  =>  0.000264172051, 
             :cubic_yards        =>  201.974025, 
             :hectoliters        =>  26.4172051, 
             :fluid_ounces       =>  0.0078125, 
             :cubic_millimeters  =>  2.64172051, 
             :gallons            =>  1, 
             :deciliters         =>  0.0264172051, 
             :tablespoons        =>  0.00390625, 
             :cubic_meters       =>  264.172051, 
             :quarts             =>  0.25, 
             :centiliters        =>  0.00264172051, 
             :teaspoons          =>  0.00130208333, 
             :cubic_decimeters   =>  0.264172051
           }
  VOLUME_ALIASES = {
             :liters             => [ :liter, :l              ],
             :hectoliters        => [ :hectoliter, :hl        ],
             :deciliters         => [ :deciliter, :dl         ],
             :centiliters        => [ :centiliter, :cl        ],
             :milliliters        => [ :milliliter, :ml        ],
             :microliters        => [ :microliter, :ul        ],
             :cubic_centimeters  => [ :cubic_centimeter, :cm3 ],
             :cubic_millimeters  => [ :cubic_millimeter, :mm3 ],
             :cubic_meters       => [ :cubic_meter, :m3       ],
             :cubic_decimeters   => [ :cubic_decimeter, :dm3  ],
             :cubic_feet         => [ :cubic_foot, :f3        ],
             :cubic_inches       => [ :cubic_inch, :i3        ],
             :cubic_yards        => [ :cubic_yard, :y3        ],
             :gallons            => [ :gallon, :gal, :gals    ],
             :quarts             => [ :quart, :qt, :qts       ],
             :pints              => [ :pint, :pt, :pts        ],
             :cups               => [ :cup                    ],
             :gills              => [ :gill                   ],
             :fluid_ounces       => [ :fluid_oz, :fluid_ozs   ],
             :tablespoons        => [ :tablespoon, :tbsp      ],
             :teaspoons          => [ :teaspoon, :tsp         ],
             :fluid_drams        => [ :fluid_dram             ],
             :minims             => [ :minim                  ]
           }
  TIME =   {                     
             :seconds            =>  1.0,
             :minutes            =>  60.0,
             :hours              =>  3600.0,
             :days               =>  86400.0,
             :weeks              =>  604800.0,
             :years              =>  31449600.0
           }                   
  TIME_ALIASES = {             
             :seconds            =>  [ :sec, :second         ],
             :minutes            =>  [ :min, :mins, :minute  ],
             :hours              =>  [ :hour                 ],
             :days               =>  [ :day                  ],
             :weeks              =>  [ :week                 ],
             :years              =>  [ :year                 ]
           }
  SIZE =   {
             :bytes              =>  1.0,
             :bits               =>  8.0,
             :kilobytes          =>  1024.0,
             :megabytes          =>  1048576.0,
             :gigabytes          =>  1073741824.0,
             :terabytes          =>  1099511627776.0,
             :petabytes          =>  1.12589991e15
           }                     
  SIZE_ALIASES = {               
             :bits               =>  [ :bit                  ],
             :bytes              =>  [ :b, :byte             ],
             :kilobytes          =>  [ :kb, :kilobyte        ],
             :megabytes          =>  [ :mb, :megabyte        ],
             :gigabytes          =>  [ :gb, :gigabyte        ],
             :terabytes          =>  [ :tb, :terabyte        ],
             :petabytes          =>  [ :pb, :petabyte        ]
           }                     
  LENGTH = {                     
             :inches             =>  1.0,
             :feet               =>  12.0,
             :meters             =>  39.3700787,
             :kilometers         =>  39370.0787,
             :milimeters         =>  0.0393700787,
             :centimeters        =>  0.393700787,
             :miles              =>  63360.0
           }
  LENGTH_ALIASES = {
             :inches             =>  [ :inch                 ],
             :feet               =>  [ :foot                 ],
             :miles              =>  [ :mile                 ],
             :meters             =>  [ :m, :meter            ],
             :kilometers         =>  [ :km, :kilometer       ],
             :milimeters         =>  [ :mm, :milimeter       ],
             :centimeters        =>  [ :cm, :centimeter      ]
           }
  
  add_unit_conversions(
    :weight => WEIGHT,
    :volume => VOLUME,
    :time   => TIME,
    :size   => SIZE,
    :length => LENGTH
  )

  add_unit_aliases(
    :weight => WEIGHT_ALIASES,
    :volume => VOLUME_ALIASES,
    :time => TIME_ALIASES,
    :size => SIZE_ALIASES,
    :length => LENGTH_ALIASES
  )
  
end

class Float #:nodoc:
  alias :_to_i :to_i
  def to_i
    case kind
    when :time
      to_seconds._to_i
    when :size
      to_bytes._to_i
    end
  end

  alias :_to_int :to_int
  def to_int
    case kind
    when :time
      to_seconds._to_int
    when :size
      to_bytes._to_int
    end
  end
end
