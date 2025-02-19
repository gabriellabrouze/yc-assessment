const UploadWidget = {

    mounted() {
        this.el.addEventListener("click", (e) => {
            e.preventDefault();

            const cloudName = this.el.dataset.cloudName;
            const uploadPreset = this.el.dataset.cloudPreset;

            cloudinary.openUploadWidget(
                {
                    cloudName: cloudName,
                    uploadPreset: uploadPreset,
                    cropping: true,
                    croppingAspectRatio: 1.0,
                    sources: ["local", "url", "facebook"],
                    multiple: false,
                    clientAllowedFormats: ["jpg", "png", "jpeg"],
                    maxFileSize: 5000000,
                    theme: "minimal",
                },
                (error, result) => {
                    if (!error && result && result.event === "success") {
                        const imageUrl = result.info.secure_url;
                        this.pushEvent("image_uploaded", { url: imageUrl });
                    }
                }
            );
        });
    },
};

export default UploadWidget