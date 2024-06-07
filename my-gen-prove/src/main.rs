use ark_bn254::Bn254;
use ark_circom::CircomBuilder;
use ark_circom::CircomConfig;
use ark_groth16::Groth16;
use ark_serialize::CanonicalSerialize;
use ark_serialize::Read;
use ark_snark::SNARK;
use num_bigint::BigInt;
use serde::Deserialize;

#[derive(Deserialize, Debug)]
struct ShuffleEncryptInput {
    pk: Vec<String>,
    A: Vec<String>,
    R: Vec<String>,
    UX0: Vec<String>,
    UX1: Vec<String>,
    UDelta0: Vec<String>,
    UDelta1: Vec<String>,
    VX0: Vec<String>,
    VX1: Vec<String>,
    VDelta0: Vec<String>,
    VDelta1: Vec<String>,
    s_u: Vec<String>,
    s_v: Vec<String>,
}

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    // Load the WASM and R1CS for witness and proof generation
    let cfg = CircomConfig::<Bn254>::new(
        "./prove/shuffle_encrypt_js/shuffle_encrypt.wasm",
        "./prove/shuffle_encrypt.r1cs",
    )
    .unwrap();

    let file = std::fs::File::open("./input/shuffle_encrypt_input.json")?;
    let shuffle_encrypt_input: ShuffleEncryptInput = serde_json::from_reader(file)?;
    println!("shuffle_encrypt_input is:{:?}", shuffle_encrypt_input);

    // Insert our secret inputs as key value pairs. We insert a single input, namely the input to the hash function.
    let mut builder = CircomBuilder::new(cfg);
    for input_value in shuffle_encrypt_input.pk {
        builder.push_input(
            "pk",
            BigInt::parse_bytes(input_value.as_bytes(), 10).unwrap(),
        );
    }
    for input_value in shuffle_encrypt_input.A {
        builder.push_input(
            "A",
            BigInt::parse_bytes(input_value.as_bytes(), 10).unwrap(),
        );
    }
    for input_value in shuffle_encrypt_input.R {
        builder.push_input(
            "R",
            BigInt::parse_bytes(input_value.as_bytes(), 10).unwrap(),
        );
    }
    for input_value in shuffle_encrypt_input.UX0 {
        builder.push_input(
            "UX0",
            BigInt::parse_bytes(input_value.as_bytes(), 10).unwrap(),
        );
    }
    for input_value in shuffle_encrypt_input.UX1 {
        builder.push_input(
            "UX1",
            BigInt::parse_bytes(input_value.as_bytes(), 10).unwrap(),
        );
    }
    for input_value in shuffle_encrypt_input.UDelta0 {
        builder.push_input(
            "UDelta0",
            BigInt::parse_bytes(input_value.as_bytes(), 10).unwrap(),
        );
    }
    for input_value in shuffle_encrypt_input.UDelta1 {
        builder.push_input(
            "UDelta1",
            BigInt::parse_bytes(input_value.as_bytes(), 10).unwrap(),
        );
    }
    for input_value in shuffle_encrypt_input.VX0 {
        builder.push_input(
            "VX0",
            BigInt::parse_bytes(input_value.as_bytes(), 10).unwrap(),
        );
    }
    for input_value in shuffle_encrypt_input.VX1 {
        builder.push_input(
            "VX1",
            BigInt::parse_bytes(input_value.as_bytes(), 10).unwrap(),
        );
    }
    for input_value in shuffle_encrypt_input.VDelta0 {
        builder.push_input(
            "VDelta0",
            BigInt::parse_bytes(input_value.as_bytes(), 10).unwrap(),
        );
    }
    for input_value in shuffle_encrypt_input.VDelta1 {
        builder.push_input(
            "VDelta1",
            BigInt::parse_bytes(input_value.as_bytes(), 10).unwrap(),
        );
    }
    for input_value in shuffle_encrypt_input.s_u {
        builder.push_input(
            "s_u",
            BigInt::parse_bytes(input_value.as_bytes(), 10).unwrap(),
        );
    }
    for input_value in shuffle_encrypt_input.s_v {
        builder.push_input(
            "s_v",
            BigInt::parse_bytes(input_value.as_bytes(), 10).unwrap(),
        );
    }

    // Create an empty instance for setting it up
    let circom = builder.setup();

    // WARNING: The code below is just for debugging, and should instead use a verification key generated from a trusted setup.
    // See for example https://docs.circom.io/getting-started/proving-circuits/#powers-of-tau.
    let mut rng = rand::thread_rng();
    let params =
        Groth16::<Bn254>::generate_random_parameters_with_reduction(circom, &mut rng).unwrap();

    let mut vk_bytes = Vec::new();
    params.vk.serialize_compressed(&mut vk_bytes).unwrap();

    let vk_hex = hex::encode(&vk_bytes);
    println!("vk_hex is  h16: {}",vk_hex);

    let circom = builder.build().unwrap();

    // There's only one public input, namely the hash digest.
    let inputs = circom.get_public_inputs().unwrap();

    let mut public_inputs_bytes = Vec::new();

    for i in 0..inputs.len(){
        inputs[i].serialize_compressed(&mut public_inputs_bytes).unwrap();
    }

    let public_inputs_str = hex::encode(&public_inputs_bytes);
    println!("public_inputs_str is h16: {}",public_inputs_str);
    // Generate the proof
    let proof = Groth16::<Bn254>::prove(&params, circom, &mut rng).unwrap();

    let mut proof_points_bytes = Vec::new();
    proof.serialize_compressed(&mut proof_points_bytes).unwrap();

    let proof_points_str = hex::encode(&proof_points_bytes);
    println!("proof_points_str is h16: {}",proof_points_str);

    // Check that the proof is valid
    let pvk = Groth16::<Bn254>::process_vk(&params.vk).unwrap();
    let verified = Groth16::<Bn254>::verify_with_processed_vk(&pvk, &inputs, &proof).unwrap();
    assert!(verified);

    // println!("vk_bytes:");
    // for k in &vk_bytes  {
    //     print!("{}",k);
    // }
    // println!("");

    // println!("vk_bytes:");
    // for k in &public_inputs_bytes  {
    //     print!("{}",k);
    // }
    // println!("");

    // println!("vk_bytes:");
    // for k in &proof_points_bytes  {
    //     print!("{}",k);
    // }
    // println!("");

    Ok(())
}
