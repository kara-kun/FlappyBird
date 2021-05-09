import SpriteKit

class GameScene: SKScene {
    func setupWall() {
        //壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        
        //移動する距離を計算
        let movingdistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        //画面外まで移動するアクションを作成:4秒で「画面横幅サイズ ＋ 壁の横幅サイズ」
        let moveWall = SKAction.moveBy(x: -movingdistance, y: 0, duration: 4)
        //自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        //２つのアニメーションを順に実行するアクションを作成(moveWall->removeWall)
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        //鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        //鳥が通り抜ける隙間の長さを、鳥のサイズbirdSize.heightの3倍に設定
        let slit_length = birdSize.height * 3
        //隙間位置の上下の振れ幅を、鳥のサイズの2.5倍をする
        let random_y_range = birdSize.height * 2.5
        //---------下の壁とY軸下限位置を計算----------
        //地面の大きさを取得
        let groundSize = SKTexture(imageNamed: "ground").size()
        //壁の縦位置の中心を計算（画面の縦幅ーgroundの縦幅）÷２　＋　groundの縦幅
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        //壁の下限＝空中央ー(スリット高さの半分+壁高さの半分＋スリット位置上下の振れ幅の半分）
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2
 
        //壁を生成するアクションを作成
        let creatWallAnimation = SKAction.run({
            //壁を見せるノードを作成
            let wall = SKNode()
            //壁の最初のxy位置を、画面右端、画面外側スレスレに設定
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            //z軸を雲の手前、地面の奥に設定
            wall.zPosition = -50
            
            //０〜random_y_rangeまでのランダム値を生成
            let randum_y = CGFloat.random(in: 0..<random_y_range)
            //y軸の下限にランダムな値を足して、下の壁のy座標を決定
            let under_wall_y = under_wall_lowest_y + randum_y
            
            //下の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            //----------------下の壁に物理演算を追加--------------
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            //下の壁にカテゴリーを設定
            under.physicsBody?.categoryBitMask = self.wallCategory
            //衝突時に動かないように設定
            under.physicsBody?.isDynamic = false
            //SKNode"wall"に上の壁を追加
            wall.addChild(under)
            
            //下の壁の位置を基準に、上の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            //----------------上の壁に物理演算を追加--------------
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            //上の壁にカテゴリーを設定
            upper.physicsBody?.categoryBitMask = self.wallCategory
            //衝突時に動かないように設定
            upper.physicsBody?.isDynamic = false
            //SKNode"wall"に下の壁を追加
            wall.addChild(upper)
            
            //ーーーーーーーーーースコアアップ用のノード-------------
            //scoreNodeを設定（これ自体は透明）
            let scoreNode = SKNode()
            //scoreNodeの位置を、x＝上の壁の幅＋鳥の幅の半分　y=画面の高さの半分に設定
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
            //scoreNodeの形を、大きさを、width＝壁と同じ heigth=画面の高さと同じ　四角(rectangle)で設定
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            //scoreNode自体は動かない
            scoreNode.physicsBody?.isDynamic = false
            //scoreNodeのカテゴリーを設定
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            //衝突の対象 ＝ 鳥birdに設定
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            //SKNode(wall)にscoreNodeを追加
            wall.addChild(scoreNode)
            
            //壁にwallAnimationアニメーションを適用
            wall.run(wallAnimation)
            self.wallNode.addChild(wall)
                        
        })
        
        //次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([creatWallAnimation, waitAnimation]))
        wallNode.run(repeatForeverAnimation)
        
    }
    
}

