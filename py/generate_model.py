from PIL import Image
import urllib
import torch
import torch.nn as nn
import coremltools
import torchvision


class ToiletDetection(nn.Module):
    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self.model = torchvision.models.mobilenet_v3_large(
            weights=torchvision.models.MobileNet_V3_Large_Weights
        )

    def forward(self, img):
        out = self.model(img)
        return nn.Softmax()(out)


model = ToiletDetection()
model.eval()

input = torch.rand(1, 3, 224, 224)
model = torch.jit.trace(model, input)
image_input = coremltools.ImageType(
    shape=(1, 3, 224, 224),
    bias=[-1, -1, -1],
    scale=1/127,
)

# Download class labels (from a separate file)
label_url = 'https://storage.googleapis.com/download.tensorflow.org/data/ImageNetLabels.txt'
class_labels = urllib.request.urlopen(label_url).read().splitlines()
class_labels = class_labels[1:]  # remove the first class which is background
assert len(class_labels) == 1000

# make sure entries of class_labels are strings
for i, label in enumerate(class_labels):
    if isinstance(label, bytes):
        class_labels[i] = label.decode("utf8")

classifier_config = coremltools.ClassifierConfig(class_labels=class_labels)

model = coremltools.convert(
    model,
    convert_to="mlprogram",
    inputs=[image_input],
    classifier_config=classifier_config
)

model.save("mobilenetv3.mlpackage")

# Use PIL to load and resize the image to expected size
example_image = Image.open("toilet.webp").resize((224, 224))

# Make a prediction using Core ML
out_dict = model.predict({"img": example_image})

# Print out top-1 prediction
print(out_dict["classLabel"])  # toilet seat
