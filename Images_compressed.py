import os
from PIL import Image

input_dir = r"D:\5120\hero"
output_dir = r"D:\5120\new hero"

os.makedirs(output_dir, exist_ok=True)

quality = 70
max_width = 1920
max_height = 1080

for filename in os.listdir(input_dir):
    if filename.lower().endswith((".jpg", ".jpeg", ".png", ".webp", ".bmp", ".tiff")):
        filepath = os.path.join(input_dir, filename)
        try:
            img = Image.open(filepath)

            # 等比缩放
            img.thumbnail((max_width, max_height))

            # 确保 PNG 转换为 JPG，避免透明通道报错
            if filename.lower().endswith(".png"):
                img = img.convert("RGB")
                output_path = os.path.join(output_dir, os.path.splitext(filename)[0] + ".jpg")
            else:
                output_path = os.path.join(output_dir, filename)

            img.save(output_path, optimize=True, quality=quality)
            print(f"✅ 压缩完成: {filename} → {output_path}")

        except Exception as e:
            print(f"❌ 处理失败 {filename}: {e}")

print("🎉 所有图片压缩完成！")
