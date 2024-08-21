import esbuild from "esbuild";
import { sassPlugin } from "esbuild-sass-plugin";

let config = {
  entryPoints: [
    './assets/javascripts/app.js',
  ],
  outdir: "dist",
  treeShaking: true,
  minify: true,
  bundle: true,
  drop: [
    "debugger",
  ],
  loader: {
    ".webp": "file",
    ".svg": "file"
  },
  plugins: [
    sassPlugin()
  ]
};

if (process.env.WATCH === "1") {
  let context = await esbuild.context(config);
  await context.watch();
} else {
  let result = await esbuild.build(config);
  console.log(result);
}
