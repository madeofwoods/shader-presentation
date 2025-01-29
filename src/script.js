import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import GUI from "lil-gui";
import vertexShader from "./shaders/test/vertex.glsl";
import fragmentShader from "./shaders/test/fragment.glsl";
import framgmentJW from "./shaders/test/fragmentJW.glsl";
import watervertex from "./shaders/water/watervertex.glsl";
import waterfragment from "./shaders/water/waterfragment.glsl";

/**
 * Base
 */
// Debug
const gui = new GUI();

// Canvas
const canvas = document.querySelector("canvas.webgl");

// Scene
const scene = new THREE.Scene();

/**
 * Textures
 */
const textureLoader = new THREE.TextureLoader();
const flagTexture = textureLoader.load("/textures/jw-flag.jpg");

/**
 * Test mesh
 */

const shaderControls = {
  toggleTime: false, // Determines whether `uTime` updates or stays at 0
  enableElevation: false,
  texture: false,
  toggleUV: false,
  wireframe: false,
  jw: false,
  water: false,
};
// Geometry
const geometrySizes = { size: 1, segments: 32 };
let geometry = shaderControls.water
  ? new THREE.PlaneGeometry(2, 2, 128, 128)
  : new THREE.PlaneGeometry(geometrySizes.size, geometrySizes.size, geometrySizes.segments, geometrySizes.segments);

// Water
const waterColors = {
  depthColor: "#258ac1",
  surfaceColor: "#9bd8ff",
};

// aRandom
const count = geometry.attributes.position.count;
const randoms = new Float32Array(count);

for (let i = 0; i < count; i++) {
  randoms[i] = Math.random();
}

geometry.setAttribute("aRandom", new THREE.BufferAttribute(randoms, 1));

// Material
const material = new THREE.ShaderMaterial({
  vertexShader: vertexShader,
  fragmentShader: fragmentShader,
  wireframe: false,
  side: THREE.DoubleSide,
  uniforms: {
    uResolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
    uFrequency: { value: new THREE.Vector2(0, 0) },
    uTime: { value: 0 },
    uColor: { value: new THREE.Color("blue") },
    uTexture: { value: flagTexture },
    uEnableElevation: { value: 0 },
    uToggleTexture: { value: 0 },
    uToggleUV: { value: 0 },
    uRandom: { value: 0.5 },
    uBigWavesElevation: { value: 0.2 },
    uWater: { value: 0 },
    uDepthColor: { value: new THREE.Color(waterColors.depthColor) },
    uSurfaceColor: { value: new THREE.Color(waterColors.surfaceColor) },
    uColorOffset: { value: 0.08 },
    uColorMultiplier: { value: 5.0 },
    uSmallWavesElevation: { value: 0.15 },
    uSmallWavesFrequency: { value: 3.0 },
    uSmallWavesSpeed: { value: 0.2 },
    uSmallWavesIterations: { value: 4.0 },
  },
});

// Debug

gui.add(material.uniforms.uFrequency.value, "x").min(0).max(20).step(0.01).name("frequencyX");
gui.add(material.uniforms.uFrequency.value, "y").min(0).max(20).step(0.01).name("frequencyY");
gui.add(shaderControls, "toggleTime").name("Toggle Time");
gui
  .add(shaderControls, "enableElevation")
  .name("Enable Elevation")
  .onChange((value) => {
    material.uniforms.uEnableElevation.value = value ? 1 : 0;
  });
// gui
//   .add(shaderControls, "texture")
//   .name("ToggleUV")
//   .onChange((value) => {
//     material.uniforms.uToggleUV.value = value ? 1 : 0;
// f9aecc
//   });
gui
  .add(shaderControls, "toggleUV")
  .name("ToggleUV")
  .onChange((value) => {
    material.uniforms.uToggleUV.value = value ? 1 : 0;
  });
gui.add(material.uniforms.uRandom, "value").min(0).max(1).step(0.01).name("Random");
gui
  .add(shaderControls, "wireframe")
  .name("Wireframe")
  .onChange((value) => {
    material.wireframe = value; // Directly assign the new value
  });
gui
  .add(shaderControls, "jw")
  .name("JW")
  .onChange((value) => {
    // Toggle between the two fragment shaders
    material.fragmentShader = value ? framgmentJW : fragmentShader;
    material.needsUpdate = true;
  });
gui.add(material.uniforms.uBigWavesElevation, "value").min(0).max(1).step(0.01).name("Big Waves Elevation");

// Mesh
const mesh = new THREE.Mesh(geometry, material);

const waterFolder = gui.addFolder("water");
waterFolder
  .add(shaderControls, "water")
  .name("Water")
  .onChange((value) => {
    material.uniforms.uWater.value = value ? 1 : 0;
    shaderControls.water = value;
    shaderControls.jw = false;
    mesh.rotation.x = value ? -Math.PI * 0.5 : 0;
    if (material.uniforms.uWater.value) {
      material.uniforms.uFrequency.value.set(0.5, 0.5);
    }

    updateGeometry(value ? 2 : geometrySizes.size, value ? 128 : geometrySizes.segments);

    material.vertexShader = value ? watervertex : vertexShader;
    material.fragmentShader = value ? waterfragment : fragmentShader;
    material.needsUpdate = true;
  });
waterFolder
  .addColor(waterColors, "depthColor")
  .name("Depth Color")
  // .enable(shaderControls.water)
  .onChange((value) => {
    material.uniforms.uDepthColor.value.set(value);
  });
waterFolder
  .addColor(waterColors, "surfaceColor")
  .name("Surface Color")
  // .enable(shaderControls.water)
  .onChange((value) => {
    material.uniforms.uSurfaceColor.value.set(value);
  });
waterFolder.add(material.uniforms.uColorOffset, "value").min(0).max(1).step(0.01).name("Color Offset");
waterFolder.add(material.uniforms.uColorMultiplier, "value").min(0).max(10).step(0.1).name("Color Multiplier");
waterFolder.add(material.uniforms.uSmallWavesElevation, "value").min(0).max(1).step(0.01).name("Small Waves Elevation");
waterFolder
  .add(material.uniforms.uSmallWavesFrequency, "value")
  .min(0)
  .max(10)
  .step(0.01)
  .name("Small Waves Frequency");
waterFolder.add(material.uniforms.uSmallWavesSpeed, "value").min(0).max(1).step(0.01).name("Small Waves Speed");
waterFolder
  .add(material.uniforms.uSmallWavesIterations, "value")
  .min(0)
  .max(10)
  .step(0.01)
  .name("Small Waves Iterations");

scene.add(mesh);

/**
 * Sizes
 */
const sizes = {
  width: window.innerWidth,
  height: window.innerHeight,
};

window.addEventListener("resize", () => {
  // Update sizes
  sizes.width = window.innerWidth;
  sizes.height = window.innerHeight;

  // Update camera
  camera.aspect = sizes.width / sizes.height;
  camera.updateProjectionMatrix();

  // Update renderer
  renderer.setSize(sizes.width, sizes.height);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
});

/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height, 0.1, 100);
camera.position.set(0, 0, 2.5);
scene.add(camera);

// Controls
const controls = new OrbitControls(camera, canvas);
controls.enableDamping = true;

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
  canvas: canvas,
});
renderer.setSize(sizes.width, sizes.height);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

// Function to update geometry dynamically
function updateGeometry(size, segments) {
  // Dispose of the old geometry to free GPU memory
  geometry.dispose();

  // Create a new geometry
  geometry = new THREE.PlaneGeometry(size, size, segments, segments);

  // Assign the new geometry to the mesh
  mesh.geometry = geometry;
}

/**
 * Animate
 */
const clock = new THREE.Clock();

const tick = () => {
  const elapsedTime = clock.getElapsedTime();

  // Update material
  if (shaderControls.toggleTime) {
    material.uniforms.uTime.value = elapsedTime; // Use elapsed time
  } else {
    material.uniforms.uTime.value = 0; // Reset time
  }

  // Update controls
  controls.update();

  // Render
  renderer.render(scene, camera);

  // Call tick again on the next frame
  window.requestAnimationFrame(tick);
};

tick();
