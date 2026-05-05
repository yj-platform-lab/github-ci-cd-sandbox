# ---------------------------------------
# IAM OIDC Provider (GitHub Actions)
# ---------------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  # GitHub ActionsがOIDCトークンを発行するIssuer URL
  url = "https://token.actions.githubusercontent.com"

  # トークンのaud（利用先）としてAWS STSを指定
  client_id_list = [
    "sts.amazonaws.com"
  ]
}

# ---------------------------------------
# IAM Trust Policy (AssumeRole用)
# ---------------------------------------
data "aws_iam_policy_document" "github_actions_assume_role" {

  statement {
    effect = "Allow"

    # OIDCトークンを用いたロール引き受けを許可
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    # 信頼する主体（GitHubのOIDC Provider）
    principals {
      type = "Federated"

      identifiers = [
        # 上で定義したGitHub OIDC ProviderのARN
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    # -------------------------------
    # Condition: aud（Audience）
    # -------------------------------
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      # AWS STS向けに発行されたトークンのみ許可
      values   = ["sts.amazonaws.com"]
    }

    # -------------------------------
    # Condition: sub（Subject）
    # -------------------------------
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      # 許可するGitHub Actionsの実行元を制限
      # 形式: repo:<org>/<repo>:ref:refs/heads/<branch>
      # 今回は特定リポジトリ配下（※ブランチ制限は未指定）
      values = [
        "repo:yj-platform-lab/github-ci-cd-sandbox:ref:refs/heads/main"
      ]
    }
  }
}

# ---------------------------------------
# IAM Role
# ---------------------------------------
resource "aws_iam_role" "github_actions" {
  name = "github-actions-terraform-role"

  # 上記Trust PolicyをRoleに適用
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}