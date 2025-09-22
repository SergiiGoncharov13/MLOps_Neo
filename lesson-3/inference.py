import torch
from torchvision import transforms
from PIL import Image
import argparse
import json
import urllib.request

parser = argparse.ArgumentParser()
parser.add_argument("--img", type=str, required=True, help="Path to img")
args = parser.parse_args()

url = "https://raw.githubusercontent.com/pytorch/hub/master/imagenet_classes.txt"
class_idx = []
with urllib.request.urlopen(url) as f:
    class_idx = [line.strip() for line in f]


preprocess = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

model = torch.jit.load("model.pt")
model.eval()

image = Image.open(args.img).convert("RGB")
input_tensor = preprocess(image).unsqueeze(0)

with torch.no_grad():
    output = model(input_tensor)
    probabilites = torch.nn.functional.softmax(output[0], dim=0)

top3 = torch.topk(probabilites, 3)
for idx, prob in zip(top3.indices, top3.values):
    print(f"{class_idx[idx]}: {prob.item()*100:.2f}%")
