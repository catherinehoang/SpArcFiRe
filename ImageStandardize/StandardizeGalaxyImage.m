(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



StandardizeGalaxyImage[imgPath_] := Module[{img, imgMtx, origDims, fitMc, mean, covar, xPadding, yPadding, padImgMtx, paddedDims, yStart, xStart, eigvec, majAxAngle, rotAngle, normImg, normDims, axisRatio, cropSize},
Print[img = ColorConvert[Import[imgPath], "GrayScale"]];
imgMtx = ImageData[img];
origDims = Dimensions[imgMtx];
fitMc = fitGaussianToIntensityVals[imgMtx, 5, False];
Print[mean = {Round[fitMc[[1, 1]] ], Round[fitMc[[1, 2]] ]}];
Print[covar = fitMc[[2]]];

(* pad image matrix so that fitted mean is at the center *)
Print[xPadding = (mean[[1]] - 1) - (origDims[[2]] - mean[[1]])];
Print[yPadding = (mean[[2]] - 1) - (origDims[[1]] - mean[[2]])];
padImgMtx = Table[0, {r, 1, (origDims[[1]] + Abs[yPadding])}, {c, 1, (origDims[[2]] + Abs[xPadding])}];
Print[paddedDims = Dimensions[padImgMtx]];
yStart = Max[yPadding, 0] + 1;
xStart = -Min[xPadding, 0] + 1;
padImgMtx[[yStart ;; yStart + origDims[[1]] - 1, xStart ;; xStart + origDims[[2]] - 1 ]] = imgMtx;
Print[normImg = Image[padImgMtx]];

 (* rotate the image so that the major axis of the elipse defined by the fitted covariance matrix is aligned with the y-axis *)
eigvec = Eigenvectors[covar, 1];
If[eigvec[[1, 2]] < 0, eigvec = eigvec * -1;];
Print[eigvec];
Print[majAxAngle = ArcTan[eigvec[[1, 1]], eigvec[[1, 2]]]];
rotAngle = \[Pi]/2 - majAxAngle;
Print[normImg = ImageRotate[normImg, rotAngle]];

(* stretch the x-direction of the image so that the ellipse defined by the fitted covariance matrix is isotropic *)
axisRatio = Max[covar[[1, 1]], covar[[2, 2]]]/Min[covar[[1, 1]], covar[[2,2]]];
normDims = Dimensions[ImageData[normImg]];
Print[normImg = ImageResize[normImg, {Round[normDims[[1]] * axisRatio], normDims[[2]]} ] ];

(*Print[cropSize = Round[  Max[covar[[1, 1]], covar[[2, 2]]] / 5  ]];*)
cropSize = cropSize /. N[Solve[PDF[MultinormalDistribution[{0, 0}, fitMc[[2]] ],{cropSize * eigvec[[1, 1]], cropSize * eigvec[[1, 2]]}] == 10^-7, cropSize]][[1]];
Print[cropSize = 2 * Round[Abs[Re[cropSize]]]];
normImg = ImageResize[ImageCrop[normImg, {cropSize, cropSize}], 512];

Export[ToString[Round[Mod[AbsoluteTime[], 1000000]]] <>"_normImg.jpg", normImg];
Return[normImg];
];


