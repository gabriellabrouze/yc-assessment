const UploadWidget = {

    mounted() {
        this.el.addEventListener("click", (e) => {
            e.preventDefault();

            cloudinary.openUploadWidget(
                {
                    cloudName: this.el.dataset.cloudName,
                    uploadPreset: this.el.dataset.cloudPreset,
                    cropping: true,
                    croppingAspectRatio: 1.0,
                    sources: ["local", "url", "image_search"],
                    multiple: false,
                    clientAllowedFormats: ["jpg", "png", "jpeg"],
                    maxFileSize: 2000000,
                    theme: "blue",
                    maxImageWidth: 200,
                    maxImageHeight: 200,
                    googleApiKey: this.el.dataset.googleApiKey,
                    searchBySites: ["vecteezy.com", "freepik.com"],
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