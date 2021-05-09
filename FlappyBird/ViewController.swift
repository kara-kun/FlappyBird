//
//  ViewController.swift
//  FlappyBird
//
//  Created by 唐津 哲也 on 2021/05/04.
//

import UIKit
//SpriteKitフレームワークをインポート
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //viewをSKView型にDownキャスティングしてskViewインスタンスを作成
        let skView = self.view as! SKView
        //フレームレートを表示
        skView.showsFPS = true
        //Nodeの数を表示
        skView.showsNodeCount = true
        
        //viewと同じサイズでシーンを作成する
        let scene = GameScene(size: skView.frame.size)
        
        //ビューにシーンを表示
        skView.presentScene(scene)
    }
    //ステータスバーを消す
    override var prefersStatusBarHidden: Bool {
        get{
            return true
        }
    }
    


}

