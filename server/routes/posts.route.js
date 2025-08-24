const express = require("express")
const router = express.Router()

router.get("/get-posts",async(req,res)=>{
    const {user_id} = req.body;
    try {
        const posts = await getPosts(user_id)
        res.json({posts})    
    } catch (error) {
        console.error("Error gettting posts:", error);
        res.status(500).json({ error: "Failed to get posts" });
    }
})
route.post("/post",async(req,res)=>{
    const {user_id} = req.body;
    try {
        const post = await addPost(user_id)
        res.json({post})
    } catch (error) {
        console.error("Error gettting posts:", error);
        res.status(500).json({ error: "Failed to get posts" });
    }
})
module.exports = router