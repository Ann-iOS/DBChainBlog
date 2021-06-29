//
//  BlogDetailView.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import UIKit

typealias BlogDetailReplyBlock = (_ replyTitle:String) -> ()

class BlogDetailView: UIView {

    var BlogReplyBlock :BlogDetailReplyBlock?

    var discussModelArr = [discussModel](){
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var titleStr = "" {
        didSet {
            titleLabel.text = titleStr
            viewHeight += Int(self.heightForView(text: titleStr, font: UIFont.boldSystemFont(ofSize: 25), width: SCREEN_WIDTH - 32))
        }
    }

    var detailTitleStr = "" {
        didSet {
            let paragraphStyle = NSMutableParagraphStyle.init()
            paragraphStyle.lineSpacing = 8.0
            paragraphStyle.alignment = .justified
            let attributes = [NSAttributedString.Key.font:UIFont.ThemeFont.HeadRegular,
                              NSAttributedString.Key.paragraphStyle: paragraphStyle]
            textLabel.attributedText = NSAttributedString(string: detailTitleStr, attributes: attributes)
            viewHeight += Int(self.height(text: detailTitleStr))
        }
    }

    var viewHeight = 50 {
        didSet {
            headerView.frame = CGRect(x: 0, y: 0, width: Int(SCREEN_WIDTH), height: viewHeight + 140)
        }
    }

    lazy var tipLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont().themeHNBoldFont(size: 26)
        label.text = "SUPPORTS"
        return label
    }()

    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont().themeHNMediumFont(size: 25)
        label.numberOfLines = 0
        return label
    }()

    lazy var textLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.ThemeFont.HeadRegular
        label.numberOfLines = 0
        return label
    }()

    lazy var commentLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "热门评论"
        label.textAlignment = .center
        label.font = UIFont().themeHNBoldFont(size: 22)
        return label
    }()

    lazy var topComLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Top Comments"
        label.textAlignment = .center
        label.font = UIFont().themeHNBoldFont(size: 13)
        return label
    }()

    lazy var replyBackView : UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: SCREEN_HEIGHT - kTabBarHeight - 88, width: SCREEN_WIDTH, height: 88))
        view.backgroundColor = .white
        return view
    }()

    lazy var replyTextBackView : UIView = {
        let view = UIView.init(frame: CGRect(x: 16, y: SCREEN_HEIGHT - kTabBarHeight - 78, width: SCREEN_WIDTH - 32, height: 52))
        view.extSetCornerRadius(14)
        view.backgroundColor = .colorWithHexString("EFEFEF")
        return view
    }()

    lazy var replyTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "留下你的观点吧!"
        tf.textColor = .black
        tf.backgroundColor = .clear
        tf.font = UIFont.ThemeFont.HeadRegular
        return tf
    }()

    lazy var replyBtn : UIButton = {
        let btn = UIButton()
        btn.setTitle("评论", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .colorWithHexString("2E44FF")
        btn.extSetCornerRadius(8)
        btn.addTarget(self, action: #selector(replyButtonClick), for: .touchUpInside)
        return btn
    }()

    lazy var headerView : UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: Int(SCREEN_WIDTH), height: viewHeight))
        tipLabel.frame = CGRect(x: 16, y: 10, width: SCREEN_WIDTH - 32, height: 26)
        view.addSubViews([tipLabel,titleLabel,textLabel,commentLabel,topComLabel])
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(tipLabel.snp.bottom).offset(10)
        }

        textLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.left.right.equalTo(titleLabel)
        }

        commentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textLabel.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }

        topComLabel.snp.makeConstraints { (make) in
            make.top.equalTo(commentLabel.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }

        return view
    }()

    lazy var tableView : UITableView = {
        let view = UITableView.init(frame: self.frame, style: .grouped)
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + kNavAndTabHeight + 20, right: 0)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.separatorStyle = .none
        view.register(UINib.init(nibName: "BlogDetailTableViewCell", bundle: nil), forCellReuseIdentifier: BlogDetailTableViewCell.identifier)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.estimatedRowHeight = 84
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableHeaderView = headerView
        self.addSubview(tableView)
        self.addSubview(replyBackView)
        self.addSubview(replyTextBackView)
        replyTextField.frame = CGRect(x: 10, y: 0, width: replyTextBackView.frame.width - 100, height: replyTextBackView.frame.height)
        replyBtn.frame = CGRect(x: replyTextField.frame.maxX + 4, y: 6, width: 80, height: 40)
        replyTextBackView.addSubViews([replyTextField,replyBtn])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func replyButtonClick() {
        if !self.replyTextField.text!.isBlank {
            if self.BlogReplyBlock != nil {
                self.BlogReplyBlock!(self.replyTextField.text!)
            }
        } else {
            SwiftMBHUD.showText("请先输入内容")
        }
    }

    /// UILbale 文本高度
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{

           let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
           label.numberOfLines = 0
           label.lineBreakMode = NSLineBreakMode.byWordWrapping
           label.font = font
           label.text = text
           label.sizeToFit()

           return label.frame.height
       }

    /// 计算富文本高度
    func height(text: String) -> CGFloat {        // 注意这里的宽度计算，要根据自己的约束来计算
            let maxSize = CGSize(width: (SCREEN_WIDTH - 32), height: CGFloat(MAXFLOAT))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .justified
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 8.0
            let labelSize = NSString(string: text).boundingRect(with: maxSize,
                                                                options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                                attributes:[.font : UIFont.ThemeFont.HeadRegular, .paragraphStyle: paragraphStyle],
                                                                context: nil).size
            return labelSize.height
    }

    /// 计算组头富文本高度
    func headerTextHeight(text: String) -> CGFloat {        // 注意这里的宽度计算，要根据自己的约束来计算
            let maxSize = CGSize(width: (SCREEN_WIDTH - 122), height: CGFloat(MAXFLOAT))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .justified
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 2.0
            let labelSize = NSString(string: text).boundingRect(with: maxSize,
                                                                options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                                attributes:[.font : UIFont.systemFont(ofSize: 15), .paragraphStyle: paragraphStyle],
                                                                context: nil).size
            return labelSize.height
    }
}

extension BlogDetailView : UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return discussModelArr.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let model = self.discussModelArr[section]
        return model.replyModelArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell :BlogDetailTableViewCell? = tableView.dequeueReusableCell(withIdentifier: BlogDetailTableViewCell.identifier, for: indexPath) as? BlogDetailTableViewCell

        if cell == nil {
            cell = BlogDetailTableViewCell.init(style: .default, reuseIdentifier: BlogDetailTableViewCell.identifier)
        }
        cell?.selectionStyle = .none
        cell?.replyModel = self.discussModelArr[indexPath.section].replyModelArr[indexPath.row]

        let cornerRadius:CGFloat = 15.0
        let sectionCount = tableView.numberOfRows(inSection: indexPath.section)
        let shapeLayer = CAShapeLayer()
        cell?.backView.layer.mask = nil
        //如果是最后一个单元格则设置圆角遮罩
        if indexPath.row == sectionCount - 1 {
            let bounds = cell?.backView.bounds
            let bezierPath = UIBezierPath(roundedRect: bounds!,
                                                          byRoundingCorners: [.bottomLeft,.bottomRight],
                                                          cornerRadii: CGSize(width: cornerRadius,height: cornerRadius))
            shapeLayer.path = bezierPath.cgPath
            cell?.backView.layer.mask = shapeLayer
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let textStr = self.discussModelArr[section].text
        let textHeight = self.height(text: textStr)
        return textHeight + 60
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let textStr = self.discussModelArr[section].text
        let textHeight = self.height(text: textStr)
        let view = sectionHeaderView.init(frame: CGRect(x: 16, y: 0, width: SCREEN_WIDTH - 32, height: textHeight + 60), textHeight: textHeight)
        view.model = self.discussModelArr[section]
        return view
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        return 12
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        return UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 12))
    }
    
}


class sectionHeaderView : UIView {

    var model = discussModel(){
        didSet{
            if model.imageData != nil {
                self.iconImgV.image = UIImage(data: model.imageData!)
            } else {
                self.iconImgV.image = UIImage(named: "home_icon_image")
            }

            self.nameLabel.text = model.nickName
            self.textLabel.text = model.text
        }
    }
    var iconImgV : UIImageView!
    var nameLabel:UILabel!
    var textLabel:UILabel!
    let cornerRadius:CGFloat = 15.0
    var shapeLayer:CAShapeLayer!

    var textHeight :CGFloat!
     init(frame: CGRect,textHeight: CGFloat) {
        super.init(frame: frame)

        self.textHeight = textHeight
        self.backgroundColor = .white
        iconImgV = UIImageView()
        iconImgV.extSetCornerRadius(24)
        self.addSubview(iconImgV)
        nameLabel = UILabel()
        nameLabel.textColor = .black
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)

        self.addSubview(nameLabel)
        textLabel = UILabel()

        textLabel.font = UIFont.systemFont(ofSize: 15)
        textLabel.textColor = .black
        self.addSubview(textLabel)

        //设置圆角遮罩
          shapeLayer = CAShapeLayer()
          self.layer.mask = shapeLayer
    }

    //覆盖frame，自动添加边距
      override var frame: CGRect {
          get {
              return super.frame
          }
          set {
              var frame = newValue
              frame.origin.x += cornerRadius
              frame.origin.y += 0
              frame.size.width -= 2 * cornerRadius
              frame.size.height -= 0
              super.frame = frame
          }
      }

      //子视图布局
      override func layoutSubviews() {
          super.layoutSubviews()

          self.iconImgV.frame = CGRect(x: 20, y: 18, width: 48, height: 48)
          self.nameLabel.frame =  CGRect(x: iconImgV.frame.maxX + 18, y: 18, width: 160, height: 26)
          self.textLabel.frame = CGRect(x: iconImgV.frame.maxX + 18, y: nameLabel.frame.maxY + 8, width: SCREEN_WIDTH - 122, height: textHeight)

          //调整遮罩层路径
        if model.replyModelArr.count > 0 {
            let bezierPath = UIBezierPath(roundedRect: bounds,
                                          byRoundingCorners: [.topLeft,.topRight],
                                          cornerRadii: CGSize(width: cornerRadius,
                                                              height: cornerRadius))
            shapeLayer.path = bezierPath.cgPath

        } else {

            let bezierPath = UIBezierPath(roundedRect: bounds,
                                          byRoundingCorners: [.topLeft,.topRight,.bottomLeft,.bottomRight],
                                          cornerRadii: CGSize(width: cornerRadius,
                                                              height: cornerRadius))
            shapeLayer.path = bezierPath.cgPath
        }
      }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
