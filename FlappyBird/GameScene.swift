//
//  GameScene.swift
//  FlappyBird
//
//  Created by 唐津 哲也 on 2021/05/04.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode:SKNode!
    var wallNode: SKNode!
    var bird: SKSpriteNode!
    
    //衝突判定カテゴリー
    var birdCategory:UInt32 = 1 << 0    //0...00001
    var groundCategory:UInt32 = 1 << 1  //0...00010
    var wallCategory: UInt32 = 1 << 2   //0...00100
    var scoreCategory:UInt32 = 1 << 3   //0...01000　スコア用の物体
    
    //スコア用の変数を定義
    var score: Int = 0
    //スコア＆ベストスコア表示用のNODEを設定
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode :SKLabelNode!
    //デフォルト値を記録するインスタンスを定義??
    let userDefaults: UserDefaults = UserDefaults.standard
    
    //いつ画面をviewに表示するか
    override func didMove(to view: SKView) {
        //重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self
        
        //背景色を指定(R15%G75%B90% 不透明度100%)
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //スクロールするスプライトの親ノードのインスタンスscrollNodeを設定
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //壁用の親ノードのインスタンスwallNodeを設定
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        //各スプライトを描画
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupScoreLabel()
        
        }
    
    func setupScoreLabel() {
        //-----------スコアラベルの設定------------
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score: \(score)"
        addChild(scoreLabelNode)
        
        //ーーーーーハイスコアラベルの設定ーーーーーーーー
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        //ベストスコアの定義let bestScore->表示
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score: \(bestScore)"
        addChild(bestScoreLabelNode)
        
        
    }
    
    
    //--------------------地面の描画---------------------
    func setupGround() {
        //地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest

        //必要な画像枚数を計算 (「画面の横幅 ÷ 地面の画像の横幅」に+ 2枚余分を足す)
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクションを定義(5秒で地面の横幅一枚分を左に移動)
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        //元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        //「左にスクロール->元の位置に戻す->左にスクロール....」を無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        //groundのスプライトを配置
        for i in 0 ..< needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            //スプライトの表示位置を指定
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            //スプライトにアクションを設定
            sprite.run(repeatScrollGround)
            
            //スプライトに物理演算を設定
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            //衝突のカテゴリーを設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            //衝突の際に動かないように設定
            sprite.physicsBody?.isDynamic = false
            
            //スプライトをSKNodeに描画
            scrollNode.addChild(sprite)
        }
    }
    
    //----------------------雲の描画------------------------
    func setupCloud() {
        //雲画像の読み込み
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        //必要な画像枚数を計算 (「画面の横幅 ÷ 地面の画像の横幅」に+ 2枚余分を足す)
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左方向に画像一枚分スクロールさせるアクションを定義(5秒で横幅一枚分を左に移動)
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
        //元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        //「左にスクロール->元の位置に戻す->左にスクロール....」を無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        //groundのスプライトを配置
        for i in 0 ..< needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            //z軸を-100とし、一番後ろになるようにする。
            sprite.zPosition = -100
            
            //スプライトの表示位置を指定
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )
            //スプライトにアクションを設定
            sprite.run(repeatScrollCloud)
            //スプライトをSKNodeに描画
            scrollNode.addChild(sprite)
        }
    
    }
    
    //-----------------------------壁の描写----------------------------------
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

        // Do any additional setup after loading the view.
    //----------------------------鳥の描画-----------------------------
    func setupBird() {
        //二種類の鳥の画像を読み込みImporting two bird images with SKTexture method.
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureA.filteringMode = .linear
        birdTextureB.filteringMode = .linear
        
        //鳥のアニメーションを設定（二種類の鳥の画像を交互に表示する）Define bird animation of which representing each of two images by turns with SKAction.animation()method.
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        //スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position =  CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        
        //物理演算の設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        //衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        //--------------衝突のカテゴリーを設定------------
        //鳥のカテゴリーを設定
        bird.physicsBody?.categoryBitMask = birdCategory
        //地面と壁の両方を、接触の対象として設定
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        //地面と壁の両方を、衝突（反発）の対象として設定
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        
        //アニメーションを設定
        bird.run(flap)
        //スプライトを追加
        addChild(bird)
    }
    
    //タップ操作時の動作を実装する
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //回転アクションが終わった後に画面をタップしたら、リスタート
        func restart() {
            //スコアをゼロに戻す
            score = 0
            scoreLabelNode.text = "Score: \(score) "
            
            //鳥の位置.速度を初期状態に戻す
            bird.position = CGPoint (x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
            bird.physicsBody?.velocity = CGVector.zero
            //地面と壁の両方を、衝突（反発）の対象に戻す
            bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
            //鳥の回転角をゼロに戻す
            bird.zRotation = 0
            //wallNodeから全ての壁を消去
            wallNode.removeAllChildren()
            
            bird.speed = 1
            scrollNode.speed = 1
        }
        
        //スクロールが止まっていなければ -> scrollNode.speed >0 ならば
        if scrollNode.speed > 0 {
            //鳥の速度をゼロにする。
            bird.physicsBody?.velocity = CGVector.zero
            //鳥に縦方向の力を加える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
            //鳥の速度がゼロならば
        } else if bird.speed == 0 {
            restart()
        }
    }
    
    //SKPhysiceContactDelegateのメソッドを実装（衝突時の挙動）
    func didBegin(_ contact: SKPhysicsContact) {
        //scrollNodeのactionスピードが０以下->何もせずにそのまま返すreturn
        if scrollNode.speed <= 0 {
            return
        }
        
        //bodyAとbodyBの内容確認用ログ
        print(contact.bodyA.categoryBitMask)
        print(contact.bodyA.categoryBitMask & scoreCategory)
        print(scoreCategory)
        print(contact.bodyB.categoryBitMask)
        print(contact.bodyB.categoryBitMask & scoreCategory)
        //score(bodyA)とbird(bodyB)が接触した場合
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory == scoreCategory) {
            //スコアを＋１加算
            print("ScoreUP")
            score += 1
            //スコア表示を更新
            scoreLabelNode.text = "Score: \(score)"
            
            //ーーーーーベストスコア更新の確認ーーーーーーーーーー
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score: \(bestScore)"
                userDefaults.set(bestScore, forKey:"BEST")
                userDefaults.synchronize()
            }
            
            
        //壁(bodyA)とbird(bodyB)が接触した場合
        } else {
            print("GAME OVER")
            //スクロールを止める
            scrollNode.speed = 0
            //鳥の衝突相手を「地面のみ」に設定し直す（壁を除外）
            bird.physicsBody?.collisionBitMask = groundCategory
            //鳥を回転
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y), duration: 1)
            //鳥を回転させ、回転が終了したらスピードをゼロにする（動きを止める）
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
