#include <iostream>
#include <cmath>
#include <cuda_runtime.h>
#include <fstream>

#define WIDTH 1024
#define HEIGHT 1024
#define G 6.674e-11
#define C 3e8
#define M 2e30   // 1 solar mass

__global__ void renderBlackHole(float *image) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    if (x >= WIDTH || y >= HEIGHT) return;

    // normalized coords (-1 to 1)
    float nx = (2.0f * x / WIDTH - 1.0f);
    float ny = (2.0f * y / HEIGHT - 1.0f);
    float b = sqrtf(nx * nx + ny * ny) + 1e-6f;

    // gravitational deflection
    float alpha = 4.0f * G * M / (C * C * b);

    // brightness falloff
    float intensity = expf(-15.0f * alpha);

    int idx = (y * WIDTH + x) * 3;
    image[idx + 0] = intensity;          // red
    image[idx + 1] = intensity * 0.8f;   // green
    image[idx + 2] = intensity * 0.6f;   // blue
}

int main() {
    size_t imageSize = WIDTH * HEIGHT * 3 * sizeof(float);
    float *d_image, *h_image;

    cudaMalloc(&d_image, imageSize);
    h_image = (float*)malloc(imageSize);

    dim3 blockSize(16, 16);
    dim3 gridSize((WIDTH + blockSize.x - 1) / blockSize.x,
                  (HEIGHT + blockSize.y - 1) / blockSize.y);

    renderBlackHole<<<gridSize, blockSize>>>(d_image);
    cudaMemcpy(h_image, d_image, imageSize, cudaMemcpyDeviceToHost);

    std::ofstream out("blackhole.ppm");
    out << "P3\n" << WIDTH << " " << HEIGHT << "\n255\n";
    for (int i = 0; i < WIDTH * HEIGHT * 3; ++i) {
        int val = static_cast<int>(255.0f * fminf(h_image[i], 1.0f));
        out << val << " ";
    }
    out.close();

    cudaFree(d_image);
    free(h_image);

    std::cout << "Rendered blackhole.ppm ✅" << std::endl;
    return 0;
}
