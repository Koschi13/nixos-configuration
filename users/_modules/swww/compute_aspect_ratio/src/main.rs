use anyhow::{Context, Error, Result};
use clap::Parser;
use std::fmt;
use std::str::FromStr;

#[derive(PartialEq)]
struct AspectRatio {
    x: i32,
    y: i32,
}

static COMMON_ASPECT_RATIOS: [AspectRatio; 5] = [
    AspectRatio { x: 16, y: 9 },
    AspectRatio { x: 9, y: 16 },  // rotated
    AspectRatio { x: 1, y: 1 },
    AspectRatio { x: 4, y: 3 },
    AspectRatio { x: 21, y: 9 },
];

// Even though commonly referred to as 21:9, the actual aspect ratio is 43:18
static WQHD_ASPECT_RATIO: AspectRatio = AspectRatio { x: 43, y: 18 };
static DEFAULT_ASPECT_RATIO: AspectRatio = AspectRatio { x: 16, y: 9 };

impl fmt::Display for AspectRatio {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}_{}", self.x, self.y)
    }
}

#[derive(Clone, Debug)]
struct Resolution {
    x: i32,
    y: i32,
}

impl FromStr for Resolution {
    type Err = Error;

    fn from_str(s: &str) -> Result<Self> {
        let (x, y) = s
            .split_once('x')
            .with_context(|| "Failed to split resolution at 'x'!")?;

        let x_fromstr = x.parse::<i32>().with_context(|| "Failed to parse x!")?;
        let y_fromstr = y.parse::<i32>().with_context(|| "Failed to parse y!")?;

        Ok(Resolution {
            x: x_fromstr,
            y: y_fromstr,
        })
    }
}

impl fmt::Display for Resolution {
    // This trait requires `fmt` with this exact signature.
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}x{}", self.x, self.y)
    }
}

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// A resolution which will be broken down to it's aspect ratio
    resolution: Resolution,
}

fn gcd(mut a: i32, mut b: i32) -> i32 {
    while b != 0 {
        let tmp_b = b;
        b = a % b;
        a = tmp_b;
    }
    a
}

fn main() {
    let args = Args::parse();

    let _gcd = gcd(args.resolution.x, args.resolution.y);
    let aspect_ratio = AspectRatio {
        x: args.resolution.x / _gcd,
        y: args.resolution.y / _gcd,
    };

    if COMMON_ASPECT_RATIOS.contains(&aspect_ratio) {
        println!("{aspect_ratio}");
    } else if aspect_ratio.eq(&WQHD_ASPECT_RATIO) {
        println!("{WQHD_ASPECT_RATIO}");
    } else {
        println!("{DEFAULT_ASPECT_RATIO}");
    }
}
