const isCheckOwner = async (req, res, next) => {
  try {
    const ownerAddress = req.headers["authorization"];
    const owner = process.env.ADMIN_ADDRESS;

    if (!ownerAddress) {
      return res.status(404).json({ msg: "Invalid Owner Address." });
    }

    if (typeof ownerAddress !== "string") {
      return res.status(400).json({ msg: "Invalid Owner Address Format." });
    }

    if (ownerAddress.toLowerCase() !== owner.toLowerCase()) {
      return res.status(500).json({ msg: "Owner Address not matched." });
    }
    console.log("ownerAddress", ownerAddress);

    next();
  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({ message: "Internal Server Error" });
  }
};

module.exports = isCheckOwner;
