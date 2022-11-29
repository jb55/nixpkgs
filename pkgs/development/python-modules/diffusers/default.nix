{ lib
, buildPythonPackage
, fetchFromGitHub

# propagates
, filelock
, huggingface-hub
, importlib-metadata
, numpy
, pillow
, regex
, requests
, torch

# tests
, pytest-timeout
, pytest-xdist
, pytestCheckHook
, scipy
, torchvision
, transformers
, sentencepiece
, parameterized
, accelerate
, black
, hf-doc-builder

}:

buildPythonPackage rec {
  pname = "diffusers";
  version = "0.9.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-9bDAfvwWQ2ja2Yx72ZdGAmHUvnh0/LXlub9aGP7uiZo=";
  };

  propagatedBuildInputs = [
    filelock
    huggingface-hub
    importlib-metadata
    numpy
    pillow
    regex
    requests
    torch
  ];

  pythonImportsCheck = [
    "diffusers"
  ];

  checkInputs = [
    pytest-timeout
    pytest-xdist
    pytestCheckHook
    scipy
    torchvision
    transformers
    sentencepiece
    parameterized
    accelerate
    black
    hf-doc-builder
  ];

  preCheck = ''
    export HOME=$TMPDIR
     
    # requires features from transformers-main, remove this after transformers is updated
    rm tests/pipelines/stable_diffusion/test_stable_diffusion_image_variation.py
  '';

  disabledTests = [
    # requires network access
    "test_alt_diffusion_ddim"
    "test_alt_diffusion_pndm"
    "test_download_no_safety_checker"
    "test_download_only_pytorch"
    "test_from_pretrained_hub"
    "test_inference_text2img"
    "test_load_custom_pipeline"
    "test_load_ddim_from_pndm"
    "test_load_dpmsolver"
    "test_load_euler_ancestral_from_pndm"
    "test_load_euler_from_pndm"
    "test_load_no_safety_checker_default_locally"
    "test_load_no_safety_checker_explicit_locally"
    "test_load_pndm"
    "test_local_custom_pipeline_file"
    "test_local_custom_pipeline_repo"
    "test_optional_components"
    "test_output_pretrained"
    "test_output_pretrained_ve_large"
    "test_output_pretrained_ve_mid"
    "test_overwrite_config_on_load"
    "test_run_custom_pipeline"
    "test_safe_diffusion_ddim"
    "test_save_pretrained_from_pretrained"
    "test_set_scheduler"
    "test_set_scheduler_consistency"
    "test_stable_diffusion_attention_chunk"
    "test_stable_diffusion_components"
    "test_stable_diffusion_cycle"
    "test_stable_diffusion_ddim"
    "test_stable_diffusion_height_width_opt"
    "test_stable_diffusion_img2img_default_case"
    "test_stable_diffusion_img2img_default_case"
    "test_stable_diffusion_img2img_k_lms"
    "test_stable_diffusion_img2img_multiple_init_images"
    "test_stable_diffusion_img2img_negative_prompt"
    "test_stable_diffusion_img2img_num_images_per_prompt"
    "test_stable_diffusion_inpaint"
    "test_stable_diffusion_inpaint_legacy"
    "test_stable_diffusion_inpaint_with_num_images_per_prompt"
    "test_stable_diffusion_k_euler"
    "test_stable_diffusion_k_euler_ancestral"
    "test_stable_diffusion_k_lms"
    "test_stable_diffusion_long_prompt"
    "test_stable_diffusion_negative_prompt"
    "test_stable_diffusion_no_safety_checker"
    "test_stable_diffusion_num_images_per_prompt"
    "test_stable_diffusion_pndm"
    "test_stable_diffusion_upscale"
    "test_stable_diffusion_v_pred_ddim"
    "test_stable_diffusion_v_pred_k_euler"
    "test_vq_diffusion"
    "test_vq_diffusion_classifier_free_sampling"

    # too much noise
    "test_full_loop_no_noise"
  ];

  meta = with lib; {
    changelog = "https://github.com/huggingface/diffusers/releases/tag/v${version}";
    description = "State-of-the-art diffusion models for image and audio generation in PyTorch";
    homepage = "https://github.com/huggingface/diffusers";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa jb55 ];
  };
}
